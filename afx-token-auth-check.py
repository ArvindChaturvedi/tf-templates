import urllib3
import json
import certifi
import os

# Get the token from environment variable
TOKEN = os.environ.get('YOUR_TOKEN')
if not TOKEN:
    print("Error: YOUR_TOKEN environment variable is not set.")
    exit(1)

REALM = "YOUR_REALM"  # Replace this with your actual realm

https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())
base_url = f"https://api.{REALM}.signalfx.com"

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

def make_request(url):
    try:
        response = https.request('GET', url, headers=headers, timeout=10.0)
        print(f"URL: {url}")
        print(f"Response status: {response.status}")
        print(f"Response headers: {response.headers}")
        print(f"Response data: {response.data.decode('utf-8')[:200]}...")  # Print first 200 characters
        
        if response.status == 200:
            return response.status, json.loads(response.data.decode('utf-8'))
        else:
            return response.status, response.data.decode('utf-8')
    except Exception as e:
        return None, f"Error: {str(e)}"

print("Splunk Observability Cloud API Access Check")
print("===========================================")

# List of endpoints to check
endpoints = [
    "/v2/accesstoken",
    "/v2/organization",
    "/v2/metric",
    "/v2/detector",
    "/v2/dashboard"
]

for endpoint in endpoints:
    print(f"\nChecking endpoint: {endpoint}")
    print("-" * (len(endpoint) + 19))
    status, data = make_request(f"{base_url}{endpoint}")
    
    if status == 200:
        print(f"Successfully accessed {endpoint}")
        if isinstance(data, dict):
            if 'results' in data:
                print(f"Number of items: {len(data['results'])}")
            elif 'auth_scopes' in data:
                print("Auth scopes:")
                for scope in data['auth_scopes']:
                    print(f"- {scope}")
    else:
        print(f"Failed to access {endpoint}. Status: {status}")
        print(f"Response: {data}")

print("\nCheck Complete")