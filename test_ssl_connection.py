import ssl
import socket
import certifi

def test_ssl_connection(hostname, port=443):
    context = ssl.create_default_context(cafile=certifi.where())
    
    try:
        with socket.create_connection((hostname, port)) as sock:
            with context.wrap_socket(sock, server_hostname=hostname) as secure_sock:
                print(f"Connected to {hostname} successfully.")
                print(f"Cipher used: {secure_sock.cipher()}")
                print(f"SSL version: {secure_sock.version()}")
                cert = secure_sock.getpeercert()
                print(f"Certificate: {cert}")
    except ssl.SSLError as e:
        print(f"SSL Error: {e}")
    except Exception as e:
        print(f"Error: {e}")

# Test connection to Splunk Observability Cloud API
test_ssl_connection(f"api.{REALM}.signalfx.com")

# Test connection to a known good SSL site for comparison
test_ssl_connection("www.google.com")