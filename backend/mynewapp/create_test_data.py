import os
import django
import sys
from datetime import timedelta
import random
from django.utils import timezone

# Set up Django environment
project_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(project_path)
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth import get_user_model
from mynewapp.models import GasSensor, GasReading, Alert, Notification

User = get_user_model()

def create_gas_readings():
    print("Creating gas readings for existing user phareljean@icloud.com...")
    
    try:
        # Get the existing user
        user = User.objects.get(email='phareljean@icloud.com')
        
        # Get or create a gas sensor for this user
        sensor, created = GasSensor.objects.get_or_create(
            house__user=user,
            defaults={
                'sensor_name': 'Main Propane Tank',
                'sensor_type': 'PROPANE',
                'serial_number': 'HTK-2023-001',
                'installation_date': timezone.now().date() - timedelta(days=180),
                'last_calibration_date': timezone.now().date() - timedelta(days=30),
                'battery_level_percentage': random.randint(70, 90),
                'is_active': True,
                'capacity': 20  # 20kg capacity
            }
        )
        
        if created:
            # If we created a new sensor, assign it to the first house
            house = user.houses.first()
            if house:
                sensor.house = house
                sensor.save()
        
        # Clear existing readings for this sensor (optional)
        # GasReading.objects.filter(sensor=sensor).delete()
        
        # Create realistic gas readings (7 days of data)
        current_level = 85.0  # Starting at 85%
        for i in range(7, -1, -1):
            # Simulate higher usage on weekends
            is_weekend = (timezone.now() - timedelta(days=i)).weekday() >= 5
            usage = random.uniform(2.0, 4.0) if is_weekend else random.uniform(1.0, 2.5)
            
            GasReading.objects.create(
                sensor=sensor,
                remaining_gas=current_level * sensor.capacity / 100,
                reading_timestamp=timezone.now() - timedelta(days=i),
                is_alert_triggered=False
            )
            current_level -= usage
        
        # Update current level in sensor
        latest_reading = GasReading.objects.filter(sensor=sensor).latest('reading_timestamp')
        sensor.current_gas_level = latest_reading.remaining_gas
        sensor.save()
        
        # Create alert if level is low
        current_percentage = (latest_reading.remaining_gas / sensor.capacity) * 100
        if current_percentage < 25:
            alert = Alert.objects.create(
                user=user,
                sensor=sensor,
                alert_type='GAS_LEVEL_LOW',
                severity_level='HIGH' if current_percentage < 15 else 'MEDIUM',
                alert_message=f'Gas level is at {current_percentage:.1f}%',
                is_resolved=False,
                triggered_at=timezone.now()
            )
            
            Notification.objects.create(
                alert=alert,
                notification_method='EMAIL',
                recipient_address=user.email,
                notification_status='SENT'
            )
        
        print(f"""
        Successfully created test data:
        - Sensor: {sensor.sensor_name} (Current level: {current_percentage:.1f}%)
        - {GasReading.objects.filter(sensor=sensor).count()} gas readings
        - {Alert.objects.filter(sensor=sensor).count()} alerts
        """)
        
    except User.DoesNotExist:
        print("Error: User phareljean@icloud.com not found")
    except Exception as e:
        print(f"Error creating test data: {str(e)}")

if __name__ == '__main__':
    create_gas_readings()