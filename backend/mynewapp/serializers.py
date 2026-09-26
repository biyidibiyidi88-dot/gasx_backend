from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.core.files.storage import default_storage
from django.utils import timezone
from rest_framework import serializers
from rest_framework.authtoken.models import Token

from .models import (
    Alert,
    CookableFood,
    CustomUser,
    Delivery,
    DeliveryPersonProfile,
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
from .bottle_config import (
    BOTTLE_CAPACITIES_KG,
    bottle_capacity_kg,
    estimated_tare_kg,
    user_bottle_capacity_kg,
)

User = get_user_model()


class DecimalAsFloatField(serializers.DecimalField):
    """Keep Decimal validation while exposing JSON numbers to Flutter clients."""

    def to_representation(self, value):
        return float(value) if value is not None else None


class OptionalCoordinateField(serializers.FloatField):
    """Accept blank multipart coordinate fields as omitted values."""

    def to_internal_value(self, data):
        if isinstance(data, str) and not data.strip():
            return None
        return super().to_internal_value(data)


class UserSerializer(serializers.ModelSerializer):
    auth_token = serializers.SerializerMethodField()
    is_administrator = serializers.BooleanField(read_only=True)
    profile_image_url = serializers.SerializerMethodField()
    role = serializers.SerializerMethodField()
    application_status = serializers.SerializerMethodField()
    account_type = serializers.ChoiceField(
        choices=("client", "delivery_person", "gas_supplier"),
        write_only=True,
        required=False,
        default="client",
    )
    supplier_name = serializers.CharField(write_only=True, required=False, allow_blank=True)
    supplier_address = serializers.CharField(write_only=True, required=False, allow_blank=True)
    supplier_latitude = OptionalCoordinateField(
        write_only=True, required=False, allow_null=True
    )
    supplier_longitude = OptionalCoordinateField(
        write_only=True, required=False, allow_null=True
    )
    identity_card = serializers.FileField(write_only=True, required=False)
    tax_payment_document = serializers.FileField(write_only=True, required=False)
    supporting_document = serializers.FileField(write_only=True, required=False)

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
            "is_delivery_person",
            "accept_terms",
            "newsletter_subscription",
            "created_at",
            "auth_token",
            "is_administrator",
            "role",
            "application_status",
            "account_type",
            "supplier_name",
            "supplier_address",
            "supplier_latitude",
            "supplier_longitude",
            "identity_card",
            "tax_payment_document",
            "supporting_document",
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
            "is_admin": {"read_only": True},
            "is_delivery_person": {"read_only": True},
            "is_active": {"read_only": True},
            "is_verified": {"read_only": True},
            "created_at": {"read_only": True},
        }

    def get_auth_token(self, obj):
        token, created = Token.objects.get_or_create(user=obj)
        return token.key

    def get_profile_image_url(self, obj):
        if obj.profile_image and hasattr(obj.profile_image, "url"):
            return obj.profile_image.url
        return None

    def get_role(self, obj):
        if obj.is_superuser or obj.is_admin:
            return "admin"
        if obj.is_delivery_person:
            return "delivery_person"
        if hasattr(obj, "vendor_profile"):
            return "gas_supplier"
        return "client"

    def get_application_status(self, obj):
        if hasattr(obj, "vendor_profile"):
            return obj.vendor_profile.application_status.lower()
        if hasattr(obj, "delivery_profile"):
            return obj.delivery_profile.application_status.lower()
        return "approved"

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data["gas_capacity"] = str(user_bottle_capacity_kg(instance))
        return data

    def validate(self, data):
        if "password" in data:
            try:
                validate_password(data["password"])
            except ValidationError as e:
                raise serializers.ValidationError({"password": list(e.messages)})

        bottle_size = data.get("preferred_bottle_size", "MEDIUM_12_5KG")
        bottle_brand = data.get("preferred_bottle_brand", "TOTAL_ENERGIES")
        if bottle_size not in BOTTLE_CAPACITIES_KG:
            raise serializers.ValidationError(
                {"preferred_bottle_size": "Select a supported bottle size."}
            )
        data["gas_capacity"] = bottle_capacity_kg(bottle_size)
        if "tare_weight" not in self.initial_data:
            data["tare_weight"] = estimated_tare_kg(bottle_size, bottle_brand)

        account_type = data.get("account_type", "client")
        if account_type in ("delivery_person", "gas_supplier") and not data.get("identity_card"):
            raise serializers.ValidationError({"identity_card": "Upload a clear identity card image."})
        if account_type == "gas_supplier":
            required_supplier_fields = {
                "supplier_name": "Enter the gas supplier or store name.",
                "tax_payment_document": "Upload the tax payment receipt.",
                "supporting_document": "Upload a document that proves the supplier's authenticity.",
            }
            errors = {
                field: message
                for field, message in required_supplier_fields.items()
                if data.get(field) in (None, "")
            }
            latitude = data.get("supplier_latitude")
            longitude = data.get("supplier_longitude")
            has_latitude = latitude is not None
            has_longitude = longitude is not None
            address = (data.get("supplier_address") or "").strip()
            if has_latitude != has_longitude:
                errors["supplier_latitude"] = (
                    "Provide both map coordinates, or leave both blank."
                )
            elif not address and not (has_latitude and has_longitude):
                errors["supplier_address"] = (
                    "Provide a business address or both map coordinates."
                )
            if errors:
                raise serializers.ValidationError(errors)
            if has_latitude and not -90 <= latitude <= 90:
                raise serializers.ValidationError({"supplier_latitude": "Latitude must be between -90 and 90."})
            if has_longitude and not -180 <= longitude <= 180:
                raise serializers.ValidationError({"supplier_longitude": "Longitude must be between -180 and 180."})
        return data

    def validate_email(self, value):
        if self.instance and self.instance.email == value:
            return value
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value

    def create(self, validated_data):
        account_type = validated_data.pop("account_type", "client")
        supplier_name = validated_data.pop("supplier_name", "")
        supplier_address = validated_data.pop("supplier_address", "")
        supplier_latitude = validated_data.pop("supplier_latitude", None)
        supplier_longitude = validated_data.pop("supplier_longitude", None)
        identity_card = validated_data.pop("identity_card", None)
        tax_payment_document = validated_data.pop("tax_payment_document", None)
        supporting_document = validated_data.pop("supporting_document", None)

        if account_type == "delivery_person":
            validated_data["is_delivery_person"] = True
        user = User.objects.create_user(**validated_data)
        if account_type == "delivery_person":
            DeliveryPersonProfile.objects.create(
                user=user,
                identity_card=identity_card,
                supporting_document=supporting_document,
            )
        elif account_type == "gas_supplier":
            VendorProfile.objects.create(
                user=user,
                store_name=supplier_name,
                address=supplier_address,
                latitude=supplier_latitude,
                longitude=supplier_longitude,
                identity_card=identity_card,
                tax_payment_document=tax_payment_document,
                additional_document=supporting_document,
            )
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
    current_gas_percentage = serializers.SerializerMethodField()
    tare_weight = serializers.SerializerMethodField()
    gas_capacity = serializers.SerializerMethodField()
    needs_maintenance = serializers.SerializerMethodField()
    house_address = serializers.CharField(source="house.address_line_1", read_only=True)
    owner_email = serializers.EmailField(source="house.user.email", read_only=True)
    owner_name = serializers.CharField(source="house.user.get_full_name", read_only=True)
    remaining_days_for_calibration = serializers.SerializerMethodField()
    raw_weight = DecimalAsFloatField(
        max_digits=10, decimal_places=2, read_only=True
    )

    class Meta:
        model = GasSensor
        fields = [
            "id",
            "house",
            "house_address",
            "owner_email",
            "owner_name",
            "sensor_name",
            "sensor_type",
            "serial_number",
            "installation_date",
            "last_calibration_date",
            "battery_level_percentage",
            "is_active",
            "current_gas_level",
            "current_gas_percentage",
            "raw_weight",
            "tare_weight",
            "gas_capacity",
            "desired_valve_state",
            "current_valve_state",
            "desired_alarm_state",
            "is_alarm_silenced",
            "needs_maintenance",
            "remaining_days_for_calibration",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "created_at",
            "updated_at",
            "current_gas_level",
            "current_gas_percentage",
            "tare_weight",
            "gas_capacity",
            "needs_maintenance",
            "remaining_days_for_calibration",
        ]

    def get_current_gas_level(self, obj):
        latest = obj.gas_readings.order_by("-reading_timestamp").first()
        return float(latest.remaining_gas) if latest else 0.0

    def get_current_gas_percentage(self, obj):
        latest = obj.gas_readings.order_by("-reading_timestamp").first()
        if not latest:
            return 0.0
        try:
            capacity = float(user_bottle_capacity_kg(obj.house.user))
            if capacity <= 0:
                capacity = 12.5
        except (AttributeError, TypeError, ValueError):
            capacity = 12.5
        remaining = float(latest.remaining_gas)
        pct = (remaining / capacity) * 100.0
        return round(max(0.0, min(100.0, pct)), 1)

    def get_tare_weight(self, obj):
        try:
            return float(obj.house.user.tare_weight)
        except (AttributeError, TypeError, ValueError):
            return 12.50

    def get_gas_capacity(self, obj):
        try:
            return float(user_bottle_capacity_kg(obj.house.user))
        except (AttributeError, TypeError, ValueError):
            return 12.50

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
    application_status = serializers.SerializerMethodField()
    active_alerts_count = serializers.SerializerMethodField()
    sensors_count = serializers.SerializerMethodField()

    def validate(self, attrs):
        bottle_size = attrs.get(
            "preferred_bottle_size",
            self.instance.preferred_bottle_size if self.instance else "MEDIUM_12_5KG",
        )
        bottle_brand = attrs.get(
            "preferred_bottle_brand",
            self.instance.preferred_bottle_brand if self.instance else "TOTAL_ENERGIES",
        )
        if bottle_size not in BOTTLE_CAPACITIES_KG:
            raise serializers.ValidationError(
                {"preferred_bottle_size": "Select a supported bottle size."}
            )

        # The selected bottle's nominal gas capacity is authoritative.
        attrs["gas_capacity"] = bottle_capacity_kg(bottle_size)
        size_or_brand_changed = self.instance and (
            bottle_size != self.instance.preferred_bottle_size
            or bottle_brand != self.instance.preferred_bottle_brand
        )
        if size_or_brand_changed and "tare_weight" not in attrs:
            attrs["tare_weight"] = estimated_tare_kg(bottle_size, bottle_brand)
        return attrs

    def update(self, instance, validated_data):
        user = super().update(instance, validated_data)
        capacity = user_bottle_capacity_kg(user)
        if user.gas_capacity != capacity:
            user.gas_capacity = capacity
            user.save(update_fields=["gas_capacity"])
        return user

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Decimal strings are retained here for compatibility with UserAccount.
        data["gas_capacity"] = str(user_bottle_capacity_kg(instance))
        return data

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
            "application_status",
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
        if obj.is_superuser or obj.is_admin:
            return "admin"
        elif obj.is_delivery_person:
            return "delivery_person"
        if hasattr(obj, "vendor_profile"):
            return "gas_supplier"
        return "client"

    def get_application_status(self, obj):
        if hasattr(obj, "vendor_profile"):
            return obj.vendor_profile.application_status.lower()
        if hasattr(obj, "delivery_profile"):
            return obj.delivery_profile.application_status.lower()
        return "approved"

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
    application_status = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = [
            "id",
            "email",
            "first_name",
            "last_name",
            "phone_number",
            "role",
            "application_status",
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
        elif obj.is_delivery_person:
            return "delivery_person"
        elif hasattr(obj, "vendor_profile"):
            return "gas_supplier"
        return "user"

    def get_status(self, obj):
        if hasattr(obj, "vendor_profile") and obj.vendor_profile.application_status != "APPROVED":
            return "pending"
        if hasattr(obj, "delivery_profile") and obj.delivery_profile.application_status != "APPROVED":
            return "pending"
        if obj.is_active:
            return "active"
        return "suspended"

    def get_application_status(self, obj):
        if hasattr(obj, "vendor_profile"):
            return obj.vendor_profile.application_status.lower()
        if hasattr(obj, "delivery_profile"):
            return obj.delivery_profile.application_status.lower()
        return "approved"

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
    raw_weight = DecimalAsFloatField(
        max_digits=10, decimal_places=2, min_value=0, required=True
    )
    remaining_gas = DecimalAsFloatField(
        max_digits=10, decimal_places=2, read_only=True
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
            "remaining_gas": {"read_only": True}
        }

    def validate_sensor(self, sensor):
        request = self.context.get("request")
        if not sensor.is_active:
            raise serializers.ValidationError("Sensor is inactive.")
        if request and sensor.house.user_id != request.user.id:
            raise serializers.ValidationError("Sensor does not belong to this account.")
        return sensor

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

            address_str = sensor.house.address_line_1 if sensor.house else "Unknown Location"
            time_str = timezone.now().strftime('%d %b %Y, %H:%M:%S')
            alert_message = f"Gas leak detected on sensor '{sensor.sensor_name}' at {address_str}{concentration_text} — {time_str}. Immediate attention required!"

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
    identity_card = serializers.FileField(write_only=True, required=False)
    birth_certificate = serializers.FileField(write_only=True, required=False)
    institution_document = serializers.FileField(write_only=True, required=False)
    tax_payment_document = serializers.FileField(write_only=True, required=False)
    additional_document = serializers.FileField(write_only=True, required=False)
    has_identity_card = serializers.SerializerMethodField()
    has_tax_payment_document = serializers.SerializerMethodField()
    has_additional_document = serializers.SerializerMethodField()

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
            "application_status",
            "rejection_reason",
            "reviewed_at",
            "birth_certificate",
            "identity_card",
            "institution_document",
            "tax_payment_document",
            "additional_document",
            "has_identity_card",
            "has_tax_payment_document",
            "has_additional_document",
            "gas_bottles",
            "created_at",
        ]
        read_only_fields = [
            "user", "created_at", "is_approved", "application_status",
            "rejection_reason", "reviewed_at", "has_identity_card",
            "has_tax_payment_document", "has_additional_document",
        ]

    def get_has_identity_card(self, obj):
        return bool(obj.identity_card)

    def get_has_tax_payment_document(self, obj):
        return bool(obj.tax_payment_document)

    def get_has_additional_document(self, obj):
        return bool(obj.additional_document or obj.institution_document or obj.birth_certificate)

    def update(self, instance, validated_data):
        application_changed = any(
            key in validated_data
            for key in (
                "store_name", "address", "latitude", "longitude", "identity_card",
                "tax_payment_document", "additional_document", "institution_document",
                "birth_certificate",
            )
        )
        if application_changed:
            validated_data["application_status"] = "PENDING"
            validated_data["is_approved"] = False
            validated_data["rejection_reason"] = ""
            validated_data["reviewed_at"] = None
            validated_data["reviewed_by"] = None
        return super().update(instance, validated_data)


