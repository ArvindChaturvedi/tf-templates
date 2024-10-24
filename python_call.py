import urllib3
import json
import certifi
import ssl

REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"
API_ENDPOINT = f"https://api.{REALM}.signalfx.com/v2/metric"

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

# Print SSL debugging information
print(f"Python SSL version: {ssl.OPENSSL_VERSION}")
print(f"Certifi version: {certifi.__version__}")
print(f"Certifi path: {certifi.where()}")
print(f"urllib3 version: {urllib3.__version__}")

def make_request(pool_manager):
    try:
        response = pool_manager.request('GET', API_ENDPOINT, headers=headers)
        if response.status == 200:
            return json.loads(response.data.decode('utf-8'))
        else:
            print(f"Error: HTTP {response.status}")
            print(f"Response: {response.data.decode('utf-8')}")
            return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

print("\nTrying with default verification...")
https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())
result = make_request(https)

if result is None:
    print("\nTrying with SSL verification disabled (NOT RECOMMENDED FOR PRODUCTION)...")
    https = urllib3.PoolManager(cert_reqs='CERT_NONE')
    result = make_request(https)

if result:
    print(json.dumps(result, indent=2))
else:
    print("All attempts failed.")