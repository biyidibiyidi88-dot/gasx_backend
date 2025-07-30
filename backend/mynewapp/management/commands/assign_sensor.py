from django.core.management.base import BaseCommand
from django.utils import timezone
from mynewapp.models import CustomUser, House, GasSensor

class Command(BaseCommand):
    help = 'Assign a gas sensor to the specified user'

    def add_arguments(self, parser):
        parser.add_argument('--email', type=str, help='User email', default='tchouabiyidi@icloud.comm')

    def handle(self, *args, **options):
        email = options['email']
        
        try:
            # Get or create the user
            user, created = CustomUser.objects.get_or_create(
                email=email,
                defaults={
                    'username': email,
                    'first_name': 'Tchoua',
                    'last_name': 'Biyidi',
                    'is_staff': True,
                    'is_superuser': True
                }
            )
            
            if created:
                user.set_password('A5555555')  # Default password
                user.save()
                self.stdout.write(f"Created user: {email}")
            else:
                self.stdout.write(f"User already exists: {email}")

            # Create or get house for the user
            house, created = House.objects.get_or_create(
                user=user,
                defaults={
                    'address_line_1': '456 Tech Street',
                    'city': 'San Francisco',
                    'state_province': 'CA',
                    'postal_code': '94105',
                    'country': 'USA',
                    'is_primary_residence': True
                }
            )
            
            if created:
                self.stdout.write(f"Created house: {house.address_line_1}")
            else:
                self.stdout.write(f"House already exists: {house.address_line_1}")

            # Create gas sensor for ESP32 testing
            sensor, created = GasSensor.objects.get_or_create(
                house=house,
                sensor_name='ESP32 Test Sensor',
                defaults={
                    'sensor_type': 'PROPANE',
                    'is_active': True,
                    'installation_date': timezone.now().date(),
                    'last_calibration_date': timezone.now().date(),
                    'battery_level_percentage': 100.0,
                    'serial_number': 'ESP32-TEST-001'
                }
            )
            
            if created:
                self.stdout.write(f"Created sensor: {sensor.sensor_name} (ID: {sensor.id})")
            else:
                self.stdout.write(f"Sensor already exists: {sensor.sensor_name} (ID: {sensor.id})")

            self.stdout.write(
                self.style.SUCCESS(
                    f'\nSensor assignment complete!\n'
                    f'User: {user.email}\n'
                    f'House: {house.address_line_1}\n'
                    f'Sensor: {sensor.sensor_name} (ID: {sensor.id})\n'
                    f'Sensor Type: {sensor.sensor_type}'
                )
            )

        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Error assigning sensor: {str(e)}')
            )
