from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from mynewapp.models import House, GasSensor

User = get_user_model()

class Command(BaseCommand):
    help = 'Create superuser and ESP32 sensor setup for tchouabiyidi@icloud.com'

    def handle(self, *args, **options):
        email = 'tchouabiyidi@icloud.com'
        password = 'A5555555'
        
        self.stdout.write("=== ESP32 User Setup ===")
        
        # Create or get the user
        user, created = User.objects.get_or_create(
            email=email,
            defaults={
                'first_name': 'Tchoua',
                'last_name': 'Biyidi',
                'phone_number': '+1234567892',
                'address': '789 ESP32 Street',
                'city': 'IoT City',
                'state_province': 'CA',
                'country': 'USA',
                'is_staff': True,
                'is_superuser': True,
                'is_admin': True,
                'is_verified': True,
            }
        )
        
        if created:
            user.set_password(password)
            user.save()
            self.stdout.write(f"✅ Created superuser: {email}")
        else:
            # Update password if user exists
            user.set_password(password)
            user.is_staff = True
            user.is_superuser = True
            user.is_admin = True
            user.save()
            self.stdout.write(f"✅ Updated existing user: {email}")
        
        # Get or create authentication token
        token, token_created = Token.objects.get_or_create(user=user)
        if token_created:
            self.stdout.write(f"✅ Created new authentication token")
        else:
            self.stdout.write(f"✅ Using existing authentication token")
        
        # Create or get house for the user
        house, house_created = House.objects.get_or_create(
            user=user,
            defaults={
                'house_name': 'ESP32 Smart Home',
                'address': '789 ESP32 Street',
                'city': 'IoT City',
                'state_province': 'CA',
                'country': 'USA',
                'postal_code': '90210'
            }
        )
        
        if house_created:
            self.stdout.write(f"✅ Created house: {house.house_name}")
        else:
            self.stdout.write(f"✅ Using existing house: {house.house_name}")
        
        # Create or get ESP32 gas sensor
        sensor, sensor_created = GasSensor.objects.get_or_create(
            house=house,
            sensor_name='ESP32 Kitchen Gas Sensor',
            defaults={
                'sensor_type': 'PROPANE',
                'location': 'Kitchen',
                'installation_date': '2025-07-30',
                'is_active': True,
            }
        )
        
        if sensor_created:
            self.stdout.write(f"✅ Created gas sensor: {sensor.sensor_name}")
        else:
            self.stdout.write(f"✅ Using existing gas sensor: {sensor.sensor_name}")
        
        # Display ESP32 configuration
        self.stdout.write("\n=== ESP32 Configuration ===")
        self.stdout.write(f"User Email: {user.email}")
        self.stdout.write(f"User ID: {user.id}")
        self.stdout.write(f"Authentication Token: {token.key}")
        self.stdout.write(f"House ID: {house.id}")
        self.stdout.write(f"Sensor ID: {sensor.id}")
        self.stdout.write(f"Sensor Name: {sensor.sensor_name}")
        
        self.stdout.write("\n=== ESP32 Code Updates Needed ===")
        self.stdout.write(f'const char* authToken = "{token.key}";')
        self.stdout.write(f'const int sensorId = {sensor.id};')
        
        self.stdout.write("\n✅ ESP32 setup completed successfully!")
