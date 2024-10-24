import socket
import urllib3.util
import certifi
import json
import urllib3

# Configuration
REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"

print("Splunk Observability Cloud API Diagnostics")
print("==========================================")

# 1. DNS Resolution Test
print("\n1. DNS Resolution Test")
print("----------------------")

domains_to_test = [
    f"api.{REALM}.signalfx.com",
    f"stream.{REALM}.signalfx.com",
    f"{REALM}.signalfx.com",
    f"ingest.{REALM}.signalfx.com",
    "www.google.com"  # As a control
]

for domain in domains_to_test:
    try:
        ip = socket.gethostbyname(domain)
        print(f"Successfully resolved {domain} to {ip}")
    except socket.gaierror as e:
        print(f"Failed to resolve {domain}: {e}")

# 2. HTTPS Connection Test
print("\n2. HTTPS Connection Test")
print("------------------------")

https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())

urls_to_test = [
    "https://api.signalfx.com",
    "https://www.google.com"
]

for url in urls_to_test:
    try:
        response = https.request('GET', url)
        print(f"Successfully connected to {url}. Status code: {response.status}")
    except Exception as e:
        print(f"Failed to connect to {url}: {e}")

# 3. API Token Test
print("\n3. API Token Test")
print("-----------------")

url = f"https://api.{REALM}.signalfx.com/v2/organization"
headers = {
    "X-SF-Token": TOKEN
}

try:
    response = https.request('GET', url, headers=headers)
    print(f"Response status: {response.status}")
    if response.status == 200:
        data = json.loads(response.data.decode('utf-8'))
        print(f"Organization name: {data.get('name')}")
    else:
        print(f"Response data: {response.data.decode('utf-8')}")
except Exception as e:
    print(f"An error occurred: {e}")

# 4. SignalFlow API Test
print("\n4. SignalFlow API Test")
print("----------------------")

base_url = f"https://api.{REALM}.signalfx.com"
execute_url = f"{base_url}/v2/signalflow/execute"

program_text = """
data('cpu.utilization').publish()
"""

payload = {
    "programText": program_text,
    "start": int(urllib3.util.timeout.current_time() * 1000) - 900000,  # 15 minutes ago
    "stop": int(urllib3.util.timeout.current_time() * 1000),  # now
    "resolution": 60000,
    "maxDelay": 0,
    "immediate": True
}

headers.update({"Content-Type": "application/json"})

try:
    response = https.request('POST', execute_url, 
                             body=json.dumps(payload).encode('utf-8'),
                             headers=headers)
    print(f"SignalFlow Execute API Status: {response.status}")
    if response.status == 200:
        print("Successfully connected to SignalFlow Execute API")
        data = json.loads(response.data.decode('utf-8'))
        print(f"Response data: {json.dumps(data, indent=2)[:1000]}...")  # First 1000 characters
    else:
        print(f"Failed to connect. Response: {response.data.decode('utf-8')}")
except Exception as e:
    print(f"Failed to connect to SignalFlow Execute API: {e}")
else:
    print("Failed to connect to any SignalFlow API endpoint")

print("\nDiagnostics Complete")