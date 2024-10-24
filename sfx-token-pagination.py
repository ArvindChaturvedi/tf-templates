import urllib3
import json
import certifi
import os

# Get the token from environment variable
TOKEN = os.environ.get('YOUR_TOKEN')
if not TOKEN:
    print("Error: YOUR_TOKEN environment variable is not set.")
    exit(1)

REALM = "YOUR_REALM"  # Replace this with your actual realm

https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())
base_url = f"https://api.{REALM}.signalfx.com"

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

def make_request(url):
    try:
        response = https.request('GET', url, headers=headers, timeout=10.0)
        if response.status == 200:
            return response.status, json.loads(response.data.decode('utf-8'))
        else:
            return response.status, response.data.decode('utf-8')
    except Exception as e:
        return None, f"Error: {str(e)}"

def get_all_metrics():
    all_metrics = []
    offset = 0
    limit = 1000  # Adjust this value if needed

    while True:
        url = f"{base_url}/v2/metric?limit={limit}&offset={offset}"
        status, data = make_request(url)

        if status != 200:
            print(f"Failed to retrieve metrics. Status: {status}")
            print(f"Response: {data}")
            break

        if not isinstance(data, dict) or 'results' not in data:
            print("Unexpected response format")
            break

        metrics = data['results']
        all_metrics.extend(metrics)
        
        if len(metrics) < limit:
            break

        offset += limit
        print(f"Retrieved {len(all_metrics)} metrics so far...")

    return all_metrics

print("Retrieving all metrics accessible via SignalFlow")
print("================================================")

metrics = get_all_metrics()

print(f"\nTotal metrics retrieved: {len(metrics)}")
print("\nList of all metrics:")
for i, metric in enumerate(metrics, 1):
    print(f"{i}. {metric['name']}")
    if 'description' in metric and metric['description']:
        print(f"   Description: {metric['description']}")
    print(f"   Type: {metric.get('type', 'N/A')}")
    print(f"   Custom: {metric.get('custom', 'N/A')}")
    print()

print("\nRetrieval Complete")