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

BASE_URL = f"https://api.{REALM}.signalfx.com"
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
        if response.status == 200:
            return response.status, json.loads(response.data.decode('utf-8'))
        else:
            return response.status, response.data.decode('utf-8')
    except Exception as e:
        return None, str(e)

def get_all_metrics():
    all_metrics = []
    offset = 0
    limit = 1000

    while True:
        url = f"{BASE_URL}/v2/metric?limit={limit}&offset={offset}"
        status, data = make_request('GET', url)

        if status != 200:
            print(f"Failed to retrieve metrics. Status: {status}")
            print(f"Response: {data}")
            break

        metrics = data.get('results', [])
        all_metrics.extend(metrics)
        
        if len(metrics) < limit:
            break

        offset += limit
        print(f"Retrieved {len(all_metrics)} metrics so far...")

    return all_metrics

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
        "end": int(end_time.timestamp() * 1000),
        "resolution": 3600000,  # 1-hour resolution
        "maxDelay": 0,
        "immediate": True
    }

    status, data = make_request('POST', f"{BASE_URL}/v2/signalflow/execute", body)

    if status != 200:
        print(f"Failed to fetch CPU utilization. Status: {status}")
        print(f"Response: {data}")
        return None

    return data

def process_cpu_data(data):
    max_cpu_utilization = {}

    for tsid, ts_data in data.get("data", {}).items():
        metadata = ts_data.get("metadata", {})
        cluster = metadata.get("kubernetes_cluster", "unknown")
        pod = metadata.get("kubernetes_pod_name", "unknown")
        
        max_value = max(ts_data.get("values", [0]))
        
        if cluster not in max_cpu_utilization:
            max_cpu_utilization[cluster] = {}
        
        if pod not in max_cpu_utilization[cluster] or max_value > max_cpu_utilization[cluster][pod]:
            max_cpu_utilization[cluster][pod] = max_value

    return max_cpu_utilization

def main():
    print("Fetching all metrics...")
    all_metrics = get_all_metrics()
    print(f"Total metrics available: {len(all_metrics)}")

    if METRIC_NAME not in [m['name'] for m in all_metrics]:
        print(f"Warning: '{METRIC_NAME}' not found in available metrics.")
    else:
        print(f"'{METRIC_NAME}' found in available metrics. Proceeding to fetch data.")

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