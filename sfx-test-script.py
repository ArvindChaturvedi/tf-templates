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
    if status