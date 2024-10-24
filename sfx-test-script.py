import urllib3
import json
import certifi
import time

REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"

https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())
base_url = f"https://api.{REALM}.signalfx.com"

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

def make_request(method, url, body=None):
    try:
        response = https.request(method, url, 
                                 body=json.dumps(body).encode('utf-8') if body else None,
                                 headers=headers)
        return response.status, json.loads(response.data.decode('utf-8'))
    except Exception as e:
        return None, str(e)

print("Splunk Observability Cloud API Access Test")
print("==========================================")

# 1. List Metrics
print("\n1. List Available Metrics")
print("--------------------------")
status, data = make_request('GET', f"{base_url}/v2/metric")
if status == 200:
    print(f"Successfully retrieved metrics. Total metrics: {len(data['results'])}")
    print("First 5 metrics:")
    for metric in data['results'][:5]:
        print(f"- {metric['name']}")
else:
    print(f"Failed to retrieve metrics. Status: {status}, Response: {data}")

# 2. Get Metric Metadata
print("\n2. Get Metric Metadata")
print("-----------------------")
if status == 200 and data['results']:
    sample_metric = data['results'][0]['name']
    status, metadata = make_request('GET', f"{base_url}/v2/metric/{sample_metric}")
    if status == 200:
        print(f"Metadata for '{sample_metric}':")
        print(json.dumps(metadata, indent=2))
    else:
        print(f"Failed to retrieve metadata. Status: {status}, Response: {metadata}")
else:
    print("Skipped due to failure in retrieving metrics list.")

# 3. Test SignalFlow
print("\n3. Test SignalFlow")
print("------------------")
program_text = "data('cpu.utilization').publish()"
payload = {
    "programText": program_text,
}

status, data = make_request('POST', f"{base_url}/v2/signalflow/execute", payload)
if status == 200:
    print("Successfully executed SignalFlow program.")
    print("Response:")
    print(json.dumps(data, indent=2)[:1000])  # Print first 1000 characters
else:
    print(f"Failed to execute SignalFlow program. Status: {status}, Response: {data}")

    # If failed, try without any additional parameters
    print("\nTrying SignalFlow without additional parameters:")
    status, data = make_request('POST', f"{base_url}/v2/signalflow/execute", {"program": program_text})
    if status == 200:
        print("Successfully executed SignalFlow program without additional parameters.")
        print("Response:")
        print(json.dumps(data, indent=2)[:1000])  # Print first 1000 characters
    else:
        print(f"Failed to execute SignalFlow program. Status: {status}, Response: {data}")

print("\nTest Complete")