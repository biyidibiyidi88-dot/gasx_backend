from django.urls import path
from .views import (
    RegisterView,
    LoginView,
    LogoutView,
    UserProfileView,
    PasswordChangeView,
    HouseListCreateView,
    HouseDetailView,
    GasSensorListView,
    AlertListView,
    ProfileImageView ,
    UserListView,
    UserDetailView,
    UserInviteView,
    UserStatusUpdateView,
    NotificationListView,
    MarkNotificationAsReadView,
    NotificationSettingsView,
    GasReadingListView,
    GasReadingCreateView,
    GasPredictionView,
    
)

urlpatterns = [
    # Authentication endpoints
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', LoginView.as_view(), name='login'),
    path('auth/logout/', LogoutView.as_view(), name='logout'),
    
    # User endpoints
    path('auth/password-change/', PasswordChangeView.as_view(), name='password-change'),
    path('users/profile/', UserProfileView.as_view(), name='user-profile'),
    path('users/profile/image/', ProfileImageView.as_view(), name='profile-image'),  # Add this line
    
     # User management endpoints
    path('users/', UserListView.as_view(), name='user-list'),
    path('users/<int:id>/', UserDetailView.as_view(), name='user-detail'),
    path('users/invite/', UserInviteView.as_view(), name='user-invite'),
    path('users/<int:id>/status/', UserStatusUpdateView.as_view(), name='user-status'),

    # Notification endpoints
    path('notifications/', NotificationListView.as_view(), name='notification-list'),
    path('notifications/<int:notification_id>/read/', MarkNotificationAsReadView.as_view(), name='mark-notification-read'),
    path('notifications/settings/', NotificationSettingsView.as_view(), name='notification-settings'),

    # Other endpoints...
    path('houses/', HouseListCreateView.as_view(), name='house-list'),
    path('houses/<uuid:pk>/', HouseDetailView.as_view(), name='house-detail'),
    path('sensors/', GasSensorListView.as_view(), name='sensor-list'),
    path('alerts/', AlertListView.as_view(), name='alert-list'),
    path('gas-readings/', GasReadingListView.as_view(), name='gas-reading-list'),
    path('gas-readings/create/', GasReadingCreateView.as_view(), name='gas-reading-create'),
     path('gas/prediction/', GasPredictionView.as_view(), name='gas-prediction'),
]