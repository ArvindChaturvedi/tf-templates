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
    print(f"Request params: {params}")
    print(f"Response status: {response.status_code}")
    
    response.raise_for_status()  # Raise an exception for bad status codes
    return response.json()

def get_all_metrics():
    url = f"{BASE_URL}/v2/metric"
    all_metrics = []
    offset = 0
    limit = 1000  # Adjust this value if needed
    total_metrics = None

    while True:
        params = {
            "offset": offset,
            "limit": limit
        }
        response_data = make_request("GET", url, params=params)
        metrics = response_data.get('results', [])
        all_metrics.extend(metrics)
        
        if total_metrics is None:
            total_metrics = response_data.get('count')
            print(f"Total metrics reported by API: {total_metrics}")

        print(f"Retrieved {len(metrics)} metrics in this batch. Total retrieved so far: {len(all_metrics)}")
        
        if len(metrics) < limit:
            break

        offset += limit

    return all_metrics, total_metrics

def main():
    print("Fetching all metrics...")
    try:
        all_metrics, total_metrics = get_all_metrics()
        print(f"\nSuccessfully retrieved {len(all_metrics)} metrics in total.")
        print(f"Total metrics reported by API: {total_metrics}")
        
        if len(all_metrics) < total_metrics:
            print(f"Warning: Retrieved fewer metrics than reported by the API.")
        elif len(all_metrics) > total_metrics:
            print(f"Warning: Retrieved more metrics than initially reported by the API.")
        
        print("\nFirst 5 metrics:")
        for metric in all_metrics[:5]:
            print(f"- {metric['name']}")
        print(f"\nLast 5 metrics:")
        for metric in all_metrics[-5:]:
            print(f"- {metric['name']}")
    except requests.exceptions.RequestException as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()