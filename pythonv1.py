import urllib3
import json
import certifi
import os
from datetime import datetime, timedelta

# Configuration
REALM = "YOUR_REALM"  # Replace with your realm
TOKEN = os.environ.get('YOUR_TOKEN')
if not TOKEN:
    raise ValueError("Error: YOUR_TOKEN environment variable is not set.")

BASE_URL = f"https://stream.{REALM}.signalfx.com"  # Note the change to 'stream' subdomain
METRIC_NAME = "container_cpu_utilization"

# Set up HTTP client
https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

def make_request(method, url, body=None):
    try:
        response = https.request(method, url, body=json.dumps(body).encode('utf-8') if body else None, headers=headers)
        print(f"Request URL: {url}")
        print(f"Request method: {method}")
        print(f"Request body: {json.dumps(body, indent=2) if body else 'None'}")
        print(f"Response status: {response.status}")
        print(f"Response headers: {response.headers}")
        print(f"Response data: {response.data.decode('utf-8')[:200]}...")  # Print first 200 characters

        return response.status, response.data
    except Exception as e:
        return None, str(e)

def fetch_cpu_utilization():
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(days=90)

    program = f"""
    data('{METRIC_NAME}', filter=filter('kubernetes_cluster', '*'))
    .publish()
    """

    body = {
        "program": program,
        "start": int(start_time.timestamp() * 1000),
        "stop": int(end_time.timestamp() * 1000),
        "resolution": 3600000,  # 1-hour resolution
        "maxDelay": 0,
        "immediate": True
    }

    status, data = make_request('POST', f"{BASE_URL}/v2/signalflow", body)

    if status != 200:
        print(f"Failed to fetch CPU utilization. Status: {status}")
        print(f"Response: {data}")
        return None

    return data

def process_cpu_data(data):
    max_cpu_utilization = {}

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

    return max_cpu_utilization

def main():
    print("\nFetching CPU utilization data for the last 90 days...")
    cpu_data = fetch_cpu_utilization()

    if cpu_data:
        print("Processing CPU utilization data...")
        max_cpu_utilization = process_cpu_data(cpu_data)

        print("\nMaximum CPU Utilization by Cluster and Pod (last 90 days):")
        for cluster, pods in max_cpu_utilization.items():
            print(f"\nCluster: {cluster}")
            for pod, max_cpu in pods.items():
                print(f"  Pod: {pod}, Max CPU Utilization: {max_cpu:.2f}%")
    else:
        print("Failed to fetch CPU utilization data.")

if __name__ == "__main__":
    main()