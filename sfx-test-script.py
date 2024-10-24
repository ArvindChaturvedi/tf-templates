import socket
import urllib3
import certifi
import json

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

base_urls = [
    f"https://stream.{REALM}.signalfx.com",
    f"https://api.{REALM}.signalfx.com",
    f"https://{REALM}.signalfx.com",
    f"https://ingest.{REALM}.signalfx.com"
]

program_text = """
data('cpu.utilization').publish()
"""

for base_url in base_urls:
    print(f"\nTrying base URL: {base_url}")
    
    # Try SignalFlow endpoint
    signalflow_url = f"{base_url}/v2/signalflow"
    try:
        response = https.request('POST', signalflow_url, 
                                 body=json.dumps({"program": program_text}).encode('utf-8'),
                                 headers=headers)
        print(f"SignalFlow API Status: {response.status}")
        if response.status == 200:
            print("Successfully connected to SignalFlow API")
            break
    except Exception as e:
        print(f"Failed to connect to SignalFlow API: {e}")
    
    # If SignalFlow fails, try the execute endpoint
    execute_url = f"{base_url}/v2/signalflow/execute"
    try:
        response = https.request('POST', execute_url, 
                                 body=json.dumps({"programText": program_text}).encode('utf-8'),
                                 headers=headers)
        print(f"SignalFlow Execute API Status: {response.status}")
        if response.status == 200:
            print("Successfully connected to SignalFlow Execute API")
            break
    except Exception as e:
        print(f"Failed to connect to SignalFlow Execute API: {e}")
else:
    print("Failed to connect to any SignalFlow API endpoint")

print("\nDiagnostics Complete")