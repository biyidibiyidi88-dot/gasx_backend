from django.urls import path

from .views import (
    AlertListView,
    BulkDeleteGasReadingsView,
    DailyGasConsumptionView,
    GasLeakAlertCreateView,
    GasPredictionView,
    GasReadingCreateView,
    GasReadingListView,
    GasSensorListView,
    HouseDetailView,
    HouseListCreateView,
    LoginView,
    LogoutView,
    MarkNotificationAsReadView,
    NotificationListView,
    NotificationSettingsView,
    PasswordChangeView,
    ProfileImageView,
    RegisterView,
    UserDetailView,
    UserInviteView,
    UserListView,
    UserProfileView,
    UserStatusUpdateView,
    CookableFoodListView,
    VendorRegistrationView,
    VendorProfileDetailView,
    VendorGasBottleListCreateView,
    VendorGasBottleDetailView,
    AdminVendorValidationListView,
    AdminVendorValidationUpdateView,
    PublicVendorListView,
)

urlpatterns = [
    # Authentication endpoints
    path("auth/register/", RegisterView.as_view(), name="register"),
    path("auth/login/", LoginView.as_view(), name="login"),
    path("auth/logout/", LogoutView.as_view(), name="logout"),
    # User endpoints
    path("auth/password-change/", PasswordChangeView.as_view(), name="password-change"),
    path("users/profile/", UserProfileView.as_view(), name="user-profile"),
    path(
        "users/profile/image/", ProfileImageView.as_view(), name="profile-image"
    ),  # Add this line
    # User management endpoints
    path("users/", UserListView.as_view(), name="user-list"),
    path("users/<int:id>/", UserDetailView.as_view(), name="user-detail"),
    path("users/invite/", UserInviteView.as_view(), name="user-invite"),
    path("users/<int:id>/status/", UserStatusUpdateView.as_view(), name="user-status"),
    # Notification endpoints
    path("notifications/", NotificationListView.as_view(), name="notification-list"),
    path(
        "notifications/<int:notification_id>/read/",
        MarkNotificationAsReadView.as_view(),
        name="mark-notification-read",
    ),
    path(
        "notifications/settings/",
        NotificationSettingsView.as_view(),
        name="notification-settings",
    ),
    # Other endpoints...
    path("houses/", HouseListCreateView.as_view(), name="house-list"),
    path("houses/<uuid:pk>/", HouseDetailView.as_view(), name="house-detail"),
    path("sensors/", GasSensorListView.as_view(), name="sensor-list"),
    path(
        "sensors/<int:sensor_id>/cookable-foods/",
        CookableFoodListView.as_view(),
        name="sensor-cookable-foods",
    ),
    path("alerts/", AlertListView.as_view(), name="alert-list"),
    path("gas-readings/", GasReadingListView.as_view(), name="gas-reading-list"),
    path(
        "gas-readings/create/",
        GasReadingCreateView.as_view(),
        name="gas-reading-create",
    ),
    path(
        "gas-readings/daily/",
        DailyGasConsumptionView.as_view(),
        name="daily-gas-consumption",
    ),
    path(
        "gas-readings/bulk-delete/",
        BulkDeleteGasReadingsView.as_view(),
        name="bulk-delete-gas-readings",
    ),
    # ESP32 endpoints
    path(
        "alerts/gas-leak/",
        GasLeakAlertCreateView.as_view(),
        name="gas-leak-alert-create",
    ),
    # gas related end points
    path("gas/prediction/", GasPredictionView.as_view(), name="gas-prediction"),
    
    # Vendor endpoints
    path("vendor/register/", VendorRegistrationView.as_view(), name="vendor-register"),
    path("vendor/profile/", VendorProfileDetailView.as_view(), name="vendor-profile"),
    path("vendor/gas-bottles/", VendorGasBottleListCreateView.as_view(), name="vendor-gas-bottles"),
    path("vendor/gas-bottles/<int:pk>/", VendorGasBottleDetailView.as_view(), name="vendor-gas-bottle-detail"),
    
    # Admin vendor validation
    path("admin/vendors/validation/", AdminVendorValidationListView.as_view(), name="admin-vendor-validation-list"),
    path("admin/vendors/validation/<int:pk>/", AdminVendorValidationUpdateView.as_view(), name="admin-vendor-validation-update"),
    
    # Public endpoints
    path("public/vendors/", PublicVendorListView.as_view(), name="public-vendor-list"),
]