class DeliveryPersonProfileSerializer(serializers.ModelSerializer):
    user_email = serializers.EmailField(source="user.email", read_only=True)
    user_name = serializers.CharField(source="user.get_full_name", read_only=True)
    user_phone = serializers.CharField(source="user.phone_number", read_only=True)
    has_identity_card = serializers.SerializerMethodField()
    has_supporting_document = serializers.SerializerMethodField()
    identity_card = serializers.FileField(write_only=True, required=False)
    supporting_document = serializers.FileField(write_only=True, required=False)

    class Meta:
        model = DeliveryPersonProfile
        fields = [
            "id", "user", "user_name", "user_email", "user_phone",
            "application_status", "rejection_reason", "reviewed_at",
            "has_identity_card", "has_supporting_document", "identity_card",
            "supporting_document", "created_at",
        ]
        read_only_fields = [
            "user", "application_status", "rejection_reason", "reviewed_at",
            "has_identity_card", "has_supporting_document", "created_at",
        ]

    def get_has_identity_card(self, obj):
        return bool(obj.identity_card)

    def get_has_supporting_document(self, obj):
        return bool(obj.supporting_document)

    def update(self, instance, validated_data):
        if "identity_card" in validated_data or "supporting_document" in validated_data:
            validated_data["application_status"] = "PENDING"
            validated_data["rejection_reason"] = ""
            validated_data["reviewed_by"] = None
            validated_data["reviewed_at"] = None
        return super().update(instance, validated_data)


