import urllib3
import json
import certifi

REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"

https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())
base_url = f"https://api.{REALM}.signalfx.com"

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

def make_request(url):
    try:
        response = https.request('GET', url, headers=headers)
        return response.status, json.loads(response.data.decode('utf-8'))
    except Exception as e:
        return None, str(e)

print("Splunk Observability Cloud API Access Analysis")
print("==============================================")

# 1. List All Available Metrics
print("\n1. List All Available Metrics")
print("------------------------------")
status, data = make_request(f"{base_url}/v2/metric")
if status == 200:
    total_metrics = len(data['results'])
    print(f"Successfully retrieved metrics. Total metrics: {total_metrics}")
    print("\nAll available metrics:")
    for i, metric in enumerate(data['results'], 1):
        print(f"{i}. {metric['name']}")
        print(f"   Description: {metric.get('description', 'N/A')}")
        print(f"   Type: {metric.get('type', 'N/A')}")
        print(f"   Custom: {metric.get('custom', 'N/A')}")
        print()
else:
    print(f"Failed to retrieve metrics. Status: {status}, Response: {data}")

# 2. Get Metric Metadata (for the first metric)
print("\n2. Get Metric Metadata (for the first metric)")
print("----------------------------------------------")
if status == 200 and data['results']:
    sample_metric = data['results'][0]['name']
    status, metadata = make_request(f"{base_url}/v2/metric/{sample_metric}")
    if status == 200:
        print(f"Metadata for '{sample_metric}':")
        print(json.dumps(metadata, indent=2))
    else:
        print(f"Failed to retrieve metadata. Status: {status}, Response: {metadata}")
else:
    print("Skipped due to failure in retrieving metrics list.")

# 3. List Detectors
print("\n3. List Detectors")
print("------------------")
status, detectors = make_request(f"{base_url}/v2/detector")
if status == 200:
    total_detectors = len(detectors['results'])
    print(f"Successfully retrieved detectors. Total detectors: {total_detectors}")
    print("\nFirst 5 detectors:")
    for i, detector in enumerate(detectors['results'][:5], 1):
        print(f"{i}. {detector['name']}")
        print(f"   ID: {detector['id']}")
        print(f"   Description: {detector.get('description', 'N/A')}")
        print()
else:
    print(f"Failed to retrieve detectors. Status: {status}, Response: {detectors}")

# 4. List Dashboards
print("\n4. List Dashboards")
print("-------------------")
status, dashboards = make_request(f"{base_url}/v2/dashboard")
if status == 200:
    total_dashboards = len(dashboards['results'])
    print(f"Successfully retrieved dashboards. Total dashboards: {total_dashboards}")
    print("\nFirst 5 dashboards:")
    for i, dashboard in enumerate(dashboards['results'][:5], 1):
        print(f"{i}. {dashboard['name']}")
        print(f"   ID: {dashboard['id']}")
        print(f"   Description: {dashboard.get('description', 'N/A')}")
        print()
else:
    print(f"Failed to retrieve dashboards. Status: {status}, Response: {dashboards}")

print("\nAnalysis Complete")