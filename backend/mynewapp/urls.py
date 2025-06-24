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
    AlertListView
)

urlpatterns = [
    # Authentication endpoints
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', LoginView.as_view(), name='login'),
    path('auth/logout/', LogoutView.as_view(), name='logout'),
    
    # User endpoints
    path('auth/password-change/', PasswordChangeView.as_view(), name='password-change'),
    path('users/profile/', UserProfileView.as_view(), name='user-profile'),
    
    # House endpoints
    path('houses/', HouseListCreateView.as_view(), name='house-list'),
    path('houses/<uuid:pk>/', HouseDetailView.as_view(), name='house-detail'),
    
    # Sensor endpoints
    path('sensors/', GasSensorListView.as_view(), name='sensor-list'),
    
    # Alert endpoints
    path('alerts/', AlertListView.as_view(), name='alert-list'),
]