class DeliverySerializer(serializers.ModelSerializer):
    client_name = serializers.CharField(source="client.get_full_name", read_only=True)
    client_email = serializers.EmailField(source="client.email", read_only=True)
    vendor_name = serializers.CharField(source="vendor.store_name", read_only=True)
    vendor_address = serializers.CharField(source="vendor.address", read_only=True)
    vendor_latitude = serializers.FloatField(source="vendor.latitude", read_only=True)
    vendor_longitude = serializers.FloatField(source="vendor.longitude", read_only=True)
    delivery_person_name = serializers.SerializerMethodField()
    bottle_detail = serializers.SerializerMethodField()
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    fulfillment_display = serializers.CharField(source="get_fulfillment_method_display", read_only=True)
    unit_price = DecimalAsFloatField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = Delivery
        fields = [
            "id",
            "client",
            "client_name",
            "client_email",
            "vendor",
            "vendor_name",
            "vendor_address",
            "vendor_latitude",
            "vendor_longitude",
            "gas_bottle",
            "bottle_detail",
            "delivery_person",
            "delivery_person_name",
            "status",
            "status_display",
            "fulfillment_method",
            "fulfillment_display",
            "unit_price",
            "delivery_fee",
            "payment_amount",
            "payment_status",
            "payment_operator",
            "payment_transaction_id",
            "delivery_address",
            "latitude",
            "longitude",
            "driver_confirmed_delivery",
            "client_confirmed_delivery",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "client", "vendor", "gas_bottle", "delivery_person", "status",
            "fulfillment_method", "unit_price", "created_at", "updated_at",
            "delivery_fee", "payment_amount", "payment_status", "payment_operator",
            "payment_transaction_id",
            "driver_confirmed_delivery", "client_confirmed_delivery",
            "status_display", "fulfillment_display", "client_name", "client_email",
            "vendor_name", "vendor_address", "vendor_latitude", "vendor_longitude",
            "delivery_person_name", "bottle_detail",
        ]

    def get_delivery_person_name(self, obj):
        if obj.delivery_person:
            return obj.delivery_person.get_full_name()
        return None

    def get_bottle_detail(self, obj):
        b = obj.gas_bottle
        return f"{b.get_brand_display()} {b.get_size_display()} — {obj.unit_price} FCFA"


