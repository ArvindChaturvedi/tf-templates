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

print("Splunk Observability Cloud Token Privilege Check")
print("================================================")

# Check Token Privileges
print("\nChecking Token Privileges")
print("--------------------------")
status, data = make_request(f"{base_url}/v2/accesstoken")

if status == 200:
    print("Successfully retrieved token information.")
    print("\nToken Details:")
    print(f"Name: {data.get('name', 'N/A')}")
    print(f"Description: {data.get('description', 'N/A')}")
    print(f"Created By: {data.get('created_by', 'N/A')}")
    print(f"Created At: {data.get('created_at', 'N/A')}")
    
    print("\nPrivileges:")
    if 'auth_scopes' in data:
        for scope in data['auth_scopes']:
            print(f"- {scope}")
    else:
        print("No specific privileges listed. This might indicate full access.")
    
    print("\nLimits:")
    if 'limits' in data:
        for limit_name, limit_value in data['limits'].items():
            print(f"- {limit_name}: {limit_value}")
    else:
        print("No specific limits listed.")
else:
    print(f"Failed to retrieve token information. Status: {status}, Response: {data}")

print("\nCheck Complete")