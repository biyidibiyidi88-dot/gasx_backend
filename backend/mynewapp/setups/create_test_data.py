import os
import django
import sys
from datetime import timedelta
import random
from django.utils import timezone

# Set up Django environment
project_path = '/home/tchoua/Desktop/gasmonitor/Gas_Monitor/backend'
sys.path.append(project_path)
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth import get_user_model
from mynewapp.models import GasSensor, GasReading, Alert, Notification

User = get_user_model()

def create_gas_readings():
    print("Creating gas readings for existing user biyiditchoua@gmail.com...")
    
    try:
        # Get the existing user
        user = User.objects.get(email='biyiditchoua@gmail.com')
        
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
                'is_active': True
            }
        )
        
        if created:
            # If we created a new sensor, assign it to the first house
            house = user.houses.first()
            if house:
                sensor.house = house
                sensor.save()
        
        # Clear existing readings and alerts for this sensor
        GasReading.objects.filter(sensor=sensor).delete()
        Alert.objects.filter(sensor=sensor).delete()
        
        # Query authorization token
        from rest_framework.authtoken.models import Token
        token, _ = Token.objects.get_or_create(user=user)
        
        # Set up HTTP parameters
        import requests
        headers = {
            "Authorization": f"Token {token.key}",
            "Content-Type": "application/json"
        }
        url = "http://127.0.0.1:8000/api/gas-readings/create/"
        
        # Create realistic gas readings (7 days of data)
        print("Uploading readings via REST API POST requests...")
        current_level = 85.0  # Starting at 85%
        for i in range(7, -1, -1):
            is_weekend = (timezone.now() - timedelta(days=i)).weekday() >= 5
            usage = random.uniform(2.0, 4.0) if is_weekend else random.uniform(1.0, 2.5)
            
            # Force the final reading to be below the 20% low and 15% high gas thresholds
            if i == 0:
                current_level = 12.0
            
            payload = {
                "sensor": sensor.id,
                "remaining_gas": round(current_level * float(user.gas_capacity) / 100, 2),
                "reading_timestamp": (timezone.now() - timedelta(days=i)).isoformat()
            }
            
            try:
                response = requests.post(url, headers=headers, json=payload, timeout=5)
                if response.status_code not in [200, 201]:
                    print(f"Failed to post reading: {response.text}")
            except Exception as e:
                print(f"Exception posting reading: {e}")
                
            current_level -= usage
        
        # Close old db connections to avoid PgBouncer session closed errors
        from django.db import connections
        connections.close_all()
        
        # Update current level in sensor (automatically handled by the read-only current_gas_level property)
        latest_reading = GasReading.objects.filter(sensor=sensor).latest('reading_timestamp')
        current_percentage = (latest_reading.remaining_gas / user.gas_capacity) * 100
        
        # Always trigger a simulated gas leak alert to test the notifications system
        alert_url = "http://127.0.0.1:8000/api/alerts/gas-leak/"
        alert_payload = {
            "sensor_id": sensor.id,
            "severity_level": "CRITICAL",
            "gas_concentration": 450.0,
            "location_details": sensor.sensor_name
        }
        try:
            response = requests.post(alert_url, headers=headers, json=alert_payload, timeout=5)
            if response.status_code not in [200, 201]:
                print(f"Failed to post alert: {response.text}")
        except Exception as e:
            print(f"Exception posting alert: {e}")
        
        print(f"""
        Successfully created test data:
        - Sensor: {sensor.sensor_name} (Current level: {current_percentage:.1f}%)
        - {GasReading.objects.filter(sensor=sensor).count()} gas readings
        - {Alert.objects.filter(sensor=sensor).count()} alerts
        """)
        
    except User.DoesNotExist:
        print("Error: User biyiditchoua@gmail.com not found")
    except Exception as e:
        print(f"Error creating test data: {str(e)}")

if __name__ == '__main__':
    create_gas_readings()