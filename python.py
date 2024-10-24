import requests
from datetime import datetime, timedelta
import json

# Configuration
REALM = "YOUR_REALM"
TOKEN = "YOUR_TOKEN"
API_ENDPOINT = f"https://api.{REALM}.signalfx.com/v2/signalflow/execute"

# Calculate the time range (last 90 days)
end_time = datetime.utcnow()
start_time = end_time - timedelta(days=7)

# SignalFlow program to fetch container CPU utilization
program = """
A = data('container_cpu_utilization')
.publish()
"""

# Prepare the request payload
payload = {
    "program": program,
    "start": int(start_time.timestamp() * 1000),
    "end": int(end_time.timestamp() * 1000),
    "resolution": 3600000,  # 1-hour resolution
    "maxDelay": 0,
    "immediate": True
}

# Set up headers
headers = {
    "Content-Type": "application/json",
    "X-SF-Token": TOKEN
}

print("Request Details:")
print(f"URL: {API_ENDPOINT}")
print(f"Headers: {json.dumps(headers, indent=2)}")
print(f"Payload: {json.dumps(payload, indent=2)}")

try:
    # Make the API request
    response = requests.post(API_ENDPOINT, headers=headers, json=payload)
    
    print(f"\nResponse Status Code: {response.status_code}")
    print(f"Response Headers: {json.dumps(dict(response.headers), indent=2)}")
    print(f"Response Content: {response.text[:1000]}...")  # Print first 1000 characters
    
    response.raise_for_status()

    # Process the response
    data = response.json()
    
    # ... (rest of the script remains the same)

except requests.exceptions.RequestException as e:
    print(f"An error occurred: {e}")
    if hasattr(e, 'response') and e.response is not None:
        print(f"Error response content: {e.response.text}")


if response.status_code == 200:
    # Process the response
    data = response.json()
    
    # Initialize a dictionary to store max CPU utilization by cluster and pod
    max_cpu_utilization = {}

    for tsid, ts_data in data.get("data", {}).items():
        metadata = ts_data.get("metadata", {})
        cluster = metadata.get("kubernetes_cluster", "unknown")
        pod = metadata.get("kubernetes_pod_name", "unknown")
        
        # Initialize the cluster in the dictionary if it doesn't exist
        if cluster not in max_cpu_utilization:
            max_cpu_utilization[cluster] = {}
        
        # Find the maximum CPU utilization for this pod
        max_value = max(ts_data.get("values", [0]))
        
        # Update the max CPU utilization for this pod
        if pod not in max_cpu_utilization[cluster] or max_value > max_cpu_utilization[cluster][pod]:
            max_cpu_utilization[cluster][pod] = max_value

    # Print the results
    print("Maximum CPU Utilization by Cluster and Pod (last 90 days):")
    for cluster, pods in max_cpu_utilization.items():
        print(f"\nCluster: {cluster}")
        for pod, max_cpu in pods.items():
            print(f"  Pod: {pod}, Max CPU Utilization: {max_cpu:.2f}%")

else:
    print(f"Error: {response.status_code}")
    print(response.text)
