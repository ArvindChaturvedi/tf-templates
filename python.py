import urllib3
import json
import certifi
import ssl
from datetime import datetime, timedelta

# Configuration
REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"
API_ENDPOINT = f"https://api.{REALM}.signalfx.com/v2/signalflow/execute"

# Print SSL debugging information
print(f"Python SSL version: {ssl.OPENSSL_VERSION}")
print(f"Certifi version: {certifi.__version__}")
print(f"Certifi path: {certifi.where()}")
print(f"urllib3 version: {urllib3.__version__}")

# Calculate the time range (last 90 days)
end_time = datetime.utcnow()
start_time = end_time - timedelta(days=90)

# SignalFlow program to fetch container CPU utilization
program_text = f"""
start_ms = {int(start_time.timestamp() * 1000)}
end_ms = {int(end_time.timestamp() * 1000)}

data('container_cpu_utilization', filter=filter('kubernetes_cluster', '*'))
.max(by=['kubernetes_cluster', 'kubernetes_pod_name'])
.publish()
"""

# Prepare the request payload
payload = {
    "programText": program_text,
}

# Set up headers
headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

def make_request(pool_manager):
    try:
        response = pool_manager.request('POST', API_ENDPOINT, 
                                        body=json.dumps(payload).encode('utf-8'),
                                        headers=headers)
        if response.status == 200:
            return json.loads(response.data.decode('utf-8'))
        else:
            print(f"Error: HTTP {response.status}")
            print(f"Response: {response.data.decode('utf-8')}")
            return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

# Make the API request
https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())
data = make_request(https)

if data:
    # Initialize a dictionary to store max CPU utilization by cluster and pod
    max_cpu_utilization = {}

    for tsid, ts_data in data.get("data", {}).items():
        metadata = ts_data.get("metadata", {})
        cluster = metadata.get("kubernetes_cluster", "unknown")
        pod = metadata.get("kubernetes_pod_name", "unknown")
        
        # Find the maximum CPU utilization for this pod
        max_value = max(ts_data.get("values", [0]))
        
        # Update the max CPU utilization for this pod
        if cluster not in max_cpu_utilization:
            max_cpu_utilization[cluster] = {}
        max_cpu_utilization[cluster][pod] = max_value

    # Print the results
    print("Maximum CPU Utilization by Cluster and Pod (last 90 days):")