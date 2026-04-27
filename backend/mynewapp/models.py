from django.contrib.auth.models import AbstractUser, BaseUserManager, PermissionsMixin
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models
from django.urls import reverse
from django.utils import timezone
from django.utils.translation import gettext_lazy as _


class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError(_("The Email must be set"))
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        extra_fields.setdefault("is_verified", True)
        extra_fields.setdefault("is_admin", True)
        return self.create_user(email, password, **extra_fields)


class CustomUser(AbstractUser, PermissionsMixin):
    username = None
    email = models.EmailField(_("email address"), unique=True)
    first_name = models.CharField(_("first name"), max_length=150)
    last_name = models.CharField(_("last name"), max_length=150)
    phone_number = models.CharField(
        _("phone number"), max_length=20, blank=True, default=""
    )
    address = models.CharField(_("address"), max_length=255, blank=True, default="")
    city = models.CharField(_("city"), max_length=100, blank=True, default="")
    state_province = models.CharField(
        _("state/province"), max_length=100, blank=True, default=""
    )
    country = models.CharField(_("country"), max_length=100, blank=True, default="")
    profile_image = models.ImageField(
        _("profile image"),
        upload_to="profile_images/",
        null=True,
        blank=True,
        default=None,
        help_text=_("Upload a profile picture"),
    )
    is_verified = models.BooleanField(_("verified"), default=False)
    is_admin = models.BooleanField(_("admin"), default=False)
    accept_terms = models.BooleanField(_("terms accepted"), default=False)
    newsletter_subscription = models.BooleanField(
        _("newsletter subscribed"), default=False
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_login_ip = models.GenericIPAddressField(null=True, blank=True)
    last_activity = models.DateTimeField(default=timezone.now)
    
    # Gas Bottle Preferences
    BOTTLE_SIZE_CHOICES = (
        ("SMALL_6KG", "Small (6kg)"),
        ("MEDIUM_12_5KG", "Medium (12.5kg)"),
        ("BIG_50KG", "Big (50kg)"),
    )
    
    BOTTLE_BRAND_CHOICES = (
        ("SCTM", "SCTM"),
        ("TOTAL_ENERGIES", "TotalEnergies"),
        ("TRADEX", "Tradex"),
        ("STAR_GAS", "StarGas"),
        ("AZA_MRS", "Aza Gas / MRS"),
        ("GLOCAL_GAS", "Glocal Gas"),
        ("BOCOM", "Bocom"),
        ("TOTAL", "Total"),
        ("GREEN_OIL", "Green Oil"),
        ("CAMGAZ", "Camgaz"),
        ("MRS", "MRS"),
        ("AFT", "AFT"),
        ("OTHER", "Other"),
    )

    preferred_bottle_size = models.CharField(
        max_length=20, choices=BOTTLE_SIZE_CHOICES, default="MEDIUM_12_5KG"
    )
    preferred_bottle_brand = models.CharField(
        max_length=50, choices=BOTTLE_BRAND_CHOICES, default="TOTAL_ENERGIES"
    )
    tare_weight = models.DecimalField(
        _("tare weight"), max_digits=5, decimal_places=2, default=12.50
    )
    gas_capacity = models.DecimalField(
        _("gas capacity"), max_digits=5, decimal_places=2, default=12.50
    )

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["first_name", "last_name"]

    objects = CustomUserManager()

    class Meta:
        verbose_name = _("user")
        verbose_name_plural = _("users")
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["email"]),
            models.Index(fields=["is_admin"]),
        ]

    def __str__(self):
        return self.email

    @property
    def is_administrator(self):
        return self.is_superuser or self.is_admin

    def get_absolute_url(self):
        return reverse("api:user-detail", kwargs={"pk": self.pk})

    @property
    def auth_token(self):
        from rest_framework.authtoken.models import Token

        token, _ = Token.objects.get_or_create(user=self)
        return token.key

    def get_full_name(self):
        return f"{self.first_name} {self.last_name}"

    def get_short_name(self):
        return self.first_name

    @property
    def profile_image_url(self):
        if self.profile_image and hasattr(self.profile_image, "url"):
            return self.profile_image.url
        return "/static/images/default-profile.png"  # Add a default image


