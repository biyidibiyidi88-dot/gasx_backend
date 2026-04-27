#!/usr/bin/env python3
"""
Gas Monitor - Realistic Test Data Generator

This script generates one month of realistic gas readings that mimic
how the optimized ESP32 code would record data:
- Only sends when weight change >= 0.1kg
- Minimum 30 seconds between readings
- Realistic consumption patterns (cooking times, weekend usage)
- Gradual tank depletion over time

Usage:
    python3 generate_test_data.py [--days DAYS] [--sensor-id SENSOR_ID]
"""

import requests
import json
import random
import argparse
from datetime import datetime, timedelta
import time
import math

# Configuration
API_BASE_URL = "http://127.0.0.1:8000/api"
API_TOKEN = "84eae07987192e82a910087ba4112cc7f29055fd"
DEFAULT_SENSOR_ID = 13

# Default Tank specifications
DEFAULT_TARE = 12.5  # kg
DEFAULT_CAPACITY = 12.5  # kg

# ESP32 behavior simulation
MIN_WEIGHT_CHANGE = 0.1  # kg - minimum change to trigger reading
MIN_READING_INTERVAL = 30  # seconds - minimum time between readings

def generate_realistic_consumption_pattern():
    """
    Generate realistic daily gas consumption patterns.
    Returns consumption events throughout the day.
    """
    events = []
    
    # Morning cooking (6-9 AM) - moderate usage
    morning_events = random.randint(1, 3)
    for _ in range(morning_events):
        hour = random.randint(6, 8)
        minute = random.randint(0, 59)
        consumption = random.uniform(0.1, 0.4)  # 0.1-0.4kg per cooking session
        events.append((hour, minute, consumption))
    
    # Lunch time (11 AM - 2 PM) - light usage
    if random.random() < 0.6:  # 60% chance of lunch cooking
        hour = random.randint(11, 13)
        minute = random.randint(0, 59)
        consumption = random.uniform(0.05, 0.2)  # Light cooking
        events.append((hour, minute, consumption))
    
    # Evening cooking (5-8 PM) - heavy usage
    evening_events = random.randint(1, 4)
    for _ in range(evening_events):
        hour = random.randint(17, 19)
        minute = random.randint(0, 59)
        consumption = random.uniform(0.2, 0.8)  # Heavier cooking
        events.append((hour, minute, consumption))
    
    # Late evening (8-10 PM) - occasional usage
    if random.random() < 0.3:  # 30% chance
        hour = random.randint(20, 21)
        minute = random.randint(0, 59)
        consumption = random.uniform(0.1, 0.3)
        events.append((hour, minute, consumption))
    
    return sorted(events)

def should_send_reading(current_weight, last_sent_weight, time_since_last):
    """
    Simulate ESP32 logic for deciding when to send readings.
    """
    # Check minimum time interval
    if time_since_last < MIN_READING_INTERVAL:
        return False
    
    # Check weight change threshold
    weight_change = abs(current_weight - last_sent_weight)
    if weight_change < MIN_WEIGHT_CHANGE:
        return False
    
    return True

def generate_month_data(start_date, days=30, sensor_id=DEFAULT_SENSOR_ID, capacity=DEFAULT_CAPACITY, tare=DEFAULT_TARE):
    """
    Generate realistic gas readings for the specified period.
    """
    readings = []
    current_date = start_date
    
    # Start with a nearly full tank (80-100% of capacity)
    current_gas_weight = random.uniform(capacity * 0.8, capacity)
    current_total_weight = tare + current_gas_weight
    last_sent_weight = current_total_weight
    last_reading_time = 0
    
    print(f"🏁 Starting simulation:")
    print(f"   📅 Period: {days} days from {start_date.strftime('%Y-%m-%d')}")
    print(f"   ⛽ Initial gas: {current_gas_weight:.2f}kg ({(current_gas_weight/capacity)*100:.1f}%)")
    print(f"   📊 Sensor ID: {sensor_id}")
    print(f"   🎛️  Bottle: {capacity}kg Capacity, {tare}kg Tare")
    print()
    
    for day in range(days):
        current_date = start_date + timedelta(days=day)
        is_weekend = current_date.weekday() >= 5  # Saturday = 5, Sunday = 6
        
        # Weekend usage is typically 20-40% higher
        usage_multiplier = random.uniform(1.2, 1.4) if is_weekend else 1.0
        
        # Generate consumption events for the day
        consumption_events = generate_realistic_consumption_pattern()
        
        # Apply weekend multiplier
        consumption_events = [
            (hour, minute, consumption * usage_multiplier)
            for hour, minute, consumption in consumption_events
        ]
        
        daily_consumption = 0
        day_readings = 0
        
        # Process each consumption event
        for hour, minute, consumption in consumption_events:
            # Consume gas
            current_gas_weight = max(0, current_gas_weight - consumption)
            current_total_weight = tare + current_gas_weight
            daily_consumption += consumption
            
            # Create timestamp for this event
            event_time = current_date.replace(hour=hour, minute=minute, second=random.randint(0, 59))
            current_timestamp = event_time.timestamp()
            
            # Check if ESP32 would send this reading
            time_since_last = current_timestamp - last_reading_time
            
            if should_send_reading(current_total_weight, last_sent_weight, time_since_last):
                # Round to 2 decimal places (matching ESP32 behavior)
                gas_weight_rounded = round(current_gas_weight, 2)
                
                reading = {
                    "sensor": sensor_id,
                    "remaining_gas": gas_weight_rounded,
                    "reading_timestamp": event_time.isoformat(),
                    "is_weekend": is_weekend,
                    "daily_consumption": round(daily_consumption, 2)
                }
                
                readings.append(reading)
                last_sent_weight = current_total_weight
                last_reading_time = current_timestamp
                day_readings += 1
        
        # Progress update
        gas_percentage = (current_gas_weight / capacity) * 100
        print(f"📅 Day {day+1:2d} ({current_date.strftime('%Y-%m-%d')}): "
              f"{current_gas_weight:5.2f}kg ({gas_percentage:5.1f}%) | "
              f"Consumed: {daily_consumption:.2f}kg | "
              f"Readings: {day_readings}")
        
        # Stop if tank is empty
        if current_gas_weight <= 0.5:  # Nearly empty
            print(f"⚠️  Tank nearly empty after {day+1} days!")
            break
    
    print(f"\n📊 Generated {len(readings)} readings over {day+1} days")
    return readings

