import logging
from datetime import timedelta
from decimal import Decimal, InvalidOperation

from django.db import transaction
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import CustomUser, SubscriptionPayment
from .serializers import SubscriptionPaymentInitiateSerializer
from .services.digipay import get_digipay_client, normalize_status

logger = logging.getLogger(__name__)

PLAN_PRICES_XAF = {"basic": Decimal("9990"), "pro": Decimal("19990")}


def _payment_payload(payment, message=""):
    result = {
        "payment_id": payment.id,
        "payment_status": payment.payment_status,
        "transaction_id": payment.transaction_id,
        "payment_operator": payment.payment_operator,
        "amount": int(payment.amount),
        "plan": payment.plan,
    }
    if message:
        result["message"] = message
    return result


class SubscriptionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        active = user.subscription_plan != "free" and (
            user.subscription_expires_at is None
            or user.subscription_expires_at > timezone.now()
        )
        return Response(
            {
                "plan": user.subscription_plan if active else "free",
                "expires_at": user.subscription_expires_at if active else None,
            },
            status=status.HTTP_200_OK,
        )


class SubscriptionPaymentInitiateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = SubscriptionPaymentInitiateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        plan = serializer.validated_data["plan"]
        user = request.user

        try:
            client = get_digipay_client()
        except Exception:
            logger.exception("DigiPay is unavailable or not configured for a subscription")
            return Response(
                {"detail": "Mobile Money payments are not configured on the server."},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        payment = SubscriptionPayment.objects.create(
            user=user,
            plan=plan,
            amount=PLAN_PRICES_XAF[plan],
            payment_operator=serializer.validated_data["payment_operator"],
            payer_phone=serializer.validated_data["payer_phone"],
            payment_status="INITIATING",
        )

        try:
            payin = client.payments.initiate(
                amount=int(payment.amount),
                customer_phone=payment.payer_phone,
                customer_email=user.email or None,
                metadata={
                    "subscriptionPaymentId": str(payment.id),
                    "plan": payment.plan,
                },
            )
        except Exception as exc:
            gateway_status = getattr(exc, "status_code", None)
            logger.warning(
                "DigiPay subscription initiation failed (error type %s, HTTP status %s)",
                type(exc).__name__,
                gateway_status,
            )
            payment.payment_status = "FAILED" if gateway_status and gateway_status < 500 else "UNKNOWN"
            payment.save(update_fields=["payment_status", "updated_at"])
            return Response(
                _payment_payload(
                    payment,
                    "DigiPay could not confirm the payment request. Check the status before trying again.",
                ),
                status=status.HTTP_202_ACCEPTED,
            )

        transaction_id = str(
            payin.get("transaction_id") or payin.get("transactionId") or ""
        ).strip()
        if not transaction_id:
            payment.payment_status = "UNKNOWN"
            payment.save(update_fields=["payment_status", "updated_at"])
            return Response(
                _payment_payload(payment, "DigiPay did not return a payment reference."),
                status=status.HTTP_202_ACCEPTED,
            )

        provider_status = normalize_status(payin.get("status"))
        if provider_status in {"failed", "declined", "rejected", "cancelled", "canceled"}:
            payment.payment_status = "FAILED"
            payment.save(update_fields=["payment_status", "updated_at"])
            return Response(
                _payment_payload(payment, "The payment request was declined by the operator."),
                status=status.HTTP_402_PAYMENT_REQUIRED,
            )

        payment.transaction_id = transaction_id
        payment.payment_status = "PENDING"
        payment.save(update_fields=["transaction_id", "payment_status", "updated_at"])
        return Response(
            _payment_payload(payment, "Approve the Mobile Money prompt on your phone."),
            status=status.HTTP_202_ACCEPTED,
        )


class SubscriptionPaymentStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, payment_id):
        payment = get_object_or_404(
            SubscriptionPayment, pk=payment_id, user=request.user
        )
        if payment.payment_status in {"PAID", "FAILED"}:
            return Response(_payment_payload(payment), status=status.HTTP_200_OK)
        if not payment.transaction_id:
            return Response(
                _payment_payload(payment, "No confirmed DigiPay reference is available yet."),
                status=status.HTTP_202_ACCEPTED,
            )

        try:
            client = get_digipay_client()
            details = client.payments.get_status(payment.transaction_id)
        except Exception:
            logger.exception("DigiPay subscription status lookup failed for payment %s", payment.id)
            return Response(
                _payment_payload(payment, "Payment is still pending. Check again shortly."),
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        provider_status = normalize_status(details.get("status"))
        if provider_status in {"success", "succeeded", "paid", "completed"}:
            reported_amount = details.get("base_amount")
            if reported_amount is None:
                reported_amount = details.get("amount")
            if reported_amount is not None:
                try:
                    if Decimal(str(reported_amount)) != payment.amount:
                        payment.payment_status = "UNKNOWN"
                        payment.save(update_fields=["payment_status", "updated_at"])
                        return Response(
                            _payment_payload(payment, "The payment amount does not match this plan."),
                            status=status.HTTP_409_CONFLICT,
                        )
                except InvalidOperation:
                    return Response(
                        _payment_payload(payment, "DigiPay returned an unreadable amount."),
                        status=status.HTTP_409_CONFLICT,
                    )

            with transaction.atomic():
                locked_payment = SubscriptionPayment.objects.select_for_update().get(
                    pk=payment.pk
                )
                if locked_payment.payment_status != "PAID":
                    user = CustomUser.objects.select_for_update().get(pk=request.user.pk)
                    now = timezone.now()
                    starts_at = max(user.subscription_expires_at or now, now)
                    user.subscription_plan = locked_payment.plan
                    user.subscription_expires_at = starts_at + timedelta(days=30)
                    user.save(update_fields=["subscription_plan", "subscription_expires_at"])
                    locked_payment.payment_status = "PAID"
                    locked_payment.save(update_fields=["payment_status", "updated_at"])
                payment = locked_payment
        elif provider_status in {"failed", "declined", "rejected", "cancelled", "canceled", "expired"}:
            payment.payment_status = "FAILED"
            payment.save(update_fields=["payment_status", "updated_at"])

        return Response(_payment_payload(payment), status=status.HTTP_200_OK)
