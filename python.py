import urllib3
import json
import ssl
from datetime import datetime, timedelta
import os

# Create an SSL context that ignores certificate verification
ssl_context = ssl.create_default_context()
ssl_context.check_hostname = False
ssl_context.verify_mode = ssl.CERT_NONE

# Configuration
REALM = "YOUR_REALM"  # Replace with your realm
TOKEN = os.environ.get('YOUR_TOKEN')
if not TOKEN:
    raise ValueError("Error: YOUR_TOKEN environment variable is not set.")

BASE_URL = f"https://api.{REALM}.signalfx.com"
METRIC_NAME = "sf_metric::container_cpu_utilization"

# Set up HTTP client
https = urllib3.PoolManager(
    ssl_version=ssl.PROTOCOL_TLS,
    ssl_context=ssl_context
)

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

def make_request(method, url, fields=None, body=None):
    response = https.request(method, url, fields=fields, body=body, headers=headers)
    if response.status != 200:
        raise Exception(f"Request failed with status {response.status}: {response.data}")
    return json.loads(response.data.decode('utf-8'))

def fetch_all_metric_metadata():
    url = f"{BASE_URL}/v2/metrictimeseries"
    params = {
        "query": f"sf_metric:{METRIC_NAME}",
        "limit": 1000,
        "offset": 0
    }
    all_metadata = []
    
    while True:
        response = make_request('GET', url, fields=params)
        all_metadata.extend(response.get('results', []))
        
        if len(response.get('results', [])) < params['limit']:
            break
        
        params['offset'] += params['limit']
        print(f"Fetched {len(all_metadata)} metadata entries so far...")
    
    return all_metadata

def fetch_metric_data(tsid):
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(days=90)
    
    url = f"{BASE_URL}/v2/timeserieswindow"
    params = {
        "tsId": tsid,
        "startMs": int(start_time.timestamp() * 1000),
        "endMs": int(end_time.timestamp() * 1000),
        "resolution": "1h"
    }
    
    all_data = []
    while True:
        response = make_request('GET', url, fields=params)
        all_data.extend(response.get('data', []))
        
        if 'nextPageLink' not in response:
            break
        
        params = {'_context': response['nextPageLink']}
    
    return all_data

def process_data(metadata, all_data):
    max_cpu_utilization = {}
    
    for ts in metadata:
        tsid = ts['tsId']
        cluster = ts.get('dimensions', {}).get('kubernetes_cluster', 'unknown')
        pod = ts.get('dimensions', {}).get('kubernetes_pod_name', 'unknown')
        
        ts_data = all_data.get(tsid, [])
        if ts_data:
            max_value = max(point[1] for point in ts_data if point[1] is not None)
            
            if cluster not in max_cpu_utilization:
                max_cpu_utilization[cluster] = {}
            
            if pod not in max_cpu_utilization[cluster] or max_value > max_cpu_utilization[cluster][pod]:
                max_cpu_utilization[cluster][pod] = max_value
    
    return max_cpu_utilization

def main():
    print("Fetching all metric metadata...")
    metadata = fetch_all_metric_metadata()
    print(f"Total metadata entries fetched: {len(metadata)}")
    
    print("\nFetching metric data for the last 90 days...")
    all_data = {}
    total_ts = len(metadata)
    for i, ts in enumerate(metadata, 1):
        tsid = ts['tsId']
        all_data[tsid] = fetch_metric_data(tsid)
        print(f"Fetched data for time series {i}/{total_ts}")
    
    print("\nProcessing data...")
    max_cpu_utilization = process_data(metadata, all_data)
    
    print("\nMaximum CPU Utilization by Cluster and Pod (last 90 days):")
    for cluster, pods in max_cpu_utilization.items():
        print(f"\nCluster: {cluster}")
        for pod, max_cpu in pods.items():
            print(f"  Pod: {pod}, Max CPU Utilization: {max_cpu:.2f}%")

if __name__ == "__main__":
    main()