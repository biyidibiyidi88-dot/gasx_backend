from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.utils import timezone
from rest_framework import serializers
from rest_framework.authtoken.models import Token

from .models import (
    Alert,
    CookableFood,
    CustomUser,
    EmergencyAction,
    EmergencyContact,
    GasReading,
    GasRefillRecord,
    GasSensor,
    House,
    Notification,
    SensorMaintenanceRecord,
    VendorProfile,
    GasBottle,
)

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    auth_token = serializers.SerializerMethodField()
    is_administrator = serializers.BooleanField(read_only=True)
    profile_image_url = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = [
            "id",
            "email",
            "password",
            "first_name",
            "last_name",
            "phone_number",
            "address",
            "city",
            "state_province",
            "country",
            "is_verified",
            "is_admin",
            "accept_terms",
            "newsletter_subscription",
            "created_at",
            "auth_token",
            "is_administrator",
            "profile_image",
            "profile_image_url",
            "is_active",
            "preferred_bottle_size",
            "preferred_bottle_brand",
            "tare_weight",
            "gas_capacity",
        ]
        extra_kwargs = {
            "password": {"write_only": True},
            "profile_image": {"write_only": True},
        }

    def get_auth_token(self, obj):
        token, created = Token.objects.get_or_create(user=obj)
        return token.key

    def get_profile_image_url(self, obj):
        if obj.profile_image and hasattr(obj.profile_image, "url"):
            return obj.profile_image.url
        return None

    def validate(self, data):
        if "password" in data:
            try:
                validate_password(data["password"])
            except ValidationError as e:
                raise serializers.ValidationError({"password": list(e.messages)})
        return data

    def validate_email(self, value):
        if self.instance and self.instance.email == value:
            return value
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, required=True)
    token = serializers.CharField(read_only=True)

    def validate(self, data):
        email = data.get("email")
        password = data.get("password")

        if email and password:
            user = User.objects.filter(email=email).first()

            if user and user.check_password(password):
                if not user.is_active:
                    raise serializers.ValidationError("User account is disabled.")
                token, _ = Token.objects.get_or_create(user=user)
                data["token"] = token.key
                data["user"] = user
            else:
                raise serializers.ValidationError(
                    "Unable to log in with provided credentials."
                )
        else:
            raise serializers.ValidationError("Must include 'email' and 'password'.")

        return data


class HouseSerializer(serializers.ModelSerializer):
    location = serializers.SerializerMethodField()

    class Meta:
        model = House
        fields = [
            "id",
            "user",
            "address_line_1",
            "address_line_2",
            "city",
            "state_province",
            "country",
            "postal_code",
            "is_primary_residence",
            "created_at",
            "updated_at",
            "location",
        ]
        read_only_fields = ["user", "created_at", "updated_at", "location"]

    def get_location(self, obj):
        return f"{obj.city}, {obj.state_province}, {obj.country}"


class GasSensorSerializer(serializers.ModelSerializer):
    current_gas_level = serializers.SerializerMethodField()
    needs_maintenance = serializers.SerializerMethodField()
    house_address = serializers.CharField(source="house.address_line_1", read_only=True)
    remaining_days_for_calibration = serializers.SerializerMethodField()

    class Meta:
        model = GasSensor
        fields = [
            "id",
            "house",
            "house_address",
            "sensor_name",
            "sensor_type",
            "serial_number",
            "installation_date",
            "last_calibration_date",
            "battery_level_percentage",
            "is_active",
            "current_gas_level",
            "needs_maintenance",
            "remaining_days_for_calibration",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "created_at",
            "updated_at",
            "current_gas_level",
            "needs_maintenance",
            "remaining_days_for_calibration",
        ]

    def get_current_gas_level(self, obj):
        latest = obj.gas_readings.order_by("-reading_timestamp").first()
        return float(latest.remaining_gas) if latest else 0.0

    def get_needs_maintenance(self, obj):
        return obj.needs_calibration

    def get_remaining_days_for_calibration(self, obj):
        if obj.last_calibration_date:
            next_calibration = obj.last_calibration_date + timezone.timedelta(days=180)
            return (next_calibration - timezone.now().date()).days
        return None





