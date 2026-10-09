"""Authenticated DigiPay checkout endpoints for customer gas orders."""

import logging
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP

from django.db import transaction
from django.db.models import F
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Delivery, GasBottle
from .serializers import DeliverySerializer, PaymentInitiateSerializer
from .services.digipay import get_digipay_client, normalize_status

logger = logging.getLogger(__name__)


def _fail_order(order_id):
    """Fail an unpaid order and return its reserved bottle to inventory once."""
    with transaction.atomic():
        order = Delivery.objects.select_for_update().get(pk=order_id)
        if order.payment_status in {"PAID", "REFUNDED", "FAILED"}:
            return order
        if order.stock_deducted:
            GasBottle.objects.filter(pk=order.gas_bottle_id).update(
                stock_quantity=F("stock_quantity") + 1
            )
            order.stock_deducted = False
        order.payment_status = "FAILED"
        order.status = "CANCELLED"
        order.save(
            update_fields=["payment_status", "status", "stock_deducted", "updated_at"]
        )
        return order


def _order_response(order, request, message=None, http_status=status.HTTP_200_OK):
    payload = {
        "order_id": order.id,
        "payment_status": order.payment_status,
        "transaction_id": order.payment_transaction_id,
        "payment_operator": order.payment_operator,
        "amount": float(order.payment_amount),
        "unit_price": float(order.unit_price),
        "delivery_fee": float(order.delivery_fee),
        "order": DeliverySerializer(order, context={"request": request}).data
        if order.payment_status == "PAID"
        else None,
    }
    if message:
        payload["message"] = message
    return Response(payload, status=http_status)


class PaymentInitiateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = request.user
        if (
            user.is_delivery_person
            or hasattr(user, "vendor_profile")
            or user.is_admin
            or user.is_superuser
            or user.is_staff
        ):
            return Response(
                {"detail": "Only customer accounts can pay for gas orders."},
                status=status.HTTP_403_FORBIDDEN,
            )

        serializer = PaymentInitiateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            client = get_digipay_client()
        except Exception:
            logger.exception("DigiPay is unavailable or not configured")
            return Response(
                {"detail": "Mobile Money payments are not configured on the server."},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        bottle_data = serializer.validated_data["gas_bottle"]
        fulfillment = serializer.validated_data["fulfillment_method"]
        delivery_address = serializer.validated_data.get("delivery_address") or ""
        operator = serializer.validated_data["payment_operator"]
        phone = serializer.validated_data["payer_phone"]

        with transaction.atomic():
            bottle = get_object_or_404(
                GasBottle.objects.select_for_update().select_related("vendor"),
                pk=bottle_data.pk,
            )
            if not bottle.vendor.is_approved or bottle.vendor.application_status != "APPROVED":
                return Response(
                    {"gas_bottle": "This supplier is not approved."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            if bottle.stock_quantity < 1:
                return Response(
                    {"gas_bottle": "This bottle is out of stock."},
                    status=status.HTTP_409_CONFLICT,
                )

            bottle.stock_quantity -= 1
            bottle.save(update_fields=["stock_quantity", "updated_at"])
            delivery_fee = (
                Decimal("50") if fulfillment == "DELIVERY" else Decimal("0")
            )
            payment_amount = (bottle.price + delivery_fee).quantize(
                Decimal("1"), rounding=ROUND_HALF_UP
            )
            order = Delivery.objects.create(
                client=user,
                vendor=bottle.vendor,
                gas_bottle=bottle,
                fulfillment_method=fulfillment,
                delivery_address=delivery_address or bottle.vendor.address,
                latitude=serializer.validated_data.get("latitude"),
                longitude=serializer.validated_data.get("longitude"),
                unit_price=bottle.price,
                delivery_fee=delivery_fee,
                payment_amount=payment_amount,
                payment_status="INITIATING",
                payment_operator=operator,
                payer_phone=phone,
                stock_deducted=True,
            )

        try:
            payin = client.payments.initiate(
                amount=int(payment_amount),
                customer_phone=phone,
                customer_email=user.email or None,
                metadata={"bookingIds": [str(order.id)]},
            )
        except Exception as exc:
            gateway_status = getattr(exc, "status_code", None)
            logger.warning(
                "DigiPay initiation failed for order %s (error type %s, HTTP status %s)",
                order.id,
                type(exc).__name__,
                gateway_status,
            )
            if gateway_status is not None and gateway_status < 500:
                failed_order = _fail_order(order.id)
                return _order_response(
                    failed_order,
                    request,
                    "DigiPay rejected the payment request. Check the number and try again.",
                    status.HTTP_502_BAD_GATEWAY,
                )
            order.payment_status = "UNKNOWN"
            order.save(update_fields=["payment_status", "updated_at"])
            return _order_response(
                order,
                request,
                "Payment initiation could not be confirmed. Contact support before retrying.",
                status.HTTP_202_ACCEPTED,
            )

        transaction_id = str(
            payin.get("transaction_id") or payin.get("transactionId") or ""
        ).strip()
        if not transaction_id:
            order.payment_status = "UNKNOWN"
            order.save(update_fields=["payment_status", "updated_at"])
            return _order_response(
                order,
                request,
                "DigiPay did not return a transaction reference. Contact support before retrying.",
                status.HTTP_202_ACCEPTED,
            )

        provider_status = normalize_status(payin.get("status"))
        if provider_status in {"failed", "declined", "rejected", "cancelled", "canceled"}:
            failed_order = _fail_order(order.id)
            return _order_response(
                failed_order,
                request,
                "The payment request was declined by the operator.",
                status.HTTP_402_PAYMENT_REQUIRED,
            )

        order.payment_transaction_id = transaction_id
        order.payment_status = "PENDING"
        order.save(update_fields=["payment_transaction_id", "payment_status", "updated_at"])
        return _order_response(
            order,
            request,
            "Approve the Mobile Money prompt on your phone, then check payment status.",
            status.HTTP_202_ACCEPTED,
        )


class PaymentStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, order_id):
        order = get_object_or_404(Delivery, pk=order_id, client=request.user)
        if order.payment_status in {"PAID", "REFUNDED", "FAILED"}:
            return _order_response(order, request)
        if not order.payment_transaction_id:
            return _order_response(
                order,
                request,
                "There is no confirmed DigiPay transaction reference to check.",
                status.HTTP_202_ACCEPTED,
            )

        try:
            client = get_digipay_client()
            transaction_info = client.payments.get_status(
                order.payment_transaction_id
            )
        except Exception:
            logger.exception("DigiPay status lookup failed for order %s", order.id)
            return _order_response(
                order,
                request,
                "Payment status is still pending. Try checking again shortly.",
                status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        provider_status = normalize_status(transaction_info.get("status"))
        if provider_status in {"success", "succeeded", "paid", "completed"}:
            reported_amount = transaction_info.get("base_amount")
            if reported_amount is None:
                reported_amount = transaction_info.get("amount")
            if reported_amount is not None:
                try:
                    if Decimal(str(reported_amount)) != order.payment_amount:
                        order.payment_status = "UNKNOWN"
                        order.save(update_fields=["payment_status", "updated_at"])
                        return _order_response(
                            order,
                            request,
                            "The gateway amount does not match this order. Contact support before collection or delivery.",
                            status.HTTP_409_CONFLICT,
                        )
                except InvalidOperation:
                    return _order_response(
                        order,
                        request,
                        "DigiPay returned an unreadable payment amount. Contact support.",
                        status.HTTP_409_CONFLICT,
                    )

            with transaction.atomic():
                order = Delivery.objects.select_for_update().get(pk=order.pk)
                if order.payment_status == "FAILED":
                    return _order_response(order, request)
                if order.payment_status != "PAID":
                    order.payment_status = "PAID"
                    order.payment_confirmed_at = timezone.now()
                    order.save(
                        update_fields=[
                            "payment_status",
                            "payment_confirmed_at",
                            "updated_at",
                        ]
                    )
        elif provider_status in {
            "failed", "declined", "rejected", "cancelled", "canceled", "expired"
        }:
            order = _fail_order(order.id)
        return _order_response(order, request)
