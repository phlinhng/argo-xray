#!/bin/bash

zone_name=$1
record_name=$2
api_key=$3

zone_id=`curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
  -H "Authorization: Bearer ${api_key}" -H "Content-Type: application/json" \
  | ./jq -r ".result | .[] | select(.name == \"${zone_name}\") | .id"`

record_id=`curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records" \
  -H "Authorization: Bearer ${api_key}" -H "Content-Type: application/json" \
  | ./jq -r ".result | .[] | select(.name == \"${record_name}.${zone_name}\") | .id"`

curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${record_id}" \
  -H "Authorization: Bearer ${api_key}" -H "Content-Type: application/json"

exit