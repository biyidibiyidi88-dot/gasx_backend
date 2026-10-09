import json
import logging
import csv
from datetime import datetime, timedelta
from decimal import Decimal

from django.contrib.auth import get_user_model, login, logout
from django.core.files.storage import default_storage
from django.db import models, transaction
from django.db.models import Count, F, Q
from django.http import FileResponse, HttpResponse
from django.utils import timezone
from rest_framework import generics, permissions, status
from rest_framework.authtoken.models import Token
from rest_framework.exceptions import PermissionDenied
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Alert, CustomUser, Delivery, DeliveryPersonProfile, GasReading, GasSensor, House, Notification, CookableFood, VendorProfile, GasBottle
from .bottle_config import user_bottle_capacity_kg
from .serializers import (
    AlertSerializer,
    DeliverySerializer,
    DeliveryPersonProfileSerializer,
    GasLeakAlertSerializer,
    GasReadingSerializer,
    GasSensorSerializer,
    HouseSerializer,
    LoginSerializer,
    NotificationSerializer,
    PasswordChangeSerializer,
    UserManagementSerializer,
    UserProfileSerializer,
    UserSerializer,
    CookableFoodSerializer,
    VendorProfileSerializer,
    GasBottleSerializer,
    PublicVendorProfileSerializer,
)
from .services.ai_service import AIPredictionService
from .services.email_service import email_service
from .permissions import IsSystemAdmin

User = get_user_model()


class RegisterView(APIView):
    parser_classes = [JSONParser, MultiPartParser, FormParser]

    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token = Token.objects.create(user=user)
            return Response(
                {"user": UserSerializer(user).data, "token": token.key},
                status=status.HTTP_201_CREATED,
            )
        return Response(
            {"errors": serializer.errors, "message": "Registration failed"},
            status=status.HTTP_400_BAD_REQUEST,
        )


class LoginView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data["user"]
            token, created = Token.objects.get_or_create(user=user)
            login(request, user)
            return Response(
                {"token": token.key, "user": UserSerializer(user).data},
                status=status.HTTP_200_OK,
            )
        return Response(
            {"errors": serializer.errors, "message": "Login failed"},
            status=status.HTTP_400_BAD_REQUEST,
        )


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        # Keep the account's DRF token stable across app logouts so linked
        # devices such as the ESP32 continue using the same credential.
        logout(request)
        return Response(status=status.HTTP_200_OK)


class UserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class ProfileDeleteView(generics.DestroyAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

    def perform_destroy(self, instance):
        instance.delete()


class PasswordChangeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = PasswordChangeSerializer(data=request.data)
        if serializer.is_valid():
            user = request.user
            if not user.check_password(serializer.data["old_password"]):
                return Response(
                    {"old_password": ["Wrong password."]},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            user.set_password(serializer.data["new_password"])
            user.save()
            return Response(status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class HouseListCreateView(generics.ListCreateAPIView):
    serializer_class = HouseSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return House.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class HouseDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = HouseSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = "id"
    lookup_url_kwarg = "pk"

    def get_queryset(self):
        return House.objects.filter(user=self.request.user)


class GasSensorListView(generics.ListAPIView):
    serializer_class = GasSensorSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if self.request.user.is_admin or self.request.user.is_superuser or self.request.user.is_staff:
            return GasSensor.objects.select_related("house", "house__user").all()
        return GasSensor.objects.filter(house__user=self.request.user)


class AlertListView(generics.ListAPIView):
    serializer_class = AlertSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if self.request.user.is_admin or self.request.user.is_superuser or self.request.user.is_staff:
            return Alert.objects.select_related("user", "sensor", "sensor__house").order_by("-triggered_at")
        return Alert.objects.filter(user=self.request.user).order_by("-triggered_at")


class ProfileImageView(APIView):
    parser_classes = [MultiPartParser, FormParser]
    permission_classes = [permissions.IsAuthenticated]

    def put(self, request):
        user = request.user
        if "profile_image" not in request.data:
            return Response(
                {"error": "No image provided"}, status=status.HTTP_400_BAD_REQUEST
            )

        # Delete old image if exists
        if user.profile_image:
            default_storage.delete(user.profile_image.path)

        user.profile_image = request.data["profile_image"]
        user.save()
        return Response(UserProfileSerializer(user).data, status=status.HTTP_200_OK)

    def delete(self, request):
        user = request.user
        if user.profile_image:
            # Delete the file from storage
            default_storage.delete(user.profile_image.path)
            # Clear the field
            user.profile_image = None
            user.save()
            return Response(
                {"message": "Profile image removed successfully"},
                status=status.HTTP_200_OK,
            )
        return Response(
            {"error": "No profile image to remove"}, status=status.HTTP_400_BAD_REQUEST
        )


# user managment
class UserListView(generics.ListAPIView):
    serializer_class = UserManagementSerializer
    permission_classes = [IsSystemAdmin]

    def get_queryset(self):
        return User.objects.all().order_by("-created_at")


class UserDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = UserManagementSerializer
    permission_classes = [IsSystemAdmin]
    queryset = User.objects.all()
    lookup_field = "id"


class UserInviteView(generics.CreateAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsSystemAdmin]

    def perform_create(self, serializer):
        user = serializer.save(is_active=False)  # Create inactive user
        # Here you would typically send an invitation email
        # with an activation link
        return user


class UserStatusUpdateView(APIView):
    permission_classes = [IsSystemAdmin]

    def patch(self, request, id):
        try:
            user = User.objects.get(id=id)
            is_active = request.data.get("is_active", None)

            if is_active is not None:
                user.is_active = is_active
                user.save()
                return Response(
                    {
                        "message": f'User {"activated" if is_active else "suspended"} successfully'
                    },
                    status=status.HTTP_200_OK,
                )
            return Response(
                {"error": "is_active field is required"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        except User.DoesNotExist:
            return Response(
                {"error": "User not found"}, status=status.HTTP_404_NOT_FOUND
            )


class AdminOverviewView(APIView):
    permission_classes = [IsSystemAdmin]

    def get(self, request):
        users = User.objects.all()
        vendors = VendorProfile.objects.all()
        delivery_profiles = DeliveryPersonProfile.objects.all()
        sensors = GasSensor.objects.all()
        deliveries = Delivery.objects.all()
        today = timezone.localdate()
        return Response({
            "generated_at": timezone.now(),
            "users": {
                "total": users.count(),
                "clients": users.filter(is_admin=False, is_superuser=False, is_delivery_person=False)
                    .exclude(id__in=vendors.values("user_id")).count(),
                "delivery_people": delivery_profiles.count(),
                "suppliers": vendors.count(),
                "active": users.filter(is_active=True).count(),
            },
            "applications": {
                "delivery_pending": delivery_profiles.filter(application_status="PENDING").count(),
                "supplier_pending": vendors.filter(application_status="PENDING").count(),
                "rejected": delivery_profiles.filter(application_status="REJECTED").count()
                    + vendors.filter(application_status="REJECTED").count(),
            },
            "sensors": {
                "total": sensors.count(),
                "active": sensors.filter(is_active=True).count(),
                "inactive": sensors.filter(is_active=False).count(),
                "readings": GasReading.objects.count(),
            },
            "alerts": {
                "total": Alert.objects.count(),
                "unresolved": Alert.objects.filter(is_resolved=False).count(),
                "critical": Alert.objects.filter(is_resolved=False, severity_level="CRITICAL").count(),
            },
            "orders": {
                "total": deliveries.count(),
                "today": deliveries.filter(created_at__date=today).count(),
                "pending": deliveries.filter(status="PENDING").count(),
                "in_progress": deliveries.filter(status__in=("ASSIGNED", "OUT_FOR_DELIVERY", "READY_FOR_PICKUP")).count(),
                "completed": deliveries.filter(status__in=("DELIVERED", "PICKED_UP")).count(),
                "pickup": deliveries.filter(fulfillment_method="PICKUP").count(),
                "delivery": deliveries.filter(fulfillment_method="DELIVERY").count(),
            },
            "recent_alerts": AlertSerializer(
                Alert.objects.select_related("user", "sensor", "sensor__house")[:8],
                many=True,
                context={"request": request},
            ).data,
        })


class AdminReportView(APIView):
    permission_classes = [IsSystemAdmin]

    def get(self, request):
        report_type = request.query_params.get("type", "orders")
        response = HttpResponse(content_type="text/csv; charset=utf-8")
        response["Content-Disposition"] = f'attachment; filename="gasx-{report_type}-report.csv"'
        writer = csv.writer(response)

        if report_type == "users":
            writer.writerow(["id", "email", "first_name", "last_name", "role", "active", "created_at"])
            for user in User.objects.order_by("-created_at").iterator():
                role = "admin" if user.is_admin or user.is_superuser else (
                    "delivery_person" if user.is_delivery_person else (
                        "gas_supplier" if hasattr(user, "vendor_profile") else "client"
                    )
                )
                writer.writerow([user.id, user.email, user.first_name, user.last_name, role, user.is_active, user.created_at.isoformat()])
        elif report_type == "sensors":
            writer.writerow(["id", "serial_number", "sensor_name", "owner_email", "active", "raw_weight_kg", "created_at"])
            for sensor in GasSensor.objects.select_related("house", "house__user").order_by("id").iterator():
                writer.writerow([sensor.id, sensor.serial_number, sensor.sensor_name, sensor.house.user.email, sensor.is_active, sensor.raw_weight, sensor.created_at.isoformat()])
        elif report_type == "suppliers":
            writer.writerow(["id", "store_name", "owner_email", "address", "status", "approved", "created_at"])
            for vendor in VendorProfile.objects.select_related("user").order_by("-created_at").iterator():
                writer.writerow([vendor.id, vendor.store_name, vendor.user.email, vendor.address, vendor.application_status, vendor.is_approved, vendor.created_at.isoformat()])
        else:
            writer.writerow(["id", "client_email", "supplier", "bottle", "fulfillment", "status", "unit_price", "created_at"])
            for order in Delivery.objects.select_related("client", "vendor", "gas_bottle").order_by("-created_at").iterator():
                writer.writerow([order.id, order.client.email, order.vendor.store_name, order.gas_bottle, order.fulfillment_method, order.status, order.unit_price, order.created_at.isoformat()])
        return response


class AdminDeliveryApplicationListView(generics.ListAPIView):
    permission_classes = [IsSystemAdmin]
    serializer_class = DeliveryPersonProfileSerializer

    def get_queryset(self):
        queryset = DeliveryPersonProfile.objects.select_related("user", "reviewed_by")
        status_filter = self.request.query_params.get("status")
        if status_filter and status_filter.upper() in {"PENDING", "APPROVED", "REJECTED"}:
            queryset = queryset.filter(application_status=status_filter.upper())
        return queryset.order_by("-created_at")


class AdminDeliveryApplicationUpdateView(APIView):
    permission_classes = [IsSystemAdmin]

    def patch(self, request, pk):
        try:
            profile = DeliveryPersonProfile.objects.select_related("user").get(pk=pk)
        except DeliveryPersonProfile.DoesNotExist:
            return Response({"error": "Delivery application not found."}, status=status.HTTP_404_NOT_FOUND)
        decision = str(request.data.get("decision", "")).upper()
        if decision not in {"APPROVED", "REJECTED"}:
            return Response({"error": "decision must be APPROVED or REJECTED."}, status=status.HTTP_400_BAD_REQUEST)
        reason = str(request.data.get("rejection_reason", "")).strip()
        if decision == "REJECTED" and not reason:
            return Response({"error": "Provide a reason when rejecting an application."}, status=status.HTTP_400_BAD_REQUEST)
        profile.application_status = decision
        profile.rejection_reason = reason if decision == "REJECTED" else ""
        profile.reviewed_by = request.user
        profile.reviewed_at = timezone.now()
        profile.save(update_fields=["application_status", "rejection_reason", "reviewed_by", "reviewed_at", "updated_at"])
        return Response(DeliveryPersonProfileSerializer(profile).data)


class VerificationDocumentView(APIView):
    permission_classes = [IsSystemAdmin]
    VENDOR_DOCUMENTS = {"identity_card", "birth_certificate", "institution_document", "tax_payment_document", "additional_document"}
    DELIVERY_DOCUMENTS = {"identity_card", "supporting_document"}

    def get(self, request, applicant_type, pk, document_name):
        if applicant_type == "supplier" and document_name in self.VENDOR_DOCUMENTS:
            profile = VendorProfile.objects.filter(pk=pk).first()
        elif applicant_type == "delivery" and document_name in self.DELIVERY_DOCUMENTS:
            profile = DeliveryPersonProfile.objects.filter(pk=pk).first()
        else:
            return Response({"error": "Unknown verification document."}, status=status.HTTP_404_NOT_FOUND)
        document = getattr(profile, document_name, None) if profile else None
        if not document:
            return Response({"error": "Document not found."}, status=status.HTTP_404_NOT_FOUND)
        stream = default_storage.open(document.name, "rb")
        response = FileResponse(stream, as_attachment=True, filename=document.name.rsplit("/", 1)[-1])
        response["Cache-Control"] = "private, no-store"
        response["X-Content-Type-Options"] = "nosniff"
        return response


class NotificationListView(generics.ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Get all notifications for the current user
        return (
            Notification.objects.filter(alert__user=self.request.user)
            .select_related("alert", "alert__sensor", "alert__sensor__house")
            .order_by("-sent_at")
        )


class MarkNotificationAsReadView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, notification_id):
        try:
            notification = Notification.objects.get(
                id=notification_id, alert__user=request.user
            )
            # Mark the alert as resolved
            alert = notification.alert
            if not alert.is_resolved:
                alert.is_resolved = True
                alert.resolved_at = timezone.now()
                alert.resolved_by = request.user
                alert.save()
                
                # Broadcast alert update via WebSocket
                from channels.layers import get_channel_layer
                from asgiref.sync import async_to_sync
                channel_layer = get_channel_layer()
                if channel_layer:
                    async_to_sync(channel_layer.group_send)(
                        f"user_{request.user.id}",
                        {
                            "type": "send_alert",
                        }
                    )
            
            return Response(
                NotificationSerializer(notification).data, status=status.HTTP_200_OK
            )
        except Notification.DoesNotExist:
            return Response(
                {"error": "Notification not found"}, status=status.HTTP_404_NOT_FOUND
            )


class NotificationSettingsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        # Return the current user's notification settings
        user = request.user
        settings = {
            "email_enabled": True,  # Default values - replace with actual user settings
            "push_enabled": True,
            "sms_enabled": False,
            "critical_alerts": "all",
            "warning_alerts": "all",
            "info_alerts": "important",
            "quiet_start": 22,
            "quiet_end": 6,
        }
        return Response(settings, status=status.HTTP_200_OK)

    def post(self, request):
        # Update the user's notification settings
        # In a real app, you would save these to the user's profile
        # For now, we'll just return the received settings
        return Response(request.data, status=status.HTTP_200_OK)


class GasPredictionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        try:
            # Get the user's primary sensor (or first sensor if multiple)
            sensor = GasSensor.objects.filter(house__user=request.user).first()
            if not sensor:
                return Response(
                    {"error": "No gas sensor found for this user"},
                    status=status.HTTP_404_NOT_FOUND,
                )

            # Fetch the most recent readings (unlimited time window, up to 100 points) 
            # to ensure we have data even if the last reading was long ago.
            readings = GasReading.objects.filter(
                sensor=sensor
            ).order_by("-reading_timestamp")[:100]

            if not readings.exists():
                return Response(
                    {
                        "status_code": 200,
                        "message": "Collecting initial data",
                        "projected_days": 0,
                        "confidence": 0,
                        "trend": "collecting",
                        "recommendation": "Please wait for more readings to be recorded for a precise prediction.",
                        "calculation": "No historical readings found in the last 30 days",
                        "history_data": []
                    },
                    status=status.HTTP_200_OK,
                )

            # Prepare history data for AI prediction
            history_data = []
            previous_reading = None

            # Group readings by hour to reduce noise and get meaningful consumption patterns
            hourly_readings = {}
            for reading in readings:
                hour_key = reading.reading_timestamp.replace(minute=0, second=0, microsecond=0)
                if hour_key not in hourly_readings or reading.reading_timestamp > hourly_readings[hour_key].reading_timestamp:
                    hourly_readings[hour_key] = reading
            
            # Sort hourly readings by timestamp
            sorted_hourly = sorted(hourly_readings.values(), key=lambda x: x.reading_timestamp)
            
            # Calculate consumption between hourly readings (minimum 1 hour intervals)
            previous_reading = None
            for reading in sorted_hourly:
                if previous_reading:
                    time_diff = (
                        reading.reading_timestamp - previous_reading.reading_timestamp
                    ).total_seconds() / 86400  # days
                    
                    # Only process if time difference is at least 1 hour (0.042 days) to avoid noise
                    if time_diff >= 0.042:  # 1 hour = 0.042 days
                        consumption = float(previous_reading.remaining_gas) - float(
                            reading.remaining_gas
                        )
                        
                        # Filter out unrealistic consumption values (more than 5kg per day)
                        daily_consumption = consumption / time_diff
                        if -5.0 <= daily_consumption <= 5.0:  # Realistic range for gas consumption
                            is_weekend = (
                                reading.reading_timestamp.weekday() >= 5
                            )  # Saturday or Sunday

                            history_data.append(
                                {
                                    "date": reading.reading_timestamp.date().isoformat(),
                                    "consumption_kg": daily_consumption,  # kg per day
                                    "is_weekend": is_weekend,
                                }
                            )

                previous_reading = reading

            if not history_data:
                return Response(
                    {
                        "status_code": 200,
                        "message": "Insufficient data for trend analysis",
                        "projected_days": 0,
                        "confidence": 0,
                        "trend": "collecting",
                        "recommendation": "Analyzing consumption patterns... more data needed for high-confidence prediction.",
                        "calculation": "Insufficient consumption events (minimum 2 distinct time periods required)",
                        "history_data": []
                    },
                    status=status.HTTP_200_OK,
                )

            # Get current remaining gas from latest reading
            latest_reading = (
                readings.first()
            )  # readings are now correctly ordered by -reading_timestamp (latest first)
            current_remaining_kg = (
                float(latest_reading.remaining_gas) if latest_reading else 1.0
            )

            # Get prediction from AI service with dynamic bottle capacity
            prediction = AIPredictionService.predict_days_remaining(
                history_data, 
                current_remaining_kg,
                bottle_capacity=user_bottle_capacity_kg(sensor.house.user)
            )

            # Format response
            response_data = {
                "status_code": 200,
                "message": "Prediction successful",
                "projected_days": prediction.get("projected_days", 0),
                "confidence": prediction.get("confidence", 0),
                "trend": prediction.get("trend", "stable"),
                "recommendation": prediction.get(
                    "recommendation", "No specific recommendation"
                ),
                "calculation": prediction.get("calculation", "No calculation details"),
                "history_data": history_data,
            }

            return Response(response_data, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {"error": str(e), "details": "Failed to generate prediction"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class GasReadingListView(generics.ListAPIView):
    serializer_class = GasReadingSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = GasReading.objects.select_related("sensor", "sensor__house", "sensor__house__user")
        if not (self.request.user.is_admin or self.request.user.is_superuser or self.request.user.is_staff):
            queryset = queryset.filter(sensor__house__user=self.request.user)

        # Handle date filtering if provided
        start_date = self.request.query_params.get("start_date")
        end_date = self.request.query_params.get("end_date")

        if start_date:
            queryset = queryset.filter(reading_timestamp__gte=start_date)
        if end_date:
            queryset = queryset.filter(reading_timestamp__lte=end_date)

        # Default to last 7 days if no dates provided
        if not start_date and not end_date:
            default_start = timezone.now() - timedelta(days=7)
            queryset = queryset.filter(reading_timestamp__gte=default_start)

        return queryset.order_by("-reading_timestamp")


class DailyGasConsumptionView(APIView):
    """
    API endpoint to get daily aggregated gas consumption data for dashboard charts.
    Groups readings by day and calculates total consumption per day.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            # Get the user's primary sensor
            sensor = GasSensor.objects.filter(house__user=request.user).first()
            if not sensor:
                return Response(
                    {"error": "No gas sensor found for this user"},
                    status=status.HTTP_404_NOT_FOUND,
                )

            # Get date range parameters (default to last 30 days)
            end_date = timezone.now().date()
            start_date = end_date - timedelta(days=30)
            
            # Override with query parameters if provided
            if request.query_params.get('start_date'):
                start_date = datetime.strptime(request.query_params.get('start_date'), '%Y-%m-%d').date()
            if request.query_params.get('end_date'):
                end_date = datetime.strptime(request.query_params.get('end_date'), '%Y-%m-%d').date()

            # Get readings for the date range
            readings = GasReading.objects.filter(
                sensor=sensor,
                reading_timestamp__date__gte=start_date,
                reading_timestamp__date__lte=end_date
            ).order_by('reading_timestamp')

            if not readings.exists():
                return Response(
                    {"message": "No gas readings found for the specified date range", "data": []},
                    status=status.HTTP_200_OK,
                )

            # Group readings by date and calculate daily consumption
            daily_data = {}
            previous_reading = None

            for reading in readings:
                date_key = reading.reading_timestamp.date()
                
                # Initialize date entry if not exists
                if date_key not in daily_data:
                    daily_data[date_key] = {
                        'date': date_key.isoformat(),
                        'consumption_kg': 0.0,
                        'avg_remaining_kg': 0.0,
                        'reading_count': 0,
                        'min_remaining': float('inf'),
                        'max_remaining': 0.0,
                        'readings': []
                    }

                # Add reading data
                remaining_gas = float(reading.remaining_gas)
                daily_data[date_key]['readings'].append(remaining_gas)
                daily_data[date_key]['reading_count'] += 1
                daily_data[date_key]['min_remaining'] = min(daily_data[date_key]['min_remaining'], remaining_gas)
                daily_data[date_key]['max_remaining'] = max(daily_data[date_key]['max_remaining'], remaining_gas)

                # Calculate consumption from previous reading (if same day or previous day)
                if previous_reading:
                    prev_date = previous_reading.reading_timestamp.date()
                    time_diff_hours = (reading.reading_timestamp - previous_reading.reading_timestamp).total_seconds() / 3600
                    
                    # Only calculate consumption if readings are within reasonable time (max 24 hours apart)
                    # and not more than 48 hours ago to avoid stale data
                    if 0 < time_diff_hours <= 24:
                        prev_gas = float(previous_reading.remaining_gas)
                        curr_gas = remaining_gas
                        
                        # Consumption = previous - current (positive means gas was used)
                        consumption = prev_gas - curr_gas
                        
                        # Only add realistic positive consumption (0.01kg to 5kg per reading)
                        # This filters out sensor errors and unrealistic jumps
                        if 0.01 <= consumption <= 5.0:
                            daily_data[date_key]['consumption_kg'] += consumption
                        elif consumption < 0:
                            # Log negative consumption for debugging (tank refill or sensor error)
                            print(f"Warning: Negative consumption detected: {consumption:.2f}kg on {date_key}")

                previous_reading = reading

            # Calculate averages and prepare final data
            chart_data = []
            for date_key in sorted(daily_data.keys()):
                day_data = daily_data[date_key]
                readings = day_data['readings']
                
                # Calculate average remaining gas for the day
                avg_remaining = sum(readings) / len(readings) if readings else 0
                
                chart_data.append({
                    'date': day_data['date'],
                    'consumption_kg': round(day_data['consumption_kg'], 2),
                    'avg_remaining_kg': round(avg_remaining, 2),
                    'min_remaining_kg': round(day_data['min_remaining'] if day_data['min_remaining'] != float('inf') else 0, 2),
                    'max_remaining_kg': round(day_data['max_remaining'], 2),
                    'reading_count': day_data['reading_count'],
                    'gas_percentage': round(
                        min(100.0, max(0.0, (avg_remaining / max(float(user_bottle_capacity_kg(request.user)), 0.1)) * 100)),
                        1,
                    )
                })

            return Response({
                'status_code': 200,
                'message': 'Daily consumption data retrieved successfully',
                'data': chart_data,
                'date_range': {
                    'start_date': start_date.isoformat(),
                    'end_date': end_date.isoformat()
                },
                'total_days': len(chart_data)
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {"error": str(e), "details": "Failed to retrieve daily consumption data"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class GasReadingCreateView(generics.CreateAPIView):
    serializer_class = GasReadingSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        sensor = serializer.validated_data["sensor"]
        user = sensor.house.user
        raw_weight = serializer.validated_data.get('raw_weight')
        capacity = user_bottle_capacity_kg(user)
        calculated_gas = max(Decimal("0.00"), raw_weight - user.tare_weight)
        remaining_gas = min(capacity, calculated_gas)

        # The device submits gross bottle weight only. Net LPG is derived here.
        gas_reading = serializer.save(remaining_gas=remaining_gas, raw_weight=raw_weight)

        # Also update sensor's raw_weight
        sensor = gas_reading.sensor
        if raw_weight is not None:
            sensor.raw_weight = raw_weight
            sensor.save(update_fields=['raw_weight', 'updated_at'])

        # Check if gas level is at or below critical thresholds
        remaining_gas_val = float(gas_reading.remaining_gas)

        # Calculate percentage based on user's dynamic tank capacity
        TANK_CAPACITY = max(float(capacity), 0.1)
        
        gas_percentage = (remaining_gas_val / TANK_CAPACITY) * 100

        # Alert thresholds: 20% (low), 10% (critical)
        LOW_THRESHOLD = 20.0
        CRITICAL_THRESHOLD = 10.0

        alert_created = False
        if gas_percentage <= LOW_THRESHOLD:
            gas_reading.is_alert_triggered = True
            gas_reading.save()

            existing_alert = Alert.objects.filter(
                sensor=sensor, alert_type="GAS_LEVEL_LOW", is_resolved=False
            ).first()

            if not existing_alert:
                if gas_percentage <= CRITICAL_THRESHOLD:
                    severity = "CRITICAL"
                elif gas_percentage <= 15:
                    severity = "HIGH"
                else:
                    severity = "MEDIUM"

                address = sensor.house.address_line_1 if sensor.house else "Unknown Location"
                time_str = timezone.now().strftime('%d %b %Y, %H:%M:%S')
                alert = Alert.objects.create(
                    user=user,
                    sensor=sensor,
                    alert_type="GAS_LEVEL_LOW",
                    severity_level=severity,
                    alert_message=f"Gas level is low ({gas_percentage:.1f}%) on sensor '{sensor.sensor_name}' at {address} — {time_str}.",
                    is_resolved=False,
                )
                
                # Create a database notification record as well
                Notification.objects.create(
                    alert=alert,
                    notification_method="PUSH",
                    recipient_address=user.email,
                    notification_status="SENT"
                )
                alert_created = True

        # Broadcast gas reading update to user group
        from channels.layers import get_channel_layer
        from asgiref.sync import async_to_sync
        channel_layer = get_channel_layer()
        if channel_layer:
            async_to_sync(channel_layer.group_send)(
                f"user_{user.id}",
                {
                    "type": "send_gas_reading",
                }
            )
            # If an alert was created, also broadcast alert update
            if alert_created:
                async_to_sync(channel_layer.group_send)(
                    f"user_{user.id}",
                    {
                        "type": "send_alert",
                    }
                )

        return gas_reading

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        gas_reading = self.perform_create(serializer)
        sensor = gas_reading.sensor
        
        # Include current remote commands in response so ESP32 can act immediately
        headers = self.get_success_headers(serializer.data)
        response_data = serializer.data
        response_data['valve_command'] = (
            sensor.desired_valve_state
            if sensor.desired_valve_state != sensor.current_valve_state
            else "NONE"
        )
        response_data['alarm_command'] = sensor.desired_alarm_state
        return Response(response_data, status=status.HTTP_201_CREATED, headers=headers)


class SensorValveControlView(APIView):
    """
    API endpoint to remotely open or close the gas valve.
    POST payload: {"command": "OPEN"} or {"command": "CLOSE"}
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        try:
            sensor = GasSensor.objects.get(pk=pk, house__user=request.user)
            command = request.data.get("command", "").upper()
            if command not in ["OPEN", "CLOSE"]:
                return Response(
                    {"error": "Invalid command. Must be 'OPEN' or 'CLOSE'."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if command == "OPEN" and Alert.objects.filter(
                sensor=sensor, alert_type="GAS_LEAK", is_resolved=False
            ).exists():
                return Response(
                    {"error": "Resolve the active gas leak alert before opening the valve."},
                    status=status.HTTP_409_CONFLICT,
                )
            
            sensor.desired_valve_state = command
            sensor.save(update_fields=["desired_valve_state"])

            # Broadcast update via Channels
            from channels.layers import get_channel_layer
            from asgiref.sync import async_to_sync
            channel_layer = get_channel_layer()
            if channel_layer:
                async_to_sync(channel_layer.group_send)(
                    f"user_{request.user.id}",
                    {"type": "send_gas_reading"}
                )

            return Response({
                "status": "success",
                "message": f"Gas valve command set to {command}",
                "desired_valve_state": sensor.desired_valve_state,
                "current_valve_state": sensor.current_valve_state,
            }, status=status.HTTP_200_OK)

        except GasSensor.DoesNotExist:
            return Response({"error": "Sensor not found"}, status=status.HTTP_404_NOT_FOUND)


class SensorAlarmControlView(APIView):
    """
    API endpoint to remotely silence or arm the alarm buzzer.
    POST payload: {"command": "SILENCE"} or {"command": "ARM"}
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        try:
            sensor = GasSensor.objects.get(pk=pk, house__user=request.user)
            command = request.data.get("command", "").upper()
            if command not in ["SILENCE", "ARM"]:
                return Response(
                    {"error": "Invalid command. Must be 'SILENCE' or 'ARM'."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            
            sensor.desired_alarm_state = command
            sensor.is_alarm_silenced = (command == "SILENCE")
            sensor.save(update_fields=["desired_alarm_state", "is_alarm_silenced"])

            # Broadcast update via Channels
            from channels.layers import get_channel_layer
            from asgiref.sync import async_to_sync
            channel_layer = get_channel_layer()
            if channel_layer:
                async_to_sync(channel_layer.group_send)(
                    f"user_{request.user.id}",
                    {"type": "send_gas_reading"}
                )

            return Response({
                "status": "success",
                "message": f"Alarm command set to {command}",
                "desired_alarm_state": sensor.desired_alarm_state,
                "is_alarm_silenced": sensor.is_alarm_silenced,
            }, status=status.HTTP_200_OK)

        except GasSensor.DoesNotExist:
            return Response({"error": "Sensor not found"}, status=status.HTTP_404_NOT_FOUND)


class SensorDeviceCommandView(APIView):
    """
    API endpoint for ESP32 microcontroller to poll current desired commands.
    GET /api/sensors/<pk>/device-command/
    Returns: {"valve_command": "OPEN"|"CLOSE", "alarm_command": "SILENCE"|"ARM"}
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        try:
            sensor = GasSensor.objects.get(pk=pk, house__user=request.user)
            # Update current state if reported by query params
            reported_valve = request.query_params.get("current_valve")
            changed_fields = []
            if reported_valve and reported_valve.upper() in ["OPEN", "CLOSE"]:
                reported_valve = reported_valve.upper()
                local_override = request.query_params.get("local_override") == "1"
                if sensor.current_valve_state != reported_valve:
                    sensor.current_valve_state = reported_valve
                    changed_fields.append("current_valve_state")
                if local_override and sensor.desired_valve_state != reported_valve:
                    sensor.desired_valve_state = reported_valve
                    changed_fields.append("desired_valve_state")

            # Keep stale OPEN commands from overriding an unresolved leak.
            active_leak = Alert.objects.filter(
                sensor=sensor, alert_type="GAS_LEAK", is_resolved=False
            ).exists()
            if active_leak and sensor.desired_valve_state != "CLOSE":
                sensor.desired_valve_state = "CLOSE"
                changed_fields.append("desired_valve_state")

            if changed_fields:
                sensor.save(update_fields=list(dict.fromkeys(changed_fields)))
                from channels.layers import get_channel_layer
                from asgiref.sync import async_to_sync

                channel_layer = get_channel_layer()
                if channel_layer:
                    async_to_sync(channel_layer.group_send)(
                        f"user_{request.user.id}",
                        {"type": "send_gas_reading"},
                    )

            # Send valve commands only until the device reports the target state.
            # This prevents old CLOSE commands from undoing a newer local toggle.
            valve_command = (
                sensor.desired_valve_state
                if sensor.desired_valve_state != sensor.current_valve_state
                else "NONE"
            )
            return Response({
                "sensor_id": sensor.id,
                "valve_command": valve_command,
                "desired_valve_state": sensor.desired_valve_state,
                "current_valve_state": sensor.current_valve_state,
                "alarm_command": sensor.desired_alarm_state,
                "is_alarm_silenced": sensor.is_alarm_silenced,
            }, status=status.HTTP_200_OK)
        except GasSensor.DoesNotExist:
            return Response({"error": "Sensor not found"}, status=status.HTTP_404_NOT_FOUND)


class GasLeakAlertCreateView(APIView):
    """
    API endpoint for ESP32 to send gas leak alerts.
    Creates alerts with alert_type='GAS_LEAK' in the Alert table.
    """

    permission_classes = [IsAuthenticated]

    def post(self, request):
        """
        Handle ESP32 gas leak alert creation.

        Expected payload:
        {
            "sensor_id": 123,
            "severity_level": "CRITICAL",
            "alert_message": "Gas leak detected in kitchen area",  # optional
            "gas_concentration": 1500.0,  # optional, in ppm
            "location_details": "Kitchen area near stove"  # optional
        }
        """
        serializer = GasLeakAlertSerializer(data=request.data)

        if serializer.is_valid():
            try:
                sensor = GasSensor.objects.get(
                    id=serializer.validated_data["sensor_id"],
                    is_active=True,
                    house__user=request.user,
                )
                # A detected leak always becomes a pending close command too.
                fields_to_update = []
                if sensor.desired_valve_state != "CLOSE":
                    sensor.desired_valve_state = "CLOSE"
                    fields_to_update.append("desired_valve_state")
                # A leak alert must leave the device alarm armed, even if a
                # previous remote command had silenced it.
                if sensor.desired_alarm_state != "ARM":
                    sensor.desired_alarm_state = "ARM"
                    fields_to_update.append("desired_alarm_state")
                if sensor.is_alarm_silenced:
                    sensor.is_alarm_silenced = False
                    fields_to_update.append("is_alarm_silenced")
                if fields_to_update:
                    sensor.save(update_fields=[*fields_to_update, "updated_at"])

                # Create the alert using the serializer's method
                alert = serializer.create_alert(serializer.validated_data)

                # Send email notification to the user
                email_sent = False
                email_error = None
                try:
                    success, result = email_service.send_gas_leak_alert_email(
                        alert.user, alert
                    )
                    email_sent = success
                    if not success:
                        email_error = result
                        logging.warning(
                            f"Failed to send gas leak alert email: {result}"
                        )
                except Exception as e:
                    email_error = str(e)
                    logging.error(
                        f"Exception while sending gas leak alert email: {str(e)}"
                    )

                # Create notification record for frontend display
                from .models import Notification

                try:
                    if not Notification.objects.filter(alert=alert).exists():
                        notification = Notification.objects.create(
                            alert=alert,
                            notification_method="EMAIL",
                            recipient_address=alert.user.email,
                            notification_status="SENT" if email_sent else "FAILED",
                            error_message=email_error if email_error else None,
                        )
                        logging.info(
                            f"Created notification record {notification.id} for gas leak alert {alert.id}"
                        )
                except Exception as e:
                    logging.error(f"Failed to create notification record: {str(e)}")

                # Broadcast alert update via WebSocket
                from channels.layers import get_channel_layer
                from asgiref.sync import async_to_sync
                channel_layer = get_channel_layer()
                if channel_layer:
                    async_to_sync(channel_layer.group_send)(
                        f"user_{alert.user.id}",
                        {"type": "send_gas_reading"},
                    )
                    async_to_sync(channel_layer.group_send)(
                        f"user_{alert.user.id}",
                        {
                            "type": "send_alert",
                        }
                    )

                # Return success response with alert details
                response_data = {
                    "status": "success",
                    "message": "Gas leak alert created successfully",
                    "alert": {
                        "id": alert.id,
                        "alert_type": alert.alert_type,
                        "severity_level": alert.severity_level,
                        "alert_message": alert.alert_message,
                        "sensor_id": alert.sensor.id,
                        "sensor_name": alert.sensor.sensor_name,
                        "triggered_at": alert.triggered_at.isoformat(),
                        "is_resolved": alert.is_resolved,
                    },
                    "email_notification": {
                        "sent": email_sent,
                        "error": email_error if email_error else None,
                    },
                }

                return Response(response_data, status=status.HTTP_201_CREATED)

            except GasSensor.DoesNotExist:
                return Response(
                    {"error": "Active sensor does not belong to this account."},
                    status=status.HTTP_403_FORBIDDEN,
                )
            except Exception as e:
                return Response(
                    {
                        "status": "error",
                        "message": "Failed to create gas leak alert",
                        "error": str(e),
                    },
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

        return Response(
            {
                "status": "error",
                "message": "Invalid data provided",
                "errors": serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST,
        )


class BulkDeleteGasReadingsView(APIView):
    """
    API endpoint to bulk delete gas readings for cleanup purposes.
    Supports deleting all readings or filtering by sensor ID.
    """
    permission_classes = [IsAuthenticated]

    def delete(self, request):
        try:
            # Get optional sensor filter from query params
            sensor_id = request.query_params.get('sensor')
            
            # Build queryset
            queryset = GasReading.objects.all()
            
            if sensor_id:
                try:
                    sensor_id = int(sensor_id)
                    queryset = queryset.filter(sensor_id=sensor_id)
                except ValueError:
                    return Response(
                        {
                            "status": "error",
                            "message": "Invalid sensor ID provided"
                        },
                        status=status.HTTP_400_BAD_REQUEST
                    )
            
            # Count readings before deletion
            total_count = queryset.count()
            
            if total_count == 0:
                return Response(
                    {
                        "status": "success",
                        "message": "No gas readings found to delete",
                        "deleted_count": 0
                    },
                    status=status.HTTP_200_OK
                )
            
            # Perform bulk deletion
            deleted_count, _ = queryset.delete()
            
            # Prepare response message
            if sensor_id:
                message = f"Successfully deleted all gas readings for sensor {sensor_id}"
            else:
                message = "Successfully deleted all gas readings"
            
            return Response(
                {
                    "status": "success",
                    "message": message,
                    "deleted_count": deleted_count
                },
                status=status.HTTP_200_OK
            )
            
        except Exception as e:
            return Response(
                {
                    "status": "error",
                    "message": "Failed to delete gas readings",
                    "error": str(e)
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class CookableFoodListView(generics.ListAPIView):
    serializer_class = CookableFoodSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        sensor_id = self.kwargs.get("sensor_id")
        try:
            # Ensure the sensor belongs to the user
            sensor = GasSensor.objects.get(id=sensor_id, house__user=self.request.user)
            current_gas = sensor.current_gas_level
            return CookableFood.objects.filter(estimated_gas_required__lte=current_gas).order_by("estimated_gas_required")
        except GasSensor.DoesNotExist:
            return CookableFood.objects.none()


class DeliveryPersonProfileView(generics.RetrieveUpdateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = DeliveryPersonProfileSerializer
    parser_classes = [MultiPartParser, FormParser]

    def get_object(self):
        return DeliveryPersonProfile.objects.get(user=self.request.user)


class VendorRegistrationView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        if hasattr(request.user, "vendor_profile"):
            return Response({"error": "User already has a vendor profile"}, status=status.HTTP_400_BAD_REQUEST)

        required_documents = ("identity_card", "tax_payment_document", "additional_document")
        missing = [name for name in required_documents if not request.FILES.get(name)]
        if missing:
            return Response({name: "This document is required." for name in missing}, status=status.HTTP_400_BAD_REQUEST)
        
        serializer = VendorProfileSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class VendorProfileDetailView(generics.RetrieveUpdateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = VendorProfileSerializer
    parser_classes = [MultiPartParser, FormParser]

    def get_object(self):
        try:
            return self.request.user.vendor_profile
        except VendorProfile.DoesNotExist:
            return None

    def get(self, request, *args, **kwargs):
        profile = self.get_object()
        if not profile:
            return Response({"error": "Vendor profile not found"}, status=status.HTTP_404_NOT_FOUND)
        serializer = self.get_serializer(profile)
        return Response(serializer.data)


class VendorGasBottleListCreateView(generics.ListCreateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = GasBottleSerializer

    def get_queryset(self):
        if self._approved_vendor():
            return GasBottle.objects.filter(vendor=self.request.user.vendor_profile)
        return GasBottle.objects.none()

    def _approved_vendor(self):
        return (
            hasattr(self.request.user, "vendor_profile")
            and self.request.user.vendor_profile.application_status == "APPROVED"
            and self.request.user.vendor_profile.is_approved
        )

    def perform_create(self, serializer):
        if self._approved_vendor():
            serializer.save(vendor=self.request.user.vendor_profile)
            return
        raise PermissionDenied("Supplier inventory is available after administrator approval.")


class VendorGasBottleDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = GasBottleSerializer
    lookup_field = "pk"

    def get_queryset(self):
        if (
            hasattr(self.request.user, "vendor_profile")
            and self.request.user.vendor_profile.application_status == "APPROVED"
            and self.request.user.vendor_profile.is_approved
        ):
            return GasBottle.objects.filter(vendor=self.request.user.vendor_profile)
        return GasBottle.objects.none()


class AdminVendorValidationListView(generics.ListAPIView):
    permission_classes = [IsSystemAdmin]
    serializer_class = VendorProfileSerializer

    def get_queryset(self):
        status_filter = self.request.query_params.get("status")
        if status_filter == "pending":
            return VendorProfile.objects.filter(application_status="PENDING").select_related("user").order_by("-created_at")
        return VendorProfile.objects.select_related("user").order_by("-created_at")


class AdminVendorValidationUpdateView(APIView):
    permission_classes = [IsSystemAdmin]

    def patch(self, request, pk):
        try:
            vendor = VendorProfile.objects.get(pk=pk)
            decision = request.data.get("decision")
            if decision is None and "is_approved" in request.data:
                decision = "APPROVED" if request.data["is_approved"] else "REJECTED"
            decision = str(decision or "").upper()
            if decision not in {"APPROVED", "REJECTED"}:
                return Response({"error": "decision must be APPROVED or REJECTED."}, status=status.HTTP_400_BAD_REQUEST)
            reason = str(request.data.get("rejection_reason", "")).strip()
            if decision == "REJECTED" and not reason:
                return Response({"error": "Provide a reason when rejecting an application."}, status=status.HTTP_400_BAD_REQUEST)
            vendor.application_status = decision
            vendor.is_approved = decision == "APPROVED"
            vendor.rejection_reason = reason if decision == "REJECTED" else ""
            vendor.reviewed_by = request.user
            vendor.reviewed_at = timezone.now()
            vendor.save(update_fields=["application_status", "is_approved", "rejection_reason", "reviewed_by", "reviewed_at", "updated_at"])
            return Response(VendorProfileSerializer(vendor).data, status=status.HTTP_200_OK)
        except VendorProfile.DoesNotExist:
            return Response({"error": "Vendor not found"}, status=status.HTTP_404_NOT_FOUND)


class PublicVendorListView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = PublicVendorProfileSerializer

    def get_queryset(self):
        return VendorProfile.objects.filter(is_approved=True, application_status="APPROVED").prefetch_related("gas_bottles")


class DeliveryListCreateView(generics.ListCreateAPIView):
    """
    GET:  - Clients see their own orders
          - Delivery persons see PENDING (unassigned) or orders assigned to them
          - Vendors see orders that came to their store
    POST: Clients create a new delivery order (status=PENDING)
    """
    serializer_class = DeliverySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_admin or user.is_superuser or user.is_staff:
            return Delivery.objects.all().select_related(
                "client", "vendor", "gas_bottle", "delivery_person"
            )
        if user.is_delivery_person and hasattr(user, "delivery_profile") and user.delivery_profile.application_status == "APPROVED":
            return Delivery.objects.filter(
                models.Q(status="PENDING", fulfillment_method="DELIVERY", delivery_person__isnull=True, payment_status="PAID") |
                models.Q(delivery_person=user, payment_status="PAID")
            ).select_related("client", "vendor", "gas_bottle", "delivery_person")
        if hasattr(user, "vendor_profile") and user.vendor_profile.is_approved:
            return Delivery.objects.filter(
                vendor=user.vendor_profile, payment_status="PAID"
            ).select_related("client", "vendor", "gas_bottle", "delivery_person")
        # Regular client
        return Delivery.objects.filter(client=user).select_related(
            "client", "vendor", "gas_bottle", "delivery_person"
        )

    def create(self, request, *args, **kwargs):
        user = request.user
        if user.is_delivery_person or hasattr(user, "vendor_profile") or user.is_admin or user.is_superuser:
            return Response({"error": "Only customer accounts can place gas orders."}, status=status.HTTP_403_FORBIDDEN)
        return Response(
            {"detail": "Payment is required before a gas order is created. Use /api/payments/initiate/."},
            status=status.HTTP_402_PAYMENT_REQUIRED,
        )


class DeliveryDetailUpdateView(generics.RetrieveUpdateAPIView):
    """
    GET:    Retrieve a single delivery (accessible by client, assigned driver, vendor, admin)
    PATCH:  Delivery person can self-assign and update status; driver and client
            must both confirm before a delivery can be marked complete.
    """
    serializer_class = DeliverySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_admin or user.is_superuser or user.is_staff:
            return Delivery.objects.all()
        if user.is_delivery_person and hasattr(user, "delivery_profile") and user.delivery_profile.application_status == "APPROVED":
            return Delivery.objects.filter(
                models.Q(status="PENDING", fulfillment_method="DELIVERY", delivery_person__isnull=True, payment_status="PAID") |
                models.Q(delivery_person=user, payment_status="PAID")
            )
        if hasattr(user, "vendor_profile") and user.vendor_profile.is_approved:
            return Delivery.objects.filter(vendor=user.vendor_profile, payment_status="PAID")
        return Delivery.objects.filter(client=user)

    def patch(self, request, *args, **kwargs):
        order = self.get_object()
        next_status = str(request.data.get("status", "")).upper()
        user = request.user
        is_admin = user.is_admin or user.is_superuser or user.is_staff

        completion_confirmation = request.data.get("completion_confirmation")
        if completion_confirmation is not None:
            confirmation = str(completion_confirmation).upper()
            if confirmation not in {"DRIVER", "CLIENT"}:
                return Response(
                    {"error": "completion_confirmation must be DRIVER or CLIENT."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            if order.fulfillment_method != "DELIVERY":
                return Response(
                    {"error": "Only delivery orders require delivery confirmations."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            if order.payment_status != "PAID":
                return Response(
                    {"error": "This order is unavailable until its payment is confirmed."},
                    status=status.HTTP_409_CONFLICT,
                )

            with transaction.atomic():
                order = Delivery.objects.select_for_update().get(pk=order.pk)
                if confirmation == "DRIVER":
                    if not user.is_delivery_person or order.delivery_person_id != user.id:
                        return Response(
                            {"error": "Only the assigned delivery person can confirm delivery."},
                            status=status.HTTP_403_FORBIDDEN,
                        )
                    if (
                        not hasattr(user, "delivery_profile")
                        or user.delivery_profile.application_status != "APPROVED"
                    ):
                        return Response(
                            {"error": "Delivery-person verification is not approved."},
                            status=status.HTTP_403_FORBIDDEN,
                        )
                    if order.status not in {"OUT_FOR_DELIVERY", "DELIVERED"}:
                        return Response(
                            {"error": "Start the delivery before marking it complete."},
                            status=status.HTTP_409_CONFLICT,
                        )
                    order.driver_confirmed_delivery = True
                else:
                    if order.client_id != user.id:
                        return Response(
                            {"error": "Only the customer who placed the order can confirm receipt."},
                            status=status.HTTP_403_FORBIDDEN,
                        )
                    # Let a retry succeed after the final confirmation was saved.
                    if not order.client_confirmed_delivery:
                        if order.status != "OUT_FOR_DELIVERY" or not order.driver_confirmed_delivery:
                            return Response(
                                {"error": "Confirm receipt after the delivery person marks the order delivered."},
                                status=status.HTTP_409_CONFLICT,
                            )
                        order.client_confirmed_delivery = True

                if order.driver_confirmed_delivery and order.client_confirmed_delivery:
                    order.status = "DELIVERED"
                order.save(
                    update_fields=[
                        "driver_confirmed_delivery",
                        "client_confirmed_delivery",
                        "status",
                        "updated_at",
                    ]
                )
            return Response(DeliverySerializer(order, context={"request": request}).data)

        if not next_status:
            return Response({"error": "status is required."}, status=status.HTTP_400_BAD_REQUEST)
        if not is_admin and order.payment_status != "PAID":
            return Response(
                {"error": "This order is unavailable until its payment is confirmed."},
                status=status.HTTP_409_CONFLICT,
            )
        if (
            next_status == "CANCELLED"
            and order.payment_status == "PAID"
            and order.payment_transaction_id
            and not (is_admin and request.data.get("refund_confirmed") is True)
        ):
            return Response(
                {"error": "Process the refund in DigiPay first; an administrator must then confirm refund_confirmed=true."},
                status=status.HTTP_409_CONFLICT,
            )
        if (
            next_status == "DELIVERED"
            and not (order.driver_confirmed_delivery and order.client_confirmed_delivery)
        ):
            return Response(
                {"error": "Both the assigned delivery person and customer must confirm completion."},
                status=status.HTTP_409_CONFLICT,
            )

        if is_admin:
            allowed = set(dict(Delivery.STATUS_CHOICES))
        elif user.is_delivery_person and order.fulfillment_method == "DELIVERY":
            if not hasattr(user, "delivery_profile") or user.delivery_profile.application_status != "APPROVED":
                return Response({"error": "Delivery-person verification is not approved."}, status=status.HTTP_403_FORBIDDEN)
            if order.delivery_person_id is None and order.status == "PENDING":
                allowed = {"ASSIGNED"}
            elif order.delivery_person_id == user.id and order.status == "ASSIGNED":
                allowed = {"OUT_FOR_DELIVERY"}
            else:
                allowed = set()
        elif hasattr(user, "vendor_profile") and order.vendor_id == user.vendor_profile.id:
            if not user.vendor_profile.is_approved:
                return Response({"error": "Supplier verification is not approved."}, status=status.HTTP_403_FORBIDDEN)
            if order.fulfillment_method == "PICKUP" and order.status == "PENDING":
                allowed = {"READY_FOR_PICKUP"}
            elif order.fulfillment_method == "PICKUP" and order.status == "READY_FOR_PICKUP":
                allowed = {"PICKED_UP"}
            else:
                allowed = set()
        else:
            can_cancel_without_refund = not order.payment_transaction_id
            allowed = (
                {"CANCELLED"}
                if order.client_id == user.id
                and order.status == "PENDING"
                and can_cancel_without_refund
                else set()
            )

        if next_status not in allowed:
            return Response({"error": "This account cannot make that order status change."}, status=status.HTTP_403_FORBIDDEN)
        if order.fulfillment_method == "PICKUP" and next_status in {"ASSIGNED", "OUT_FOR_DELIVERY", "DELIVERED"}:
            return Response({"error": "Pickup orders cannot be assigned to a delivery person."}, status=status.HTTP_400_BAD_REQUEST)

        with transaction.atomic():
            if next_status == "CANCELLED" and order.stock_deducted:
                GasBottle.objects.filter(pk=order.gas_bottle_id).update(stock_quantity=F("stock_quantity") + 1)
                order.stock_deducted = False
            order.status = next_status
            if (
                next_status == "CANCELLED"
                and order.payment_status == "PAID"
                and order.payment_transaction_id
            ):
                order.payment_status = "REFUNDED"
            if next_status == "ASSIGNED" and user.is_delivery_person and order.delivery_person_id is None:
                order.delivery_person = user
            order.save(update_fields=["status", "delivery_person", "stock_deducted", "payment_status", "updated_at"])
        return Response(DeliverySerializer(order, context={"request": request}).data)

    def put(self, request, *args, **kwargs):
        return self.patch(request, *args, **kwargs)
