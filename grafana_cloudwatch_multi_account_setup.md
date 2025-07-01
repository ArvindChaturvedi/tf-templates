# Integrating AWS CloudWatch as a Grafana Data Source Across Multiple AWS Accounts

## Overview

This document outlines the step-by-step process to integrate AWS CloudWatch as a data source in Grafana for multiple AWS accounts using IAM roles and instance profiles. Grafana is assumed to be running on an EC2 instance in Account A.

---

## Prerequisites

- Grafana installed and running on an EC2 instance in AWS Account A.
- Access to AWS accounts B, C, etc., where CloudWatch metrics need to be pulled from.
- Admin privileges to configure IAM roles and Grafana settings.

---

## 1. Setup IAM Role for EC2 (Account A)

### a. Create IAM Role for EC2

- Role name: `GrafanaEC2Role`
- Trusted entity: `ec2.amazonaws.com`

#### Trust Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
```

#### Permissions Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:GetMetricData",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics",
        "logs:DescribeLogGroups",
        "logs:GetLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::<AccountB_ID>:role/GrafanaCrossAccountRole",
        "arn:aws:iam::<AccountC_ID>:role/GrafanaCrossAccountRole"
      ]
    }
  ]
}
```

### b. Attach the IAM Role to the EC2 instance

- Use the EC2 console or CLI to attach `GrafanaEC2Role` as an instance profile to your EC2 instance.

---

## 2. Setup IAM Roles in Remote Accounts (B, C, etc.)

### a. Create IAM Role in Each Remote Account

- Role name: `GrafanaCrossAccountRole`

#### Trust Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::<AccountA_ID>:role/GrafanaEC2Role"
    },
    "Action": "sts:AssumeRole"
  }]
}
```

#### Permissions Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "logs:DescribeLogGroups",
      "logs:GetLogEvents"
    ],
    "Resource": "*"
  }]
}
```

---

## 3. Configure CloudWatch Data Source in Grafana UI

### a. Open Grafana

- Access `http://<ec2-public-ip>:3000`
- Login with admin credentials

### b. Add a New Data Source

1. Click **Gear icon (⚙)** > **Data Sources**
2. Click **Add data source**
3. Choose **CloudWatch** from the list

### c. Configure for Account A (Local)

- **Name**: `CloudWatch-AccountA`
- **Default Region**: e.g., `us-east-1`
- **Auth Provider**: `EC2 IAM Role`
- Leave `Assume Role ARN` empty
- Click **Save & Test**

### d. Configure for Account B (Remote)

- Click **Add data source** again
- **Name**: `CloudWatch-AccountB`
- **Default Region**: e.g., `us-west-2`
- **Auth Provider**: `EC2 IAM Role`
- **Assume Role ARN**: `arn:aws:iam::<AccountB_ID>:role/GrafanaCrossAccountRole`
- Click **Save & Test**

Repeat this step for each additional account (C, D, etc.)

---

## 4. Visualize Metrics

- In **Dashboards**, create or edit a panel
- Choose one of the configured CloudWatch data sources
- Select namespace, metric name, and other options
- Save the dashboard

---

## 5. Optional: Automate Data Source Setup

You can automate data source creation using the Grafana HTTP API. Example:

### Sample API Payload

```json
{
  "name": "CloudWatch-AccountB",
  "type": "cloudwatch",
  "access": "proxy",
  "jsonData": {
    "authType": "ec2_iam_role",
    "defaultRegion": "us-west-2",
    "assumeRoleArn": "arn:aws:iam::<AccountB_ID>:role/GrafanaCrossAccountRole"
  }
}
```

### API Call

```bash
curl -X POST -H "Content-Type: application/json" \
     -H "Authorization: Bearer <GRAFANA_API_KEY>" \
     -d @payload.json http://localhost:3000/api/datasources
```

---

## Conclusion

You have now set up Grafana to monitor AWS CloudWatch metrics across multiple AWS accounts using secure IAM role assumption via EC2 instance profile. This approach scales well and eliminates the need to manage AWS access keys manually.

---

## Screenshots

> *Screenshots should be taken manually from your own Grafana UI for steps like Data Source addition, IAM role policies, and dashboard visualization.*

