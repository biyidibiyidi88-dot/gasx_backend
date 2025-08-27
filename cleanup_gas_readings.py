#!/usr/bin/env python3
"""
Cleanup script for Gas Monitor gas readings.
This script allows you to delete gas readings from the database.
"""
import os
import sys
import requests
from datetime import datetime, timedelta

def get_auth_headers():
    """Return authentication headers with API token."""
    token = "972e4539789c26414553c450b2994111b7ebccae"  # User's API token
    return {
        "Authorization": f"Token {token}",
        "Content-Type": "application/json"
    }

def get_base_url():
    """Return the base API URL."""
    return "https://gas-monitor-sfk3.onrender.com/api"

def get_gas_readings():
    """Fetch all gas readings from the API."""
    url = f"{get_base_url()}/gas-readings/"
    response = requests.get(url, headers=get_auth_headers())
    if response.status_code == 200:
        return response.json()
    print(f"Error fetching gas readings: {response.status_code} - {response.text}")
    return []

def delete_gas_readings(sensor_id=None):
    """Delete gas readings, optionally filtered by sensor_id."""
    url = f"{get_base_url()}/gas-readings/bulk-delete/"
    
    # Prepare the request payload
    payload = {}
    if sensor_id:
        payload["sensor_id"] = sensor_id
    
    # Add confirmation prompt
    if sensor_id:
        confirm = input(f"Are you sure you want to delete all readings for sensor {sensor_id}? (y/n): ")
    else:
        confirm = input("WARNING: This will delete ALL gas readings. Are you sure? (y/n): ")
    
    if confirm.lower() != 'y':
        print("Operation cancelled.")
        return False
    
    # Make the DELETE request
    response = requests.delete(url, headers=get_auth_headers(), json=payload)
    
    if response.status_code == 200:
        result = response.json()
        print(f"Successfully deleted {result.get('deleted_count', 0)} gas readings")
        if 'error' in result:
            print(f"Warning: {result['error']}")
        return True
    else:
        print(f"Error deleting gas readings: {response.status_code} - {response.text}")
        return False

def list_sensors():
    """List all available gas sensors."""
    url = f"{get_base_url()}/sensors/"
    response = requests.get(url, headers=get_auth_headers())
    
    if response.status_code == 200:
        sensors = response.json()
        if not sensors:
            print("No sensors found.")
            return []
        
        print("\nAvailable Sensors:")
        print("-" * 50)
        for sensor in sensors:
            print(f"ID: {sensor.get('id')}")
            print(f"Name: {sensor.get('name')}")
            print(f"Type: {sensor.get('gas_type')}")
            print(f"Location: {sensor.get('location', 'N/A')}")
            print("-" * 50)
        return sensors
    else:
        print(f"Error fetching sensors: {response.status_code} - {response.text}")
        return []

def main():
    print("Gas Monitor - Gas Readings Cleanup Tool")
    print("=" * 50)
    
    while True:
        print("\nOptions:")
        print("1. List all gas readings")
        print("2. List all sensors")
        print("3. Delete all gas readings")
        print("4. Delete readings for a specific sensor")
        print("5. Exit")
        
        choice = input("\nEnter your choice (1-5): ").strip()
        
        if choice == '1':
            print("\nFetching gas readings...")
            readings = get_gas_readings()
            if readings:
                print(f"\nFound {len(readings)} gas readings:")
                for reading in readings[:5]:  # Show first 5 readings to avoid overwhelming output
                    print(f"- ID: {reading.get('id')}, Sensor: {reading.get('sensor')}, Remaining: {reading.get('remaining_gas')}kg, Date: {reading.get('reading_timestamp')}")
                if len(readings) > 5:
                    print(f"... and {len(readings) - 5} more readings")
            else:
                print("No gas readings found.")
                
        elif choice == '2':
            list_sensors()
            
        elif choice == '3':
            delete_gas_readings()
            
        elif choice == '4':
            sensors = list_sensors()
            if sensors:
                try:
                    sensor_id = int(input("\nEnter the sensor ID to delete readings for: "))
                    delete_gas_readings(sensor_id)
                except ValueError:
                    print("Invalid sensor ID. Please enter a number.")
        
        elif choice == '5':
            print("Exiting cleanup tool.")
            break
            
        else:
            print("Invalid choice. Please enter a number between 1 and 5.")

if __name__ == "__main__":
    main()
