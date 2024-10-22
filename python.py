import requests
import datetime
import json

# Define constants
SPLUNK_REALM = 'YOUR_REALM'  # e.g., 'us0', 'eu0', etc.
SPLUNK_TOKEN = 'YOUR_TOKEN'
ENDPOINT = f"https://api.{SPLUNK_REALM}.signalfx.com/v2/signalflow/query"
HEADERS = {
    'Content-Type': 'application/json',
    'X-SF-Token': SPLUNK_TOKEN
}

# Helper function to get the last 90 days in milliseconds (since epoch)
def get_last_90_days_time_range():
    end_time = datetime.datetime.now()
    start_time = end_time - datetime.timedelta(days=90)
    return int(start_time.timestamp() * 1000), int(end_time.timestamp() * 1000)

# Fetch CPU utilization data from Splunk Observability
def fetch_cpu_utilization():
    start_ms, end_ms = get_last_90_days_time_range()
    query = {
        "programText": """
        data('container_cpu_utilization', filter=filter("cluster", "*")).mean(by=['cluster', 'pod']).max()
        """,
        "start": start_ms,
        "stop": end_ms
    }
    
    response = requests.post(ENDPOINT, headers=HEADERS, data=json.dumps(query))
    
    if response.status_code != 200:
        raise Exception(f"Error fetching data: {response.text}")
    
    return response.json()

# Process data and categorize by clusters and pods
def categorize_by_cluster_and_pod(data):
    categorized_data = {}
    
    for record in data['data']['results']:
        cluster = record['groupBy']['cluster']
        pod = record['groupBy']['pod']
        max_cpu_utilization = record['value']

        if cluster not in categorized_data:
            categorized_data[cluster] = {}
        
        categorized_data[cluster][pod] = max(categorized_data[cluster].get(pod, 0), max_cpu_utilization)
    
    return categorized_data

# Main function
if __name__ == '__main__':
    try:
        print("Fetching CPU utilization data...")
        raw_data = fetch_cpu_utilization()
        categorized_data = categorize_by_cluster_and_pod(raw_data)
        
        for cluster, pods in categorized_data.items():
            print(f"\nCluster: {cluster}")
            for pod, max_cpu in pods.items():
                print(f"  Pod: {pod}, Max CPU Utilization: {max_cpu:.2f}%")
                
    except Exception as e:
        print(f"An error occurred: {str(e)}")
