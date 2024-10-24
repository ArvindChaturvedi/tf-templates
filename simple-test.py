import requests
import os
from datetime import datetime, timedelta

# Configuration
REALM = "YOUR_REALM"  # Replace with your realm
TOKEN = os.environ.get('YOUR_TOKEN')
if not TOKEN:
    raise ValueError("Error: YOUR_TOKEN environment variable is not set.")

BASE_URL = f"https://api.{REALM}.signalfx.com"

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

def make_request(method, url, params=None, data=None):
    response = requests.request(method, url, headers=headers, params=params, json=data)
    print(f"Request URL: {response.url}")
    print(f"Request method: {method}")
    print(f"Request body: {data}")
    print(f"Response status: {response.status_code}")
    print(f"Response headers: {response.headers}")
    print(f"Response content: {response.text[:200]}...")  # Print first 200 characters
    
    response.raise_for_status()  # Raise an exception for bad status codes
    return response.json()

def get_metric_list():
    url = f"{BASE_URL}/v2/metric"
    return make_request("GET", url)

def main():
    print("Fetching list of metrics...")
    try:
        metrics = get_metric_list()
        print(f"Successfully retrieved {len(metrics['results'])} metrics.")
        print("First 5 metrics:")
        for metric in metrics['results'][:5]:
            print(f"- {metric['name']}")
    except requests.exceptions.RequestException as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()