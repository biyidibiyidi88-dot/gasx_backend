#!/usr/bin/env python3
import os
import sys
import django

# Add the backend directory to Python path
sys.path.append('/home/tchoua/Desktop/backup/Gas_Monitor/backend')

# Set Django settings module
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')

# Setup Django
django.setup()

from django.contrib.auth import get_user_model
from mynewapp.models import House, GasSensor
from django.utils import timezone

User = get_user_model()

try:
    user = User.objects.get(email='biyiditchoua@gmail.com')
    house = House.objects.filter(user=user).first()
    
    if not house:
        print("❌ No house found for user")
        sys.exit(1)
    
    sensor = GasSensor.objects.create(
        house=house,
        sensor_name='Test Gas Leak Detector',
        sensor_type='METHANE',
        serial_number='TEST-GLD-001',
        installation_date=timezone.now().date(),
        last_calibration_date=timezone.now().date(),
        battery_level_percentage=95,
        is_active=True,
        ai_enabled=True
    )
    
    print(f'✅ Created sensor: {sensor.sensor_name} (ID: {sensor.id})')
    
except User.DoesNotExist:
    print("❌ User biyiditchoua@gmail.com not found")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error creating sensor: {str(e)}")
    sys.exit(1)
