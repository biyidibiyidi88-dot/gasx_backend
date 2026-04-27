#!/usr/bin/env python3
"""
Gas Monitor - Bulk Delete Faulty Readings Script

This script clears all faulty gas readings from the backend database
using the new bulk delete API endpoint.

Usage:
    python3 cleanup_faulty_readings.py [--sensor-id SENSOR_ID]

Examples:
    python3 cleanup_faulty_readings.py                    # Delete all readings
    python3 cleanup_faulty_readings.py --sensor-id 13     # Delete only sensor 13 readings
"""

import requests
import argparse
import sys
from datetime import datetime

# Configuration
API_BASE_URL = "http://127.0.0.1:8000/api"
API_TOKEN = "84eae07987192e82a910087ba4112cc7f29055fd"

def clear_gas_readings(sensor_id=None):
    """
    Clear gas readings using the bulk delete endpoint.
    
    Args:
        sensor_id (int, optional): If provided, only delete readings for this sensor
    
    Returns:
        dict: API response
    """
    url = f"{API_BASE_URL}/gas-readings/bulk-delete/"
    
    headers = {
        "Authorization": f"Token {API_TOKEN}",
        "Content-Type": "application/json"
    }
    
    params = {}
    if sensor_id:
        params["sensor"] = sensor_id
    
    try:
        print(f"🗑️  Clearing gas readings...")
        if sensor_id:
            print(f"   📍 Target: Sensor ID {sensor_id}")
        else:
            print(f"   📍 Target: ALL sensors")
        
        print(f"   🌐 Endpoint: {url}")
        print(f"   ⏰ Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
        
        response = requests.delete(url, headers=headers, params=params, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            print("✅ SUCCESS!")
            print(f"   📊 Deleted: {data.get('deleted_count', 0)} readings")
            print(f"   💬 Message: {data.get('message', 'No message')}")
            return data
        else:
            print(f"❌ ERROR: HTTP {response.status_code}")
            try:
                error_data = response.json()
                print(f"   💬 Message: {error_data.get('message', 'Unknown error')}")
                if 'error' in error_data:
                    print(f"   🔍 Details: {error_data['error']}")
            except:
                print(f"   💬 Response: {response.text}")
            return None
            
    except requests.exceptions.Timeout:
        print("❌ ERROR: Request timed out (30 seconds)")
        print("   💡 The backend might be sleeping. Try again in a few minutes.")
        return None
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Connection failed")
        print("   💡 Check your internet connection and backend URL")
        return None
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")
        return None

def check_readings_count(sensor_id=None):
    """
    Check how many readings exist before deletion.
    
    Args:
        sensor_id (int, optional): If provided, only count readings for this sensor
    
    Returns:
        int: Number of readings found
    """
    url = f"{API_BASE_URL}/gas-readings/"
    
    headers = {
        "Authorization": f"Token {API_TOKEN}",
        "Content-Type": "application/json"
    }
    
    params = {}
    if sensor_id:
        params["sensor"] = sensor_id
    
    try:
        response = requests.get(url, headers=headers, params=params, timeout=15)
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list):
                return len(data)
            else:
                return 0
        else:
            print(f"⚠️  Warning: Could not check readings count (HTTP {response.status_code})")
            return -1
    except Exception as e:
        print(f"⚠️  Warning: Could not check readings count ({str(e)})")
        return -1

def main():
    parser = argparse.ArgumentParser(
        description="Clear faulty gas readings from the Gas Monitor backend",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 cleanup_faulty_readings.py                    # Delete all readings
  python3 cleanup_faulty_readings.py --sensor-id 13     # Delete only sensor 13 readings
        """
    )
    
    parser.add_argument(
        "--sensor-id", 
        type=int, 
        help="Only delete readings for this specific sensor ID"
    )
    
    parser.add_argument(
        "--dry-run", 
        action="store_true", 
        help="Check readings count without deleting"
    )
    
    args = parser.parse_args()
    
    print("🧹 Gas Monitor - Faulty Readings Cleanup Tool")
    print("=" * 50)
    
    # Check current readings count
    print("📊 Checking current readings...")
    count = check_readings_count(args.sensor_id)
    if count >= 0:
        if args.sensor_id:
            print(f"   Found {count} readings for sensor {args.sensor_id}")
        else:
            print(f"   Found {count} total readings")
    
    if count == 0:
        print("✨ No readings found to delete!")
        return
    
    if args.dry_run:
        print("🔍 Dry run mode - no deletion performed")
        return
    
    # Confirm deletion
    if count > 0:
        print()
        if args.sensor_id:
            confirm_msg = f"Delete {count} readings for sensor {args.sensor_id}?"
        else:
            confirm_msg = f"Delete ALL {count} readings?"
        
        confirm = input(f"⚠️  {confirm_msg} (y/N): ").strip().lower()
        if confirm not in ['y', 'yes']:
            print("❌ Deletion cancelled by user")
            return
    
    # Perform deletion
    print()
    result = clear_gas_readings(args.sensor_id)
    
    if result:
        print()
        print("🎉 Cleanup completed successfully!")
        print("💡 You can now upload your optimized ESP32 code for clean data collection.")
    else:
        print()
        print("💥 Cleanup failed. Please check the error messages above.")
        sys.exit(1)

if __name__ == "__main__":
    main()
