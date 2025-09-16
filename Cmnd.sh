#!/bin/bash
ZONE_ID=${1:-"YOUR_ZONE_ID"}

echo "DNS Records Routing Traffic (CNAME + Alias Records)"
echo "=================================================="

aws route53 list-resource-record-sets --hosted-zone-id $ZONE_ID --output json | \
jq -r '
  ["Record Name", "Record Type", "TTL", "Routes Traffic To"],
  (.ResourceRecordSets[] | 
    if .Type == "CNAME" then 
      [.Name, "CNAME", (.TTL | tostring), .ResourceRecords.Value] 
    elif .Type == "A" and .AliasTarget then 
      [.Name, "ALIAS (A)", "Auto-managed", .AliasTarget.DNSName] 
    else empty end
  ) | @tsv
' | column -t -s $'\t'