class AdminActivityLog(models.Model):
    ACTION_CHOICES = [
        ("LOGIN", "Admin Login"),
        ("USER_EDIT", "User Edited"),
        ("SENSOR_EDIT", "Sensor Edited"),
        ("ALERT_RESOLVE", "Alert Resolved"),
    ]

    admin = models.ForeignKey(CustomUser, on_delete=models.SET_NULL, null=True)
    action = models.CharField(max_length=20, choices=ACTION_CHOICES)
    ip_address = models.GenericIPAddressField()
    details = models.JSONField(default=dict)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-timestamp"]
        verbose_name = _("admin activity log")
        verbose_name_plural = _("admin activity logs")

    def __str__(self):
        return f"{self.admin} - {self.get_action_display()} at {self.timestamp}"


class House(models.Model):
    user = models.ForeignKey(
        CustomUser, on_delete=models.CASCADE, related_name="houses"
    )
    address_line_1 = models.CharField(_("address line 1"), max_length=255)
    address_line_2 = models.CharField(
        _("address line 2"), max_length=255, blank=True, null=True
    )
    city = models.CharField(_("city"), max_length=100)
    state_province = models.CharField(_("state/province"), max_length=100)
    country = models.CharField(_("country"), max_length=100)
    postal_code = models.CharField(_("postal code"), max_length=20)
    is_primary_residence = models.BooleanField(_("primary residence"), default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = _("house")
        verbose_name_plural = _("houses")
        indexes = [
            models.Index(fields=["user"]),
        ]

    def __str__(self):
        return f"{self.address_line_1}, {self.city}"

    @property
    def location(self):
        return f"{self.city}, {self.state_province}, {self.country}"

    def get_sensors_status(self):
        from django.db.models import Count

        return self.gas_sensors.aggregate(
            active=Count("id", filter=models.Q(is_active=True)),
            inactive=Count("id", filter=models.Q(is_active=False)),
            needs_maintenance=Count(
                "id",
                filter=models.Q(
                    last_calibration_date__lt=timezone.now()
                    - timezone.timedelta(days=180)
                ),
            ),
        )


class GasSensor(models.Model):
    SENSOR_TYPES = (
        ("METHANE", "Methane"),
        ("CARBON_MONOXIDE", "Carbon Monoxide"),
        ("PROPANE", "Propane"),
        ("BUTANE", "Butane"),
    )

    house = models.ForeignKey(
        House, on_delete=models.CASCADE, related_name="gas_sensors"
    )
    sensor_name = models.CharField(_("sensor name"), max_length=100)
    sensor_type = models.CharField(
        _("sensor type"), max_length=50, choices=SENSOR_TYPES
    )
    serial_number = models.CharField(_("serial number"), max_length=100, unique=True)
    installation_date = models.DateField(_("installation date"))
    last_calibration_date = models.DateField(_("last calibration date"))
    battery_level_percentage = models.IntegerField(
        _("battery level"), validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    is_active = models.BooleanField(_("active"), default=True)
    ai_enabled = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = _("gas sensor")
        verbose_name_plural = _("gas sensors")
        indexes = [
            models.Index(fields=["house"]),
            models.Index(fields=["is_active"]),
            models.Index(fields=["sensor_type"]),
        ]

    def __str__(self):
        return f"{self.sensor_name} ({self.get_sensor_type_display()})"

    @property
    def current_gas_level(self):
        latest = self.gas_readings.order_by("-reading_timestamp").first()
        return latest.remaining_gas if latest else 0

    @property
    def needs_calibration(self):
        return self.last_calibration_date < (
            timezone.now().date() - timezone.timedelta(days=180)
        )

    def api_serialized(self):
        return {
            "id": self.id,
            "name": self.sensor_name,
            "type": self.get_sensor_type_display(),
            "battery": self.battery_level_percentage,
            "current_gas": float(self.current_gas_level),
            "house_id": self.house.id,
            "status": "active" if self.is_active else "inactive",
            "needs_maintenance": self.needs_calibration,
        }


class GasReading(models.Model):
    sensor = models.ForeignKey(
        GasSensor, on_delete=models.CASCADE, related_name="gas_readings"
    )
    remaining_gas = models.DecimalField(
        _("remaining gas"),
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(0)],
    )
    reading_timestamp = models.DateTimeField(
        _("reading timestamp"), default=timezone.now
    )
    is_alert_triggered = models.BooleanField(_("alert triggered"), default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-reading_timestamp"]
        verbose_name = _("gas reading")
        verbose_name_plural = _("gas readings")
        indexes = [
            models.Index(fields=["sensor"]),
            models.Index(fields=["reading_timestamp"]),
            models.Index(fields=["is_alert_triggered"]),
        ]

    def __str__(self):
        return f"{self.sensor}: {self.remaining_gas}kg at {self.reading_timestamp}"


class Alert(models.Model):
    ALERT_TYPES = (
        ("GAS_LEAK", "Gas Leak"),
        ("LOW_BATTERY", "Low Battery"),
        ("SENSOR_OFFLINE", "Sensor Offline"),
        ("GAS_LEVEL_LOW", "Gas Level Low"),
    )

    SEVERITY_LEVELS = (
        ("LOW", "Low"),
        ("MEDIUM", "Medium"),
        ("HIGH", "High"),
        ("CRITICAL", "Critical"),
    )

    user = models.ForeignKey(
        CustomUser, on_delete=models.CASCADE, related_name="alerts"
    )
    sensor = models.ForeignKey(
        GasSensor, on_delete=models.CASCADE, related_name="alerts"
    )
    alert_type = models.CharField(_("alert type"), max_length=50, choices=ALERT_TYPES)
    severity_level = models.CharField(
        _("severity level"), max_length=20, choices=SEVERITY_LEVELS
    )
    alert_message = models.TextField(_("alert message"))
    is_resolved = models.BooleanField(_("resolved"), default=False)
    triggered_at = models.DateTimeField(auto_now_add=True)
    resolved_at = models.DateTimeField(_("resolved at"), null=True, blank=True)
    resolved_by = models.ForeignKey(
        CustomUser,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="resolved_alerts",
    )

    class Meta:
        ordering = ["-triggered_at"]
        verbose_name = _("alert")
        verbose_name_plural = _("alerts")
        indexes = [
            models.Index(fields=["user"]),
            models.Index(fields=["sensor"]),
            models.Index(fields=["is_resolved"]),
            models.Index(fields=["severity_level"]),
        ]

    def __str__(self):
        return f"{self.get_alert_type_display()} alert ({self.get_severity_level_display()})"

    @property
    def duration(self):
        if self.is_resolved and self.resolved_at:
            return self.resolved_at - self.triggered_at
        return timezone.now() - self.triggered_at


class Notification(models.Model):
    NOTIFICATION_METHODS = (
        ("EMAIL", "Email"),
        ("SMS", "SMS"),
        ("PUSH", "Mobile Push"),
    )

    NOTIFICATION_STATUSES = (
        ("PENDING", "Pending"),
        ("SENT", "Sent"),
        ("DELIVERED", "Delivered"),
        ("FAILED", "Failed"),
    )

    alert = models.ForeignKey(
        Alert, on_delete=models.CASCADE, related_name="notifications"
    )
    notification_method = models.CharField(
        _("notification method"), max_length=20, choices=NOTIFICATION_METHODS
    )
    recipient_address = models.CharField(_("recipient address"), max_length=255)
    notification_status = models.CharField(
        _("status"), max_length=20, choices=NOTIFICATION_STATUSES, default="PENDING"
    )
    sent_at = models.DateTimeField(_("sent at"), auto_now_add=True)
    error_message = models.TextField(_("error message"), blank=True, null=True)

    class Meta:
        ordering = ["-sent_at"]
        verbose_name = _("notification")
        verbose_name_plural = _("notifications")

    def __str__(self):
        return f"{self.get_notification_method_display()} to {self.recipient_address}"


class EmergencyContact(models.Model):
    RELATIONSHIPS = (
        ("FAMILY", "Family"),
        ("FRIEND", "Friend"),
        ("NEIGHBOR", "Neighbor"),
        ("LANDLORD", "Landlord"),
        ("OTHER", "Other"),
    )

    user = models.ForeignKey(
        CustomUser, on_delete=models.CASCADE, related_name="emergency_contacts"
    )
    contact_name = models.CharField(_("contact name"), max_length=150)
    contact_phone = models.CharField(_("contact phone"), max_length=20)
    contact_email = models.EmailField(_("contact email"), blank=True, null=True)
    relationship = models.CharField(
        _("relationship"), max_length=20, choices=RELATIONSHIPS
    )
    is_primary_contact = models.BooleanField(_("primary contact"), default=False)

    class Meta:
        ordering = ["-is_primary_contact", "contact_name"]
        verbose_name = _("emergency contact")
        verbose_name_plural = _("emergency contacts")

    def __str__(self):
        return f"{self.contact_name} ({self.get_relationship_display()})"


class SensorMaintenanceRecord(models.Model):
    MAINTENANCE_TYPES = (
        ("BATTERY_REPLACEMENT", "Battery Replacement"),
        ("CALIBRATION", "Calibration"),
        ("CLEANING", "Cleaning"),
        ("INSPECTION", "Inspection"),
        ("OTHER", "Other"),
    )

    sensor = models.ForeignKey(
        GasSensor, on_delete=models.CASCADE, related_name="maintenance_records"
    )
    maintenance_type = models.CharField(
        _("maintenance type"), max_length=50, choices=MAINTENANCE_TYPES
    )
    maintenance_notes = models.TextField(_("notes"), blank=True, null=True)
    performed_at = models.DateTimeField(_("performed at"), auto_now_add=True)
    next_maintenance_due = models.DateField(
        _("next maintenance due"), blank=True, null=True
    )
    performed_by = models.ForeignKey(
        CustomUser,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        limit_choices_to={"is_admin": True},
    )

    class Meta:
        ordering = ["-performed_at"]
        verbose_name = _("maintenance record")
        verbose_name_plural = _("maintenance records")

    def __str__(self):
        return f"{self.get_maintenance_type_display()} on {self.sensor}"


class EmergencyAction(models.Model):
    ACTION_TYPES = (
        ("SHUT_OFF_VALVE", "Shut Off Valve"),
        ("ACTIVATE_VENTILATION", "Activate Ventilation"),
        ("SEND_ALERT", "Send Alert"),
        ("CALL_EMERGENCY", "Call Emergency Services"),
    )

    ACTION_STATUSES = (
        ("PENDING", "Pending"),
        ("TRIGGERED", "Triggered"),
        ("COMPLETED", "Completed"),
        ("FAILED", "Failed"),
    )

    sensor = models.ForeignKey(
        GasSensor, on_delete=models.CASCADE, related_name="emergency_actions"
    )
    action_type = models.CharField(
        _("action type"), max_length=50, choices=ACTION_TYPES
    )
    action_status = models.CharField(
        _("status"), max_length=20, choices=ACTION_STATUSES, default="PENDING"
    )
    initiated_at = models.DateTimeField(_("initiated at"), auto_now_add=True)
    completed_at = models.DateTimeField(_("completed at"), blank=True, null=True)
    initiated_by = models.ForeignKey(
        CustomUser,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="actions_initiated",
    )

    class Meta:
        ordering = ["-initiated_at"]
        verbose_name = _("emergency action")
        verbose_name_plural = _("emergency actions")

    def __str__(self):
        return f"{self.get_action_type_display()} ({self.get_action_status_display()})"


class GasRefillRecord(models.Model):
    sensor = models.ForeignKey(
        GasSensor, on_delete=models.CASCADE, related_name="gas_refills"
    )
    refill_amount = models.DecimalField(
        _("refill amount"), max_digits=10, decimal_places=2
    )
    refill_cost = models.DecimalField(_("refill cost"), max_digits=10, decimal_places=2)
    supplier_name = models.CharField(_("supplier name"), max_length=100)
    refill_date = models.DateField(_("refill date"))
    recorded_by = models.ForeignKey(
        CustomUser,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        limit_choices_to={"is_admin": True},
    )

    class Meta:
        ordering = ["-refill_date"]
        verbose_name = _("gas refill record")
        verbose_name_plural = _("gas refill records")

    def __str__(self):
        return f"{self.refill_amount}kg refill on {self.refill_date}"


class CookableFood(models.Model):
    name = models.CharField(_("food name"), max_length=150)
    estimated_gas_required = models.DecimalField(
        _("estimated gas required (kg)"),
        max_digits=10,
        decimal_places=3,
        validators=[MinValueValidator(0)],
        help_text=_("Estimated gas required to cook this food in kg"),
    )
    cooking_time_minutes = models.IntegerField(
        _("cooking time (minutes)"),
        validators=[MinValueValidator(1)],
        help_text=_("Estimated cooking time in minutes"),
    )
    image_url = models.URLField(_("image URL"), blank=True, null=True)

    class Meta:
        ordering = ["estimated_gas_required"]
        verbose_name = _("cookable food")
        verbose_name_plural = _("cookable foods")

    def __str__(self):
        return f"{self.name} ({self.estimated_gas_required}kg)"


class VendorProfile(models.Model):
    user = models.OneToOneField(
        CustomUser, on_delete=models.CASCADE, related_name="vendor_profile"
    )
    store_name = models.CharField(_("store name"), max_length=255)
    latitude = models.FloatField(_("latitude"), blank=True, null=True)
    longitude = models.FloatField(_("longitude"), blank=True, null=True)
    address = models.CharField(_("address"), max_length=255, blank=True, default="")
    is_approved = models.BooleanField(_("approved"), default=False)
    birth_certificate = models.FileField(
        _("birth certificate"), upload_to="vendor_docs/birth_certs/", blank=True, null=True
    )
    identity_card = models.FileField(
        _("identity card"), upload_to="vendor_docs/id_cards/", blank=True, null=True
    )
    institution_document = models.FileField(
        _("institution document"), upload_to="vendor_docs/institution_docs/", blank=True, null=True
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = _("vendor profile")
        verbose_name_plural = _("vendor profiles")

    def __str__(self):
        return f"{self.store_name} ({self.user.get_full_name()})"


class GasBottle(models.Model):
    BRAND_CHOICES = (
        ("SCTM", "SCTM"),
        ("TOTAL_ENERGIES", "TotalEnergies"),
        ("TRADEX", "Tradex"),
        ("STAR_GAS", "StarGas"),
        ("AZA_MRS", "Aza Gas / MRS"),
        ("GLOCAL_GAS", "Glocal Gas"),
        ("BOCOM", "Bocom"),
        ("TOTAL", "Total"),
        ("GREEN_OIL", "Green Oil"),
        ("CAMGAZ", "Camgaz"),
        ("MRS", "MRS"),
        ("AFT", "AFT"),
        ("OTHER", "Other"),
    )

    SIZE_CHOICES = (
        ("SMALL_6KG", "Small (6kg)"),
        ("MEDIUM_12_5KG", "Medium (12.5kg)"),
        ("BIG_50KG", "Big (50kg)"),
    )

    vendor = models.ForeignKey(
        VendorProfile, on_delete=models.CASCADE, related_name="gas_bottles"
    )
    brand = models.CharField(_("brand"), max_length=50, choices=BRAND_CHOICES)
    size = models.CharField(_("size"), max_length=50, choices=SIZE_CHOICES)
    price = models.DecimalField(
        _("price (CFA)"), max_digits=10, decimal_places=2, validators=[MinValueValidator(0)]
    )
    stock_quantity = models.IntegerField(
        _("stock quantity"), default=0, validators=[MinValueValidator(0)]
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = _("gas bottle")
        verbose_name_plural = _("gas bottles")
        unique_together = ("vendor", "brand", "size")

    def __str__(self):
        return f"{self.get_brand_display()} - {self.get_size_display()} ({self.vendor.store_name})"
