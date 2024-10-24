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
        print(f"Response status: {response.status}")
        print(f"Response headers: {response.headers}")
        print(f"Response data: {response.data.decode('utf-8')[:200]}...")  # Print first 200 characters
        
        if response.status == 200:
            return response.status, json.loads(response.data.decode('utf-8'))
        else:
            return response.status, response.data.decode('utf-8')
    except urllib3.exceptions.HTTPError as e:
        return None, f"HTTP Error: {str(e)}"
    except json.JSONDecodeError as e:
        return None, f"JSON Decode Error: {str(e)}"
    except Exception as e:
        return None, f"Unexpected Error: {str(e)}"

print("Splunk Observability Cloud Token Privilege Check")
print("================================================")

# Check Token Privileges
print("\nChecking Token Privileges")
print("--------------------------")
status, data = make_request(f"{base_url}/v2/accesstoken")

if status == 200:
    print("Successfully retrieved token information.")
    print("\nToken Privileges (auth_scopes):")
    if isinstance(data, dict) and 'auth_scopes' in data and data['auth_scopes']:
        for scope in data['auth_scopes']:
            print(f"- {scope}")
    elif isinstance(data, dict) and 'auth_scopes' in data and not data['auth_scopes']:
        print("No specific auth_scopes listed. This might indicate full access.")
    else:
        print("Unable to retrieve auth_scopes information.")
else:
    print(f"Failed to retrieve token information. Status: {status}")
    print(f"Response: {data}")

print("\nCheck Complete")