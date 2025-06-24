from rest_framework import serializers
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from .models import CustomUser, House, GasSensor, GasReading, Alert, Notification, EmergencyContact, SensorMaintenanceRecord, EmergencyAction, GasRefillRecord

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    auth_token = serializers.SerializerMethodField()
    is_administrator = serializers.BooleanField(read_only=True)

    class Meta:
        model = CustomUser
        fields = [
            'id', 'email', 'password', 'first_name', 'last_name', 
            'phone_number', 'address', 'city', 'state_province', 'country',
            'is_verified', 'is_admin', 'accept_terms', 'newsletter_subscription',
            'created_at', 'auth_token', 'is_administrator'
        ]
        extra_kwargs = {
            'password': {'write_only': True},
            'email': {'required': True},
            'first_name': {'required': True},
            'last_name': {'required': True},
            'phone_number': {'required': True},
            'accept_terms': {'required': True},
            'is_admin': {'read_only': True},
            'is_verified': {'read_only': True}
        }

    def get_auth_token(self, obj):
        token, created = Token.objects.get_or_create(user=obj)
        return token.key

    def validate(self, data):
        try:
            validate_password(data['password'])
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
        email = data.get('email')
        password = data.get('password')
        
        if email and password:
            user = User.objects.filter(email=email).first()
            
            if user and user.check_password(password):
                if not user.is_active:
                    raise serializers.ValidationError("User account is disabled.")
                token, _ = Token.objects.get_or_create(user=user)
                data['token'] = token.key
                data['user'] = user
            else:
                raise serializers.ValidationError("Unable to log in with provided credentials.")
        else:
            raise serializers.ValidationError("Must include 'email' and 'password'.")
        
        return data

class HouseSerializer(serializers.ModelSerializer):
    class Meta:
        model = House
        fields = [
            'id', 'user', 'address_line_1', 'address_line_2', 
            'city', 'state_province', 'country', 'postal_code',
            'is_primary_residence', 'created_at', 'updated_at'
        ]
        read_only_fields = ['user', 'created_at', 'updated_at']

class GasSensorSerializer(serializers.ModelSerializer):
    current_gas_level = serializers.SerializerMethodField()
    needs_maintenance = serializers.SerializerMethodField()

    class Meta:
        model = GasSensor
        fields = [
            'id', 'house', 'sensor_name', 'sensor_type', 'serial_number',
            'installation_date', 'last_calibration_date', 'battery_level_percentage',
            'is_active', 'current_gas_level', 'needs_maintenance', 'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at', 'current_gas_level', 'needs_maintenance']

    def get_current_gas_level(self, obj):
        return obj.current_gas_level

    def get_needs_maintenance(self, obj):
        return obj.needs_calibration

class GasReadingSerializer(serializers.ModelSerializer):
    class Meta:
        model = GasReading
        fields = [
            'id', 'sensor', 'remaining_gas', 'reading_timestamp',
            'is_alert_triggered', 'created_at'
        ]
        read_only_fields = ['created_at']

class AlertSerializer(serializers.ModelSerializer):
    duration = serializers.SerializerMethodField()
    sensor_name = serializers.CharField(source='sensor.sensor_name', read_only=True)
    house_address = serializers.CharField(source='sensor.house.address_line_1', read_only=True)

    class Meta:
        model = Alert
        fields = [
            'id', 'user', 'sensor', 'sensor_name', 'house_address',
            'alert_type', 'severity_level', 'alert_message',
            'is_resolved', 'triggered_at', 'resolved_at',
            'resolved_by', 'duration'
        ]
        read_only_fields = ['triggered_at', 'resolved_at', 'duration']

    def get_duration(self, obj):
        return obj.duration.total_seconds() if obj.duration else None

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = [
            'id', 'alert', 'notification_method',
            'recipient_address', 'notification_status',
            'sent_at', 'error_message'
        ]
        read_only_fields = ['sent_at']

class EmergencyContactSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyContact
        fields = [
            'id', 'user', 'contact_name', 'contact_phone',
            'contact_email', 'relationship', 'is_primary_contact'
        ]

class SensorMaintenanceRecordSerializer(serializers.ModelSerializer):
    performed_by_name = serializers.CharField(source='performed_by.get_full_name', read_only=True)

    class Meta:
        model = SensorMaintenanceRecord
        fields = [
            'id', 'sensor', 'maintenance_type', 'maintenance_notes',
            'performed_at', 'next_maintenance_due', 'performed_by', 'performed_by_name'
        ]
        read_only_fields = ['performed_at']

class EmergencyActionSerializer(serializers.ModelSerializer):
    initiated_by_name = serializers.CharField(source='initiated_by.get_full_name', read_only=True)

    class Meta:
        model = EmergencyAction
        fields = [
            'id', 'sensor', 'action_type', 'action_status',
            'initiated_at', 'completed_at', 'initiated_by', 'initiated_by_name'
        ]
        read_only_fields = ['initiated_at']

class GasRefillRecordSerializer(serializers.ModelSerializer):
    recorded_by_name = serializers.CharField(source='recorded_by.get_full_name', read_only=True)

    class Meta:
        model = GasRefillRecord
        fields = [
            'id', 'sensor', 'refill_amount', 'refill_cost',
            'supplier_name', 'refill_date', 'recorded_by', 'recorded_by_name'
        ]

class UserProfileSerializer(serializers.ModelSerializer):
    houses = HouseSerializer(many=True, read_only=True)
    emergency_contacts = EmergencyContactSerializer(many=True, read_only=True)

    class Meta:
        model = CustomUser
        fields = [
            'id', 'email', 'first_name', 'last_name', 'phone_number',
            'address', 'city', 'state_province', 'country',
            'is_verified', 'accept_terms', 'newsletter_subscription',
            'houses', 'emergency_contacts', 'created_at'
        ]
        read_only_fields = ['is_verified', 'created_at']

class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)

    def validate_new_password(self, value):
        try:
            validate_password(value)
        except ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value