class AlertSerializer(serializers.ModelSerializer):
    duration = serializers.SerializerMethodField()
    sensor_name = serializers.CharField(source="sensor.sensor_name", read_only=True)
    house_address = serializers.CharField(
        source="sensor.house.address_line_1", read_only=True
    )
    resolved_by_name = serializers.CharField(
        source="resolved_by.get_full_name", read_only=True
    )
    sensor_type = serializers.CharField(source="sensor.sensor_type", read_only=True)

    class Meta:
        model = Alert
        fields = [
            "id",
            "user",
            "sensor",
            "sensor_name",
            "sensor_type",
            "house_address",
            "alert_type",
            "severity_level",
            "alert_message",
            "is_resolved",
            "triggered_at",
            "resolved_at",
            "resolved_by",
            "resolved_by_name",
            "duration",
        ]
        read_only_fields = ["triggered_at", "resolved_at", "duration"]

    def get_duration(self, obj):
        if obj.is_resolved and obj.resolved_at:
            return (obj.resolved_at - obj.triggered_at).total_seconds()
        elif not obj.is_resolved:
            return (timezone.now() - obj.triggered_at).total_seconds()
        return None


class NotificationSerializer(serializers.ModelSerializer):
    alert_message = serializers.CharField(source="alert.alert_message", read_only=True)
    alert_type = serializers.CharField(source="alert.alert_type", read_only=True)
    severity_level = serializers.CharField(
        source="alert.severity_level", read_only=True
    )
    is_resolved = serializers.BooleanField(source="alert.is_resolved", read_only=True)
    triggered_at = serializers.DateTimeField(
        source="alert.triggered_at", read_only=True
    )
    sensor_name = serializers.CharField(
        source="alert.sensor.sensor_name", read_only=True
    )
    house_address = serializers.CharField(
        source="alert.sensor.house.address_line_1", read_only=True
    )

    class Meta:
        model = Notification
        fields = [
            "id",
            "alert",
            "alert_message",
            "alert_type",
            "notification_method",
            "recipient_address",
            "notification_status",
            "sent_at",
            "error_message",
            "severity_level",
            "is_resolved",
            "triggered_at",
            "sensor_name",
            "house_address",
        ]
        read_only_fields = ["sent_at"]


class EmergencyContactSerializer(serializers.ModelSerializer):
    user_email = serializers.CharField(source="user.email", read_only=True)

    class Meta:
        model = EmergencyContact
        fields = [
            "id",
            "user",
            "user_email",
            "contact_name",
            "contact_phone",
            "contact_email",
            "relationship",
            "is_primary_contact",
        ]


class SensorMaintenanceRecordSerializer(serializers.ModelSerializer):
    performed_by_name = serializers.CharField(
        source="performed_by.get_full_name", read_only=True
    )
    sensor_name = serializers.CharField(source="sensor.sensor_name", read_only=True)

    class Meta:
        model = SensorMaintenanceRecord
        fields = [
            "id",
            "sensor",
            "sensor_name",
            "maintenance_type",
            "maintenance_notes",
            "performed_at",
            "next_maintenance_due",
            "performed_by",
            "performed_by_name",
        ]
        read_only_fields = ["performed_at"]


class EmergencyActionSerializer(serializers.ModelSerializer):
    initiated_by_name = serializers.CharField(
        source="initiated_by.get_full_name", read_only=True
    )
    sensor_name = serializers.CharField(source="sensor.sensor_name", read_only=True)
    house_address = serializers.CharField(
        source="sensor.house.address_line_1", read_only=True
    )

    class Meta:
        model = EmergencyAction
        fields = [
            "id",
            "sensor",
            "sensor_name",
            "house_address",
            "action_type",
            "action_status",
            "initiated_at",
            "completed_at",
            "initiated_by",
            "initiated_by_name",
        ]
        read_only_fields = ["initiated_at"]


class GasRefillRecordSerializer(serializers.ModelSerializer):
    recorded_by_name = serializers.CharField(
        source="recorded_by.get_full_name", read_only=True
    )
    sensor_name = serializers.CharField(source="sensor.sensor_name", read_only=True)
    house_address = serializers.CharField(
        source="sensor.house.address_line_1", read_only=True
    )

    class Meta:
        model = GasRefillRecord
        fields = [
            "id",
            "sensor",
            "sensor_name",
            "house_address",
            "refill_amount",
            "refill_cost",
            "supplier_name",
            "refill_date",
            "recorded_by",
            "recorded_by_name",
        ]


