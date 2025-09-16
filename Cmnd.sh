#!/bin/bash
ZONE_ID=${1:-"YOUR_DEFAULT_ZONE_ID"}

echo "CNAME Records for Hosted Zone: $ZONE_ID"
echo "============================================"

aws route53 list-resource-record-sets --hosted-zone-id $ZONE_ID \
  --query "ResourceRecordSets[?Type == 'CNAME'].{
    RecordName:Name,
    RecordType:Type,
    TTL:TTL,
    RoutesTrafficTo:ResourceRecords.Value
  }" \
  --output table
