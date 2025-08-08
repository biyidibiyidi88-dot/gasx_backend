from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import datetime, timedelta
import random
from decimal import Decimal
from mynewapp.models import CustomUser, House, GasSensor, GasReading


class Command(BaseCommand):
    help = 'Create realistic cooking gas test data for Gas Monitor application'

    def handle(self, *args, **options):
        self.stdout.write('Creating cooking gas test data...')
        
        # Get the superuser
        try:
            user = CustomUser.objects.get(email='tchouabiyidi@gmail.com')
            self.stdout.write(f'Found superuser: {user.email}')
        except CustomUser.DoesNotExist:
            self.stdout.write(self.style.ERROR('Superuser not found. Please create a superuser first.'))
            return

        # Clear existing data for clean test
        self.stdout.write('Clearing existing test data...')
        GasReading.objects.filter(sensor__house__user=user).delete()
        GasSensor.objects.filter(house__user=user).delete()
        House.objects.filter(user=user).delete()

        # Create a house for the user
        house = House.objects.create(
            user=user,
            address_line_1='123 Main Street',
            city='San Francisco',
            state_province='California',
            country='USA',
            postal_code='94102',
            is_primary_residence=True
        )
        self.stdout.write(f'Created house: {house.address_line_1}')

        # Create a single cooking gas sensor (Propane/LPG)
        sensor = GasSensor.objects.create(
            house=house,
            sensor_name='Kitchen Cooking Gas Tank',
            sensor_type='PROPANE',
            serial_number='COOK-GAS-001',
            installation_date=timezone.now().date() - timedelta(days=180),
            last_calibration_date=timezone.now().date() - timedelta(days=45),
            battery_level_percentage=85,
            is_active=True,
            ai_enabled=True
        )
        self.stdout.write(f'Created cooking gas sensor: {sensor.sensor_name}')

        # Generate realistic cooking gas readings for the past month
        self.stdout.write('Generating realistic cooking gas readings...')
        
        end_date = timezone.now()
        start_date = end_date - timedelta(days=30)
        
        # Start with a full tank (100kg typical cooking gas cylinder)
        current_level = Decimal('95.0')  # Start at 95% (recently refilled)
        readings_created = 0
        
        current_date = start_date
        
        while current_date <= end_date:
            # Generate 4 readings per day (morning, noon, evening, night)
            daily_readings = [
                {'hour': 6, 'usage': 0.0},      # Morning - minimal usage
                {'hour': 12, 'usage': 0.8},     # Lunch - moderate cooking
                {'hour': 18, 'usage': 1.2},     # Dinner - heavy cooking
                {'hour': 23, 'usage': 0.2}      # Night - minimal usage
            ]
            
            # Weekend vs weekday usage patterns
            is_weekend = current_date.weekday() >= 5
            usage_multiplier = 1.3 if is_weekend else 1.0  # More cooking on weekends
            
            for reading_info in daily_readings:
                reading_time = current_date.replace(
                    hour=reading_info['hour'], 
                    minute=random.randint(0, 59), 
                    second=0
                )
                
                # Calculate gas consumption based on time of day and day type
                base_consumption = reading_info['usage'] * usage_multiplier
                
                # Add some randomness for realistic variation
                consumption_variation = random.uniform(0.7, 1.3)
                actual_consumption = base_consumption * consumption_variation
                
                # Special occasions (random heavy cooking days)
                if random.random() < 0.1:  # 10% chance of heavy cooking day
                    actual_consumption *= 2.0
                
                # Reduce current level
                current_level = max(Decimal('0'), current_level - Decimal(str(actual_consumption)))
                
                # Convert to percentage (assuming 100kg full tank)
                level_percentage = current_level
                
                # Trigger alerts for low gas
                is_alert = level_percentage < Decimal('15.0')
                
                GasReading.objects.create(
                    sensor=sensor,
                    remaining_gas=level_percentage,
                    reading_timestamp=reading_time,
                    is_alert_triggered=is_alert
                )
                readings_created += 1
                
                # Simulate refill when gas gets very low (below 5%)
                if level_percentage < Decimal('5.0'):
                    current_level = Decimal('95.0')  # Refill to 95%
                    self.stdout.write(f'Simulated refill on {reading_time.strftime("%Y-%m-%d")}')
            
            current_date += timedelta(days=1)
        
        # Generate some additional statistics
        total_readings = GasReading.objects.filter(sensor=sensor).count()
        alert_readings = GasReading.objects.filter(sensor=sensor, is_alert_triggered=True).count()
        latest_reading = GasReading.objects.filter(sensor=sensor).latest('reading_timestamp')
        
        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully created cooking gas test data:\n'
                f'- 1 House: {house.address_line_1}\n'
                f'- 1 Cooking Gas Sensor: {sensor.sensor_name}\n'
                f'- {total_readings} Gas Readings (30 days)\n'
                f'- {alert_readings} Alert readings (low gas warnings)\n'
                f'- Current gas level: {latest_reading.remaining_gas}%\n'
                f'- User: {user.email}'
            )
        )
        
        # Display usage pattern summary
        self.stdout.write('\n--- Cooking Gas Usage Summary ---')
        
        # Calculate daily averages
        readings_by_day = {}
        for reading in GasReading.objects.filter(sensor=sensor).order_by('reading_timestamp'):
            day_key = reading.reading_timestamp.date()
            if day_key not in readings_by_day:
                readings_by_day[day_key] = []
            readings_by_day[day_key].append(reading.remaining_gas)
        
        # Show consumption pattern
        for day, levels in list(readings_by_day.items())[-7:]:  # Last 7 days
            daily_consumption = max(levels) - min(levels) if len(levels) > 1 else 0
            day_type = "Weekend" if day.weekday() >= 5 else "Weekday"
            self.stdout.write(
                f'{day.strftime("%Y-%m-%d")} ({day_type}): '
                f'{daily_consumption:.1f}% consumed'
            )
        
        self.stdout.write(f'\nLatest reading: {latest_reading.remaining_gas}% at {latest_reading.reading_timestamp.strftime("%Y-%m-%d %H:%M")}')