class DeliveryOrderCreateSerializer(serializers.Serializer):
    gas_bottle = serializers.PrimaryKeyRelatedField(queryset=GasBottle.objects.all())
    fulfillment_method = serializers.ChoiceField(choices=Delivery.FULFILLMENT_CHOICES)
    delivery_address = serializers.CharField(required=False, allow_blank=True)
    latitude = serializers.FloatField(required=False, allow_null=True)
    longitude = serializers.FloatField(required=False, allow_null=True)

    def validate(self, attrs):
        bottle = attrs["gas_bottle"]
        if not bottle.vendor.is_approved or bottle.vendor.application_status != "APPROVED":
            raise serializers.ValidationError({"gas_bottle": "This supplier is not approved."})
        if bottle.stock_quantity < 1:
            raise serializers.ValidationError({"gas_bottle": "This bottle is out of stock."})
        if attrs["fulfillment_method"] == "DELIVERY" and not attrs.get("delivery_address", "").strip():
            raise serializers.ValidationError({"delivery_address": "Enter a delivery address."})
        latitude = attrs.get("latitude")
        longitude = attrs.get("longitude")
        if (latitude is None) != (longitude is None):
            raise serializers.ValidationError(
                {"location": "Provide both GPS latitude and longitude, or leave both empty."}
            )
        if latitude is not None and not (-90 <= latitude <= 90):
            raise serializers.ValidationError({"latitude": "Latitude must be between -90 and 90."})
        if longitude is not None and not (-180 <= longitude <= 180):
            raise serializers.ValidationError({"longitude": "Longitude must be between -180 and 180."})
        if attrs["fulfillment_method"] == "PICKUP":
            attrs["delivery_address"] = bottle.vendor.address
            attrs["latitude"] = None
            attrs["longitude"] = None
        return attrs


class PaymentInitiateSerializer(DeliveryOrderCreateSerializer):
    payment_operator = serializers.ChoiceField(choices=Delivery.PAYMENT_OPERATOR_CHOICES)
    payer_phone = serializers.CharField(max_length=16)

    def validate_payer_phone(self, value):
        if any(
            not (character.isdigit() or character in "+-() ")
            for character in value
        ):
            raise serializers.ValidationError(
                "Enter a valid Cameroon mobile number."
            )
        digits = "".join(character for character in value if character.isdigit())
        if digits.startswith("237"):
            digits = digits[3:]
        if len(digits) != 9:
            raise serializers.ValidationError(
                "Enter a Cameroon mobile number with 9 digits."
            )
        return f"237{digits}"


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
