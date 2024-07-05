namespace=<namespace>
output_file="df_output.txt"

# Fetch all pods in the specified namespace that start with 'uaa-'
for pod in $(kubectl get pods -n $namespace -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^uaa-'); do
    # Fetch all container names in the current pod
    for container in $(kubectl get pod $pod -n $namespace -o jsonpath='{.spec.containers[*].name}'); do
        # Print the pod and container information and run df -h
        echo "Pod: $pod, Container: $container" | tee -a $output_file
        kubectl exec -n $namespace $pod -c $container -- df -h | tee -a $output_file
    done
done
