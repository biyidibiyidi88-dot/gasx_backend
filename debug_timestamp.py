import requests
import json
from datetime import datetime
import pytz

# Test 1: Manual timestamp (this worked before)
url = "https://gas-monitor-sfk3.onrender.com/api/gas-readings/create/"
headers = {
    "Authorization": "Token 972e4539789c26414553c450b2994111b7ebccae",
    "Content-Type": "application/json"
}

# Test payload with historical timestamp
test_payload = {
    "sensor": 13,
    "remaining_gas": 12.34,
    "reading_timestamp": "2025-07-20T15:30:00Z"
}

print("🧪 Testing manual timestamp format...")
print(f"Payload: {json.dumps(test_payload, indent=2)}")

response = requests.post(url, headers=headers, json=test_payload)
print(f"Status: {response.status_code}")
print(f"Response: {response.json()}")

# Test 2: Generator format (mimicking our test data generator)
utc = pytz.UTC
event_time = datetime(2025, 7, 21, 10, 45, 30)
event_time_utc = utc.localize(event_time)

generator_payload = {
    "sensor": 13,
    "remaining_gas": 11.22,
    "reading_timestamp": event_time_utc.isoformat(),
    "is_weekend": False,
    "daily_consumption": 1.5
}

print(f"\n🧪 Testing generator timestamp format...")
print(f"Payload: {json.dumps(generator_payload, indent=2)}")

response2 = requests.post(url, headers=headers, json=generator_payload)
print(f"Status: {response2.status_code}")
print(f"Response: {response2.json()}")