class UserProfileSerializer(serializers.ModelSerializer):
    houses = HouseSerializer(many=True, read_only=True)
    emergency_contacts = EmergencyContactSerializer(
        source="emergencycontact_set", many=True, read_only=True
    )
    profile_image_url = serializers.SerializerMethodField()
    role = serializers.SerializerMethodField()
    active_alerts_count = serializers.SerializerMethodField()
    sensors_count = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = [
            "id",
            "email",
            "first_name",
            "last_name",
            "phone_number",
            "address",
            "city",
            "state_province",
            "country",
            "profile_image",
            "is_verified",
            "accept_terms",
            "newsletter_subscription",
            "is_admin",
            "preferred_bottle_size",
            "preferred_bottle_brand",
            "tare_weight",
            "gas_capacity",
            "houses",
            "emergency_contacts",
            "created_at",
            "profile_image_url",
            "role",
            "active_alerts_count",
            "sensors_count",
        ]
        read_only_fields = [
            "is_verified",
            "created_at",
            "is_admin",
            "active_alerts_count",
            "sensors_count",
        ]
        extra_kwargs = {
            "profile_image": {"write_only": True},
        }

    def get_profile_image_url(self, obj):
        if obj.profile_image and hasattr(obj.profile_image, "url"):
            return obj.profile_image.url
        return None

    def get_role(self, obj):
        if obj.is_superuser:
            return "Super Admin"
        elif obj.is_admin:
            return "Admin"
        if hasattr(obj, "vendor_profile"):
            return "Vendor"
        return "User"

    def get_active_alerts_count(self, obj):
        return obj.alerts.filter(is_resolved=False).count()

    def get_sensors_count(self, obj):
        return GasSensor.objects.filter(house__user=obj).count()


class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)

    def validate_new_password(self, value):
        try:
            validate_password(value)
        except ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value

        # user managment serializer


class UserManagementSerializer(serializers.ModelSerializer):
    role = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()
    profile_image_url = serializers.SerializerMethodField()
    last_active = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = [
            "id",
            "email",
            "first_name",
            "last_name",
            "phone_number",
            "role",
            "status",
            "last_active",
            "profile_image_url",
            "created_at",
        ]
        read_only_fields = ["created_at"]

    def get_role(self, obj):
        if obj.is_superuser:
            return "superadmin"
        elif obj.is_admin:
            return "admin"
        return "user"

    def get_status(self, obj):
        if obj.is_active:
            return "active"
        return "suspended"

    def get_profile_image_url(self, obj):
        if obj.profile_image and hasattr(obj.profile_image, "url"):
            request = self.context.get("request")
            if request is not None:
                return request.build_absolute_uri(obj.profile_image.url)
            return obj.profile_image.url
        return None

    def get_last_active(self, obj):
        return obj.last_login


class ProfileImageSerializer(serializers.ModelSerializer):
    profile_image_url = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = ["profile_image", "profile_image_url"]
        extra_kwargs = {
            "profile_image": {
                "write_only": True,
                "required": False,  # Add this to allow null/empty values
                "allow_null": True,  # Add this to support deletion
            },
        }

    # profile image handling
    def get_profile_image_url(self, obj):
        if obj.profile_image and hasattr(obj.profile_image, "url"):
            request = self.context.get("request")
            if request is not None:
                return request.build_absolute_uri(obj.profile_image.url)
            return obj.profile_image.url
        return None

    def update(self, instance, validated_data):
        # Handle image deletion when None is passed
        if (
            "profile_image" in validated_data
            and validated_data["profile_image"] is None
        ):
            if instance.profile_image:
                # Delete the file from storage
                default_storage.delete(instance.profile_image.path)
            instance.profile_image = None
        else:
            # Default update behavior for other cases
            return super().update(instance, validated_data)

        instance.save()
        return instance


class GasReadingSerializer(serializers.ModelSerializer):
    sensor_name = serializers.CharField(source="sensor.sensor_name", read_only=True)
    sensor_type = serializers.CharField(source="sensor.sensor_type", read_only=True)
    date = serializers.SerializerMethodField()
    is_weekend = serializers.SerializerMethodField()
    raw_weight = serializers.DecimalField(
        max_digits=10, decimal_places=2, required=False, write_only=True
    )

    class Meta:
        model = GasReading
        fields = [
            "id",
            "sensor",
            "sensor_name",
            "sensor_type",
            "remaining_gas",
            "raw_weight",
            "reading_timestamp",
            "is_alert_triggered",
            "date",
            "is_weekend",
        ]
        read_only_fields = ["date", "is_weekend"]
        extra_kwargs = {
            "remaining_gas": {"required": False}
        }

    def get_date(self, obj):
        return obj.reading_timestamp.date().isoformat()

    def get_is_weekend(self, obj):
        return obj.reading_timestamp.weekday() >= 5  # Saturday or Sunday


