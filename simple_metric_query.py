import urllib3
import json
import certifi
from datetime import datetime, timedelta

REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"
API_ENDPOINT = f"https://api.{REALM}.signalfx.com/v2/signalflow/execute"

end_time = datetime.utcnow()
start_time = end_time - timedelta(minutes=5)  # Just fetch last 5 minutes of data

program_text = "data('cpu.utilization').publish()"

payload = {
    "program": program_text,
    "start": int(start_time.timestamp() * 1000),
    "end": int(end_time.timestamp() * 1000),
    "resolution": 60000,  # 1-minute resolution
    "immediate": True
}

headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

def make_request(pool_manager):
    try:
        encoded_payload = json.dumps(payload).encode('utf-8')
        print(f"Request payload: {encoded_payload.decode('utf-8')}")
        
        response = pool_manager.request('POST', API_ENDPOINT, 
                                        body=encoded_payload,
                                        headers=headers)
        print(f"Response status: {response.status}")
        print(f"Response headers: {response.headers}")
        print(f"Response data: {response.data.decode('utf-8')[:1000]}")
        
        return response.status, response.data.decode('utf-8')
    except Exception as e:
        print(f"An error occurred: {e}")
        return None, str(e)

https = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())
status, data = make_request(https)

print(f"\nFinal Status: {status}")
print(f"Final Data: {data[:1000]}")  # Print first 1000 characters of the response