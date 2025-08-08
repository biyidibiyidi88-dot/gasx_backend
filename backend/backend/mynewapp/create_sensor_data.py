import os
import django
from django.utils import timezone
from datetime import datetime, timedelta
import random

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'your_project.settings')
django.setup()

from your_app.models import CustomUser, House, GasSensor, GasReading

def create_sensor_and_readings():
    try:
        # 1. Get the user
        user = CustomUser.objects.get(email="tchouabiyidi@gmail.com")
        
        # 2. Get or create a house for this user
        house, created = House.objects.get_or_create(
            user=user,
            defaults={
                'address_line_1': '123 Main St',
                'city': 'Sample City',
                'state_province': 'Sample State',
                'country': 'Sample Country',
                'postal_code': '12345',
                'is_primary_residence': True
            }
        )
        
        # 3. Create a gas sensor
        sensor = GasSensor.objects.create(
            house=house,
            sensor_name="Kitchen Gas Sensor",
            sensor_type="PROPANE",
            serial_number=f"GS-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}",
            installation_date=timezone.now().date() - timedelta(days=60),
            last_calibration_date=timezone.now().date() - timedelta(days=30),
            battery_level_percentage=random.randint(80, 100),
            is_active=True
        )
        
        # 4. Create gas readings for the last 30 days
        today = timezone.now()
        start_date = today - timedelta(days=30)
        
        current_date = start_date
        current_gas = 100.0  # Start with full tank
        
        while current_date <= today:
            # Create 1-4 readings per day
            for _ in range(random.randint(1, 4)):
                # Gas consumption varies between 0.5% to 3% per reading
                gas_consumed = random.uniform(0.5, 3.0)
                current_gas = max(0, current_gas - gas_consumed)  # Ensure doesn't go below 0
                
                # Occasionally simulate a refill (10% chance)
                if random.random() < 0.1 and current_gas < 20:
                    current_gas = 100.0
                
                # Create the reading
                GasReading.objects.create(
                    sensor=sensor,
                    remaining_gas=current_gas,
                    reading_timestamp=current_date + timedelta(
                        hours=random.randint(0, 23),
                        minutes=random.randint(0, 59)
                    ),
                    is_alert_triggered=(current_gas < 10)  # Trigger alert if gas < 10%
                )
            
            current_date += timedelta(days=1)
        
        print(f"Successfully created sensor {sensor.serial_number} with 30 days of readings")
        
    except CustomUser.DoesNotExist:
        print("User with email tchouabiyidi@gmail.com not found")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

if __name__ == "__main__":
    create_sensor_and_readings()