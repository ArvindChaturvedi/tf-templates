import urllib3
import json
import certifi
from datetime import datetime, timedelta

REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())

def make_request(method, url, body=None):
    try:
        response = https.request(method, url, body=json.dumps(body).encode('utf-8') if body else None, headers=headers)
        print(f"URL: {url}")
        print(f"Response status: {response.status}")
        return response.status, response.data
    except Exception as e:
        print(f"An error occurred: {e}")
        return None, str(e)

# List of possible base URLs to try
base_urls = [
    f"https://stream.{REALM}.signalfx.com",
    f"https://api.{REALM}.signalfx.com",
    f"https://{REALM}.signalfx.com",
    f"https://ingest.{REALM}.signalfx.com"
]

program_text = """
data('container_cpu_utilization', filter=filter('kubernetes_cluster', '*'))
.max(by=['kubernetes_cluster', 'kubernetes_pod_name'])
.publish()
"""

for base_url in base_urls:
    print(f"\nTrying base URL: {base_url}")
    
    # Try SignalFlow endpoint
    signalflow_url = f"{base_url}/v2/signalflow"
    status, data = make_request('POST', signalflow_url, {"program": program_text})
    
    if status == 200:
        print("Successfully connected to SignalFlow API")
        # Process the data here
        break
    
    # If SignalFlow fails, try the execute endpoint
    execute_url = f"{base_url}/v2/signalflow/execute"
    status, data = make_request('POST', execute_url, {"programText": program_text})
    
    if status == 200:
        print("Successfully connected to SignalFlow execute API")
        # Process the data here
        break

else:
    print("Failed to connect to any API endpoint")

# If a successful connection was made, process and print the results here