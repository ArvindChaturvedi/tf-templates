import urllib3
import json
import certifi
from datetime import datetime, timedelta

REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"
BASE_URL = f"https://stream.{REALM}.signalfx.com"  # Note the change to 'stream' subdomain

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())

def make_request(method, url, body=None):
    try:
        response = https.request(method, url, body=json.dumps(body).encode('utf-8') if body else None, headers=headers)
        print(f"Response status: {response.status}")
        return response.status, response.data
    except Exception as e:
        print(f"An error occurred: {e}")
        return None, str(e)

# Fetch data for the last 1 hour
end_time = datetime.utcnow()
start_time = end_time - timedelta(hours=1)

program_text = """
data('container_cpu_utilization', filter=filter('kubernetes_cluster', '*'))
.max(by=['kubernetes_cluster', 'kubernetes_pod_name'])
.publish()
"""

signalflow_url = f"{BASE_URL}/v2/signalflow"
status, data = make_request('POST', signalflow_url, {"program": program_text})

if status != 200:
    print(f"Error fetching data. Status: {status}")
    print(f"Response: {data}")
    exit(1)

# Process and print the results
max_cpu_utilization = {}

# Parse the streaming data
for line in data.split(b'\n'):
    if line:
        try:
            message = json.loads(line)
            if message['type'] == 'data':
                tsid = message['tsId']
                metadata = message['metadata']
                cluster = metadata.get('kubernetes_cluster', 'unknown')
                pod = metadata.get('kubernetes_pod_name', 'unknown')
                value = message['value']
                
                if cluster not in max_cpu_utilization:
                    max_cpu_utilization[cluster] = {}
                if pod not in max_cpu_utilization[cluster] or value > max_cpu_utilization[cluster][pod]:
                    max_cpu_utilization[cluster][pod] = value
        except json.JSONDecodeError:
            continue

print("Maximum CPU Utilization by Cluster and Pod (last hour):")
for cluster, pods in max_cpu_utilization.items():
    print(f"\nCluster: {cluster}")
    for pod, max_cpu in pods.items():
        print(f"  Pod: {pod}, Max CPU Utilization: {max_cpu:.2f}%")