def upload_readings_to_backend(readings, batch_size=10):
    """
    Upload readings to the backend API in batches.
    """
    headers = {
        "Authorization": f"Token {API_TOKEN}",
        "Content-Type": "application/json"
    }
    
    url = f"{API_BASE_URL}/gas-readings/create/"
    
    print(f"\n🚀 Uploading {len(readings)} readings to backend...")
    print(f"   🌐 Endpoint: {url}")
    print(f"   📦 Batch size: {batch_size}")
    print()
    
    successful_uploads = 0
    failed_uploads = 0
    
    for i in range(0, len(readings), batch_size):
        batch = readings[i:i+batch_size]
        batch_num = (i // batch_size) + 1
        total_batches = math.ceil(len(readings) / batch_size)
        
        print(f"📦 Batch {batch_num}/{total_batches} ({len(batch)} readings)...")
        
        for reading in batch:
            try:
                # Prepare payload with historical timestamp for test data
                payload = {
                    "sensor": reading["sensor"],
                    "remaining_gas": reading["remaining_gas"],
                    "reading_timestamp": reading["reading_timestamp"]
                }
                
                response = requests.post(url, headers=headers, json=payload, timeout=10)
                
                if response.status_code in [200, 201]:
                    successful_uploads += 1
                    print(f"   ✅ {reading['reading_timestamp']}: {reading['remaining_gas']}kg")
                else:
                    failed_uploads += 1
                    print(f"   ❌ {reading['reading_timestamp']}: HTTP {response.status_code}")
                
                # Small delay to avoid overwhelming the server
                time.sleep(0.1)
                
            except requests.exceptions.Timeout:
                failed_uploads += 1
                print(f"   ⏰ {reading['reading_timestamp']}: Timeout")
            except Exception as e:
                failed_uploads += 1
                print(f"   💥 {reading['reading_timestamp']}: {str(e)}")
        
        # Longer delay between batches
        if i + batch_size < len(readings):
            print(f"   ⏸️  Waiting 2 seconds before next batch...")
            time.sleep(2)
    
    print(f"\n📊 Upload Summary:")
    print(f"   ✅ Successful: {successful_uploads}")
    print(f"   ❌ Failed: {failed_uploads}")
    print(f"   📈 Success Rate: {(successful_uploads/(successful_uploads+failed_uploads))*100:.1f}%")
    
    return successful_uploads, failed_uploads

def main():
    parser = argparse.ArgumentParser(
        description="Generate realistic test data for Gas Monitor dashboard",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        "--days", 
        type=int, 
        default=30,
        help="Number of days to generate data for (default: 30)"
    )
    
    parser.add_argument(
        "--sensor-id", 
        type=int, 
        default=DEFAULT_SENSOR_ID,
        help=f"Sensor ID to use (default: {DEFAULT_SENSOR_ID})"
    )
    
    parser.add_argument(
        "--start-date", 
        type=str,
        default=None,
        help="Start date (YYYY-MM-DD). Default: 30 days ago"
    )
    
    parser.add_argument(
        "--capacity", 
        type=float, 
        default=DEFAULT_CAPACITY,
        help=f"Gas capacity in kg (default: {DEFAULT_CAPACITY})"
    )
    
    parser.add_argument(
        "--tare", 
        type=float, 
        default=DEFAULT_TARE,
        help=f"Empty bottle weight in kg (default: {DEFAULT_TARE})"
    )
    
    parser.add_argument(
        "--dry-run", 
        action="store_true",
        help="Generate data but don't upload to backend"
    )
    
    args = parser.parse_args()
    
    # Determine start date
    if args.start_date:
        start_date = datetime.strptime(args.start_date, "%Y-%m-%d")
    else:
        # Start from 30 days ago to create historical data
        start_date = datetime.now() - timedelta(days=args.days)
    
    print("🧪 Gas Monitor - Realistic Test Data Generator")
    print("=" * 55)
    
    # Generate realistic data
    readings = generate_month_data(start_date, args.days, args.sensor_id, args.capacity, args.tare)
    
    if not readings:
        print("❌ No readings generated!")
        return
    
    if args.dry_run:
        print(f"\n🔍 Dry run mode - generated {len(readings)} readings")
        print("📄 Sample readings:")
        for i, reading in enumerate(readings[:5]):
            print(f"   {i+1}. {reading['reading_timestamp']}: {reading['remaining_gas']}kg")
        if len(readings) > 5:
            print(f"   ... and {len(readings)-5} more")
        return
    
    # Upload to backend
    successful, failed = upload_readings_to_backend(readings)
    
    if successful > 0:
        print(f"\n🎉 Successfully uploaded {successful} readings!")
        print("💡 Check your dashboard to see the realistic consumption trends.")
        print("🤖 AI predictions should now work with quality historical data.")
    else:
        print(f"\n💥 Upload failed! Please check your connection and API token.")

if __name__ == "__main__":
    main()
