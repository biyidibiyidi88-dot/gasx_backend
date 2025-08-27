#!/usr/bin/env python3
"""
Gas Monitor - Precise 10-Day Test Cycle with Refill

Simulates:
1. Full depletion in 6 days (100% → 0%)
2. Refill to 100%
3. Partial depletion in 4 days (100% → 40%)

Usage: echo "y" | python3 generate_test_data_with_refills.py --sensor-id 13 --start-date 2025-08-05
   
"""

import requests
import random
import argparse
from datetime import datetime, timedelta
import time

# Configuration
API_BASE_URL = "https://gas-monitor-sfk3.onrender.com/api"
API_TOKEN = "972e4539789c26414553c450b2994111b7ebccae"
DEFAULT_SENSOR_ID = 13

# Tank specifications
TANK_CAPACITY = 20.0  # kg of gas
DAILY_DEPLETION_PHASE1 = TANK_CAPACITY / 6  # ~3.33kg/day (0% in 6 days)
DAILY_DEPLETION_PHASE2 = (TANK_CAPACITY * 0.6) / 4  # 3kg/day (40% in 4 days)

def generate_test_cycle(start_date, sensor_id):
    """Generate the precise 10-day test cycle with realistic data"""
    readings = []
    current_date = start_date
    current_gas = TANK_CAPACITY  # Start at 100%
    num_readings_per_day = 3

    print("🔧 Gas Monitor - Precise 10-Day Test Cycle")
    print("=" * 60)
    print(f"📅 Start Date: {start_date.strftime('%Y-%m-%d')}")
    print(f"🔋 Phase 1: 6 days (100% → 0%)")
    print(f"⛽ Refill: 0% → 100%")
    print(f"📉 Phase 2: 4 days (100% → 40%)")
    print(f"📊 Sensor ID: {sensor_id}")
    print()

    # Phase 1: Full depletion in 6 days
    print("📉 PHASE 1: Full Depletion")
    per_reading_depletion_p1 = DAILY_DEPLETION_PHASE1 / num_readings_per_day
    for day in range(6):
        current_date = start_date + timedelta(days=day)
        print(f"  Day {day+1} ({current_date.strftime('%Y-%m-%d')}):")
        for i in range(num_readings_per_day):
            # Consume gas before creating the reading
            consumption = per_reading_depletion_p1 * random.uniform(0.9, 1.1)
            current_gas = max(0, current_gas - consumption)
            
            reading_time = current_date.replace(hour=8 + i * 6, minute=random.randint(0, 59))
            reading = {
                "sensor": sensor_id,
                "remaining_gas": round(current_gas, 2),
                "reading_timestamp": reading_time.isoformat() + "Z",
            }
            readings.append(reading)
            print(f"    - Reading at {reading_time.strftime('%H:%M')}: {reading['remaining_gas']:.2f}kg ({(reading['remaining_gas']/TANK_CAPACITY)*100:.1f}%)")

    # Refill to 100%
    print("\n⛽ REFILL EVENT")
    refill_date = current_date + timedelta(days=1)
    current_gas = TANK_CAPACITY
    refill_reading = {
        "sensor": sensor_id,
        "remaining_gas": round(current_gas, 2),
        "reading_timestamp": refill_date.replace(hour=10, minute=0).isoformat() + "Z",
    }
    readings.append(refill_reading)
    print(f"  Refilled to {refill_reading['remaining_gas']:.2f}kg (100%) at {refill_date.date()} 10:00:00")

    # Phase 2: Partial depletion in 4 days
    print("\n📉 PHASE 2: Partial Depletion")
    per_reading_depletion_p2 = DAILY_DEPLETION_PHASE2 / num_readings_per_day
    for day in range(4):
        # Start day count from where phase 1 left off
        current_day_num = day + 7
        current_date = refill_date + timedelta(days=day)
        print(f"  Day {current_day_num} ({current_date.strftime('%Y-%m-%d')}):")
        for i in range(num_readings_per_day):
            consumption = per_reading_depletion_p2 * random.uniform(0.9, 1.1)
            current_gas = max(TANK_CAPACITY * 0.4, current_gas - consumption)
            
            reading_time = current_date.replace(hour=8 + i * 6, minute=random.randint(0, 59))
            reading = {
                "sensor": sensor_id,
                "remaining_gas": round(current_gas, 2),
                "reading_timestamp": reading_time.isoformat() + "Z",
            }
            readings.append(reading)
            print(f"    - Reading at {reading_time.strftime('%H:%M')}: {reading['remaining_gas']:.2f}kg ({(reading['remaining_gas']/TANK_CAPACITY)*100:.1f}%)")

    print(f"\n✅ Test cycle complete with {len(readings)} readings")
    return readings

def upload_readings(readings):
    """Upload readings to backend"""
    headers = {
        "Authorization": f"Token {API_TOKEN}",
        "Content-Type": "application/json"
    }
    
    successful = 0
    for reading in readings:
        try:
            response = requests.post(
                f"{API_BASE_URL}/gas-readings/create/",
                headers=headers,
                json=reading,
                timeout=10
            )
            if response.status_code in [200, 201]:
                successful += 1
            print(f"  {'✅' if response.ok else '❌'} {reading['reading_timestamp']}: {reading['remaining_gas']}kg")
        except Exception as e:
            print(f"  ❌ Error: {str(e)}")
        time.sleep(0.1)
    
    return successful, len(readings) - successful

def main():
    parser = argparse.ArgumentParser(description="Run precise 10-day test cycle")
    parser.add_argument("--sensor-id", type=int, default=DEFAULT_SENSOR_ID,
                      help=f"Sensor ID (default: {DEFAULT_SENSOR_ID})")
    parser.add_argument("--start-date", required=True,
                      help="Start date (YYYY-MM-DD)")
    
    args = parser.parse_args()
    
    try:
        start_date = datetime.strptime(args.start_date, "%Y-%m-%d")
    except ValueError:
        print("Invalid date format. Use YYYY-MM-DD")
        return
    
    print(f"🚀 Starting 10-day test cycle for sensor {args.sensor_id}")
    readings = generate_test_cycle(start_date, args.sensor_id)
    
    if not readings:
        print("❌ No readings generated!")
        return
    
    print("\n🌐 Uploading to backend...")
    success, failed = upload_readings(readings)
    
    print(f"\n📊 Upload Summary:")
    print(f"  ✅ Successful: {success}")
    print(f"  ❌ Failed: {failed}")
    print(f"  🎉 Success rate: {success/(success+failed)*100:.1f}%")

if __name__ == "__main__":
    main()