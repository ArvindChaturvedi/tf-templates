import requests
import json

REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"
API_ENDPOINT = f"https://api.{REALM}.signalfx.com/v2/metric"

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

try:
    response = requests.get(API_ENDPOINT, headers=headers)
    response.raise_for_status()
    metrics = response.json()
    print(json.dumps(metrics, indent=2))
except requests.exceptions.RequestException as e:
    print(f"An error occurred: {e}")
    if hasattr(e, 'response') and e.response is not None:
        print(f"Error response content: {e.response.text}")