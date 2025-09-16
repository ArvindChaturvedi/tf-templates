#!/bin/bash
ZONE_ID=${1:-"YOUR_ZONE_ID"}

echo "Record Name                    Record Type    TTL    Routes Traffic To"
echo "============================================================================"

aws route53 list-resource-record-sets --hosted-zone-id $ZONE_ID --output json | \
jq -r '.ResourceRecordSets[] | 
  if .Type == "CNAME" and (.ResourceRecords | length > 0) then 
    [.Name, "CNAME", (.TTL | tostring), .ResourceRecords.Value] 
  elif .Type == "A" and .AliasTarget then 
    [.Name, "ALIAS", "Auto", .AliasTarget.DNSName] 
  else empty end | 
  @tsv' | \
column -t -s $'\t'
