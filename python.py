import urllib3
import json
import certifi
from datetime import datetime, timedelta

REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"
BASE_URL = f"https://api.{REALM}.signalfx.com"

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())

def make_request(method, url, body=None):
    try:
        response = https.request(method, url, body=json.dumps(body).encode('utf-8') if body else None, headers=headers)
        print(f"Response status: {response.status}")
        return response.status, json.loads(response.data.decode('utf-8'))
    except Exception as e:
        print(f"An error occurred: {e}")
        return None, str(e)

# Check if the metric exists
metric_url = f"{BASE_URL}/v2/metric/container_cpu_utilization"
status, data = make_request('GET', metric_url)

if status != 200:
    print(f"Error: Metric 'container_cpu_utilization' not found. Status: {status}")
    print(f"Response: {data}")
    exit(1)

print("Metric 'container_cpu_utilization' found. Fetching data...")

# Fetch data for the last 1 hour
end_time = datetime.utcnow()
start_time = end_time - timedelta(hours=1)

program_text = """
data('container_cpu_utilization', filter=filter('kubernetes_cluster', '*'))
.max(by=['kubernetes_cluster', 'kubernetes_pod_name'])
.publish()
"""

payload = {
    "programText": program_text,
    "start": int(start_time.timestamp() * 1000),
    "end": int(end_time.timestamp() * 1000),
    "resolution": 60000,  # 1-minute resolution
    "immediate": True
}

signalflow_url = f"{BASE_URL}/v2/signalflow/execute"
status, data = make_request('POST', signalflow_url, payload)

if status != 200:
    print(f"Error fetching data. Status: {status}")
    print(f"Response: {data}")
    exit(1)

# Process and print the results
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

print("Maximum CPU Utilization by Cluster and Pod (last hour):")
for cluster, pods in max_cpu_utilization.items():
    print(f"\nCluster: {cluster}")
    for pod, max_cpu in pods.items():
        print(f"  Pod: {pod}, Max CPU Utilization: {max_cpu:.2f}%")