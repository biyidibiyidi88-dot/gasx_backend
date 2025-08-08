from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import datetime, timedelta
import random
from decimal import Decimal
from mynewapp.models import CustomUser, House, GasSensor, GasReading


class Command(BaseCommand):
    help = 'Create realistic test data for Gas Monitor application for both users'

    def add_arguments(self, parser):
        parser.add_argument(
            '--days',
            type=int,
            default=3,
            help='Number of days to generate data for (default: 3)'
        )
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Clear existing test data before creating new data'
        )

    def handle(self, *args, **options):
        days = options['days']
        clear_data = options['clear']
        
        self.stdout.write(f'Creating test data for {days} days...')
        
        if clear_data:
            self.stdout.write('Clearing existing test data...')
            GasReading.objects.all().delete()
            GasSensor.objects.all().delete()
            House.objects.all().delete()
            self.stdout.write('Existing test data cleared.')
        
        # Process all users
        users_data = [
            {
                'email': 'tchouabiyidi@gmail.com',
                'password': 'A5555555',
                'house_data': {
                    'address_line_1': '123 Main Street',
                    'city': 'San Francisco',
                    'state_province': 'California',
                    'country': 'USA',
                    'postal_code': '94102'
                }
            },
            {
                'email': 'biyidichoua@gmail.com',
                'password': 'A5555555',
                'house_data': {
                    'address_line_1': '456 Oak Avenue',
                    'city': 'Los Angeles',
                    'state_province': 'California',
                    'country': 'USA',
                    'postal_code': '90210'
                }
            },
            {
                'email': 'biyiditchoua@gmail.com',
                'password': 'A5555555#',
                'house_data': {
                    'address_line_1': '789 Pine Street',
                    'city': 'Seattle',
                    'state_province': 'Washington',
                    'country': 'USA',
                    'postal_code': '98101'
                }
            }
        ]
        
        for user_info in users_data:
            self.create_user_data(user_info, days)
        
        self.stdout.write(self.style.SUCCESS('Test data creation completed!'))
    
    def create_user_data(self, user_info, days):
        # Get or create the user
        try:
            user = CustomUser.objects.get(email=user_info['email'])
            self.stdout.write(f'Processing existing user: {user.email}')
        except CustomUser.DoesNotExist:
            # Create the user if it doesn't exist
            user = CustomUser.objects.create_user(
                email=user_info['email'],
                password=user_info['password'],
                is_active=True
            )
            self.stdout.write(f'Created new user: {user.email}')

        # Create a house for the user
        house, created = House.objects.get_or_create(
            user=user,
            defaults={
                **user_info['house_data'],
                'is_primary_residence': True
            }
        )
        
        if created:
            self.stdout.write(f'Created house: {house.address_line_1}')
        else:
            self.stdout.write(f'House already exists: {house.address_line_1}')

        # Create a cooking gas sensor (most relevant for home dashboard)
        sensor, created = GasSensor.objects.get_or_create(
            house=house,
            serial_number=f'COOK-GAS-{user.id:03d}',
            defaults={
                'sensor_name': 'Kitchen Cooking Gas Tank',
                'sensor_type': 'PROPANE',  # Cooking gas is typically propane/LPG
                'installation_date': timezone.now().date() - timedelta(days=90),
                'last_calibration_date': timezone.now().date() - timedelta(days=30),
                'battery_level_percentage': random.randint(80, 100),
                'is_active': True,
                'ai_enabled': True
            }
        )
        
        if created:
            self.stdout.write(f'Created sensor: {sensor.sensor_name}')
        else:
            self.stdout.write(f'Sensor already exists: {sensor.sensor_name}')

        # Generate realistic gas readings for the specified number of days
        self.stdout.write(f'Generating gas readings for the past {days} days...')
        
        # Clear existing readings for this sensor to ensure clean test data
        sensor.gas_readings.all().delete()
        
        # Generate realistic cooking gas consumption data
        end_date = timezone.now()
        start_date = end_date - timedelta(days=days)
        
        # Starting gas level (20kg tank capacity, start at ~80% = 16kg)
        current_gas_level = Decimal('16.0')  # kg
        tank_capacity = Decimal('20.0')  # kg
        
        readings_created = 0
        current_datetime = start_date
        
        while current_datetime <= end_date:
            # Generate multiple readings per day (every 6 hours)
            for hour in [6, 12, 18, 23]:  # Morning, noon, evening, night
                reading_time = current_datetime.replace(
                    hour=hour, 
                    minute=random.randint(0, 59),
                    second=random.randint(0, 59)
                )
                # Ensure timezone awareness
                if timezone.is_naive(reading_time):
                    reading_time = timezone.make_aware(reading_time)
                
                # Realistic consumption patterns
                is_weekend = reading_time.weekday() >= 5
                is_peak_cooking = hour in [12, 18]  # Lunch and dinner times
                
                # Calculate consumption since last reading
                if hour == 6:  # Morning - minimal overnight consumption
                    consumption = Decimal(str(random.uniform(0.1, 0.3)))
                elif hour == 12:  # Lunch time - moderate consumption
                    base_consumption = 1.2 if is_weekend else 0.8
                    consumption = Decimal(str(random.uniform(base_consumption, base_consumption + 0.5)))
                elif hour == 18:  # Dinner time - highest consumption
                    base_consumption = 2.0 if is_weekend else 1.5
                    consumption = Decimal(str(random.uniform(base_consumption, base_consumption + 0.8)))
                else:  # Night - minimal consumption
                    consumption = Decimal(str(random.uniform(0.05, 0.2)))
                
                # Apply consumption
                current_gas_level = max(Decimal('0.0'), current_gas_level - consumption)
                
                # Create gas reading
                reading = GasReading.objects.create(
                    sensor=sensor,
                    remaining_gas=current_gas_level,
                    reading_timestamp=reading_time,
                    is_alert_triggered=current_gas_level < Decimal('2.0')  # Alert when < 10% capacity (2kg of 20kg)
                )
                
                readings_created += 1
                
                # Stop if gas runs out (for realism)
                if current_gas_level <= Decimal('0.0'):
                    break
            
            current_datetime += timedelta(days=1)
            
            # Stop if gas runs out
            if current_gas_level <= Decimal('0.0'):
                break
        
        self.stdout.write(f'Created {readings_created} gas readings for {sensor.sensor_name}')
        self.stdout.write(f'Current gas level: {current_gas_level}kg ({(current_gas_level/tank_capacity*100):.1f}%)')
        
        # Show latest reading for verification
        latest_reading = sensor.gas_readings.order_by('-reading_timestamp').first()
        if latest_reading:
            self.stdout.write(f'Latest reading: {latest_reading.remaining_gas}kg at {latest_reading.reading_timestamp}')
