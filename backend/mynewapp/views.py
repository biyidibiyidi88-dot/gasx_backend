import json
import logging
from datetime import datetime, timedelta

from django.contrib.auth import get_user_model, login, logout
from django.core.files.storage import default_storage
from django.utils import timezone
from rest_framework import generics, permissions, status
from rest_framework.authtoken.models import Token
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Alert, CustomUser, GasReading, GasSensor, House, Notification
from .serializers import (
    AlertSerializer,
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
)
from .services.ai_service import AIPredictionService
from .services.email_service import email_service

User = get_user_model()


class RegisterView(APIView):
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
        request.user.auth_token.delete()
        logout(request)
        return Response(status=status.HTTP_200_OK)


class UserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


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
        return GasSensor.objects.filter(house__user=self.request.user)


class AlertListView(generics.ListAPIView):
    serializer_class = AlertSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
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
    permission_classes = [permissions.IsAdminUser]

    def get_queryset(self):
        return User.objects.all().order_by("-created_at")


class UserDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = UserManagementSerializer
    permission_classes = [permissions.IsAdminUser]
    queryset = User.objects.all()
    lookup_field = "id"


class UserInviteView(generics.CreateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAdminUser]

    def perform_create(self, serializer):
        user = serializer.save(is_active=False)  # Create inactive user
        # Here you would typically send an invitation email
        # with an activation link
        return user


class UserStatusUpdateView(APIView):
    permission_classes = [permissions.IsAdminUser]

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
            # In a real app, you might want to mark this as read in some way
            # For now, we'll just return the notification
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

            # Get readings from the last 7 days
            end_date = timezone.now()
            start_date = end_date - timedelta(days=7)

            readings = GasReading.objects.filter(
                sensor=sensor, reading_timestamp__gte=start_date
            ).order_by("reading_timestamp")

            if not readings.exists():
                return Response(
                    {"error": "No gas readings available for prediction"},
                    status=status.HTTP_400_BAD_REQUEST,
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
                    {"error": "Insufficient data for prediction"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Get current remaining gas from latest reading
            latest_reading = (
                readings.first()
            )  # readings are ordered by -reading_timestamp
            current_remaining_kg = (
                float(latest_reading.remaining_gas) if latest_reading else 1.0
            )

            # Get prediction from AI service
            prediction = AIPredictionService.predict_days_remaining(
                history_data, current_remaining_kg
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
        queryset = GasReading.objects.filter(
            sensor__house__user=self.request.user
        ).select_related("sensor", "sensor__house")

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


class GasReadingCreateView(generics.CreateAPIView):
    serializer_class = GasReadingSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        # Save the gas reading
        gas_reading = serializer.save()

        # Check if gas level is at or below critical threshold (15%)
        sensor = gas_reading.sensor
        remaining_gas = float(gas_reading.remaining_gas)

        # Calculate percentage based on 20kg tank capacity (from memory)
        TANK_CAPACITY = 20.0  # kg
        gas_percentage = (remaining_gas / TANK_CAPACITY) * 100

        # Alert thresholds to match frontend: 20% (low), 10% (critical)
        LOW_THRESHOLD = 20.0
        CRITICAL_THRESHOLD = 10.0

        if gas_percentage <= LOW_THRESHOLD:
            # Mark the reading as alert triggered
            gas_reading.is_alert_triggered = True
            gas_reading.save()

            # Check if there's already an unresolved alert for this sensor
            existing_alert = Alert.objects.filter(
                sensor=sensor, alert_type="GAS_LEVEL_LOW", is_resolved=False
            ).first()

            # Only create a new alert if there isn't an existing unresolved one
            if not existing_alert:
                # Determine severity based on gas level (matching frontend thresholds)
                if gas_percentage <= CRITICAL_THRESHOLD:  # <= 10%
                    severity = "CRITICAL"
                elif gas_percentage <= 15:  # 10% < level <= 15%
                    severity = "HIGH"
                else:  # 15% < level <= 20%
                    severity = "MEDIUM"

                # Create the alert
                Alert.objects.create(
                    user=sensor.house.user,
                    sensor=sensor,
                    alert_type="GAS_LEVEL_LOW",
                    severity_level=severity,
                    alert_message=f"Critical gas level detected! {sensor.sensor_name} has only {remaining_gas}kg ({gas_percentage:.1f}%) remaining. Please refill soon.",
                    is_resolved=False,
                )

        return gas_reading


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
