#!/bin/bash
set -e

# Install required packages
yum update -y
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

yum install -y gcc make wget unzip jq postgresql-devel python3-pip bind-utils

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install PGBouncer
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install -y pgbouncer

# Create pgbouncer user
useradd -r pgbouncer || echo "User already exists"

# Create directories
mkdir -p /etc/pgbouncer
mkdir -p /var/log/pgbouncer
chown pgbouncer:pgbouncer /var/log/pgbouncer

# Get DB credentials from Secrets Manager if enabled
if [ "${use_secrets_manager}" = "true" ]; then
    SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id ${db_credentials_secret_arn} --region ${region} --query SecretString --output text)
    db_username=$(echo $SECRET_VALUE | jq -r '.username')
    db_password=$(echo $SECRET_VALUE | jq -r '.password')
else
    db_username="${db_username}"
    db_password="${db_password}"
fi

# Wait for DNS resolution of Aurora DB endpoint
echo "Waiting for Aurora DB endpoint DNS resolution..."
for i in {1..30}; do
    if host ${db_host} > /dev/null 2>&1; then
        echo "DNS resolution successful"
        break
    fi
    echo "Attempt $i: Waiting for DNS resolution..."
    sleep 10
done

# Configure pgbouncer.ini
cat > /etc/pgbouncer/pgbouncer.ini << EOF
[databases]
* = host=${db_host} port=${db_port} dbname=${db_name}

[pgbouncer]
listen_addr = *
listen_port = ${pgbouncer_port}
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
logfile = /var/log/pgbouncer/pgbouncer.log
pidfile = /var/run/pgbouncer/pgbouncer.pid
admin_users = pgbouncer
stats_users = pgbouncer
pool_mode = transaction
server_reset_query = DISCARD ALL
max_client_conn = ${max_client_conn}
default_pool_size = ${default_pool_size}
min_pool_size = ${min_pool_size}
reserve_pool_size = 5
reserve_pool_timeout = 3
max_db_connections = ${max_db_connections}
max_user_connections = 0
server_round_robin = 1
ignore_startup_parameters = extra_float_digits

# TLS settings
;client_tls_sslmode = disable
;client_tls_ca_file = /etc/pgbouncer/ca.crt
;client_tls_cert_file = /etc/pgbouncer/server.crt
;client_tls_key_file = /etc/pgbouncer/server.key

# Custom parameters
${custom_pg_params}
EOF

# Create userlist.txt with DB credentials
PASSWORD_MD5=$(echo -n "md5$(echo -n "${db_password}${db_username}" | md5sum | cut -d' ' -f1)")

cat > /etc/pgbouncer/userlist.txt << EOF
"${db_username}" "$${PASSWORD_MD5}"
"pgbouncer" "md5$(echo -n 'pgbouncerpgbouncer' | md5sum | cut -d' ' -f1)"
EOF

# Set permissions
chmod 640 /etc/pgbouncer/pgbouncer.ini
chmod 600 /etc/pgbouncer/userlist.txt
chown pgbouncer:pgbouncer /etc/pgbouncer/pgbouncer.ini
chown pgbouncer:pgbouncer /etc/pgbouncer/userlist.txt

# Create systemd unit file
cat > /etc/systemd/system/pgbouncer.service << EOF
[Unit]
Description=PgBouncer connection pooler for PostgreSQL
After=network.target

[Service]
Type=simple
User=pgbouncer
ExecStart=/usr/bin/pgbouncer /etc/pgbouncer/pgbouncer.ini
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=mixed
KillSignal=SIGINT
TimeoutSec=0
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

# Create health check script
cat > /usr/local/bin/health_check.sh << EOF
#!/bin/bash
PGPASSWORD=pgbouncer psql -h 127.0.0.1 -p ${pgbouncer_port} -U pgbouncer pgbouncer -c "SHOW POOLS;" > /dev/null 2>&1
exit \$?
EOF

chmod +x /usr/local/bin/health_check.sh

# Start PgBouncer
systemctl daemon-reload
systemctl enable pgbouncer
systemctl start pgbouncer

# Wait for PgBouncer to start
for i in {1..30}; do
    if systemctl is-active --quiet pgbouncer; then
        echo "PgBouncer started successfully"
        break
    fi
    echo "Attempt $i: Waiting for PgBouncer to start..."
    sleep 5
done

# Setup CloudWatch agent for monitoring
yum install -y amazon-cloudwatch-agent

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/pgbouncer/pgbouncer.log",
            "log_group_name": "${name}-pgbouncer-logs",
            "log_stream_name": "{instance_id}",
            "retention_in_days": 7
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      }
    },
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}"
    }
  }
}
EOF

# Start CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

echo "PGBouncer setup complete!"