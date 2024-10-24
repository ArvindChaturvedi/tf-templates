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

def get_all_metrics():
    url = f"{BASE_URL}/v2/metric"
    all_metrics = []
    offset = 0
    limit = 1000  # Adjust this value if needed

    while True:
        params = {
            "offset": offset,
            "limit": limit
        }
        response_data = make_request("GET", url, params=params)
        metrics = response_data.get('results', [])
        all_metrics.extend(metrics)
        
        if len(metrics) < limit:
            break

        offset += limit
        print(f"Retrieved {len(all_metrics)} metrics so far...")

    return all_metrics

def main():
    print("Fetching all metrics...")
    try:
        all_metrics = get_all_metrics()
        print(f"Successfully retrieved {len(all_metrics)} metrics in total.")
        print("First 5 metrics:")
        for metric in all_metrics[:5]:
            print(f"- {metric['name']}")
        print(f"\nLast 5 metrics:")
        for metric in all_metrics[-5:]:
            print(f"- {metric['name']}")
    except requests.exceptions.RequestException as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()