class GasLeakAlertSerializer(serializers.Serializer):
    """Serializer for ESP32 gas leak alerts"""

    sensor_id = serializers.IntegerField(
        required=True, help_text="ID of the gas sensor that detected the leak"
    )
    severity_level = serializers.ChoiceField(
        choices=[
            ("LOW", "Low"),
            ("MEDIUM", "Medium"),
            ("HIGH", "High"),
            ("CRITICAL", "Critical"),
        ],
        required=True,
        help_text="Severity level of the gas leak",
    )
    alert_message = serializers.CharField(
        max_length=500,
        required=False,
        allow_blank=True,
        help_text="Optional custom alert message from ESP32",
    )
    gas_concentration = serializers.FloatField(
        required=False,
        allow_null=True,
        help_text="Gas concentration reading in ppm (optional)",
    )
    location_details = serializers.CharField(
        max_length=200,
        required=False,
        allow_blank=True,
        help_text="Specific location details where leak was detected",
    )

    def validate_sensor_id(self, value):
        """Validate that the sensor exists and is active"""
        try:
            sensor = GasSensor.objects.get(id=value, is_active=True)
            return value
        except GasSensor.DoesNotExist:
            raise serializers.ValidationError(
                f"Active gas sensor with ID {value} not found."
            )

    def validate_gas_concentration(self, value):
        """Validate gas concentration is positive if provided"""
        if value is not None and value < 0:
            raise serializers.ValidationError(
                "Gas concentration must be a positive value."
            )
        return value

    def create_alert(self, validated_data):
        """Create a gas leak alert from validated data"""
        sensor_id = validated_data["sensor_id"]
        sensor = GasSensor.objects.get(id=sensor_id)

        # Generate alert message if not provided
        alert_message = validated_data.get("alert_message", "")
        if not alert_message:
            concentration_text = ""
            if validated_data.get("gas_concentration"):
                concentration_text = (
                    f" (concentration: {validated_data['gas_concentration']} ppm)"
                )

            location_text = ""
            if validated_data.get("location_details"):
                location_text = f" in {validated_data['location_details']}"

            alert_message = f"Gas leak detected by {sensor.sensor_name}{location_text}{concentration_text}. Immediate attention required!"

        # Check for existing unresolved gas leak alert for this sensor
        existing_alert = Alert.objects.filter(
            sensor=sensor, alert_type="GAS_LEAK", is_resolved=False
        ).first()

        if existing_alert:
            # Update existing alert with new severity if it's higher
            severity_order = {"LOW": 1, "MEDIUM": 2, "HIGH": 3, "CRITICAL": 4}
            if (
                severity_order[validated_data["severity_level"]]
                > severity_order[existing_alert.severity_level]
            ):
                existing_alert.severity_level = validated_data["severity_level"]
                existing_alert.alert_message = alert_message
                existing_alert.save()
            return existing_alert

        # Create new alert
        alert = Alert.objects.create(
            user=sensor.house.user,
            sensor=sensor,
            alert_type="GAS_LEAK",
            severity_level=validated_data["severity_level"],
            alert_message=alert_message,
            is_resolved=False,
        )

        return alert


class CookableFoodSerializer(serializers.ModelSerializer):
    class Meta:
        model = CookableFood
        fields = [
            "id",
            "name",
            "estimated_gas_required",
            "cooking_time_minutes",
            "image_url",
        ]


class GasBottleSerializer(serializers.ModelSerializer):
    brand_display = serializers.CharField(source="get_brand_display", read_only=True)
    size_display = serializers.CharField(source="get_size_display", read_only=True)

    class Meta:
        model = GasBottle
        fields = [
            "id",
            "vendor",
            "brand",
            "brand_display",
            "size",
            "size_display",
            "price",
            "stock_quantity",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["vendor", "created_at", "updated_at"]


class VendorProfileSerializer(serializers.ModelSerializer):
    gas_bottles = GasBottleSerializer(many=True, read_only=True)
    user_email = serializers.CharField(source="user.email", read_only=True)
    user_name = serializers.CharField(source="user.get_full_name", read_only=True)

    class Meta:
        model = VendorProfile
        fields = [
            "id",
            "user",
            "user_email",
            "user_name",
            "store_name",
            "latitude",
            "longitude",
            "address",
            "is_approved",
            "birth_certificate",
            "identity_card",
            "institution_document",
            "gas_bottles",
            "created_at",
        ]
        read_only_fields = ["user", "created_at", "is_approved"]


class PublicVendorProfileSerializer(serializers.ModelSerializer):
    gas_bottles = GasBottleSerializer(many=True, read_only=True)
    user_name = serializers.CharField(source="user.get_full_name", read_only=True)

    class Meta:
        model = VendorProfile
        fields = [
            "id",
            "user_name",
            "store_name",
            "latitude",
            "longitude",
            "address",
            "gas_bottles",
        ]
