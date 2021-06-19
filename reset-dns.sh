#!/bin/bash

zone_name=$1
record_name=$2
api_key=$3
api_email=$4

zone_id=`curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
  -H "X-Auth-Key: ${api_key}" -H "X-Auth-Email: ${api_email}" -H "Content-Type: application/json" \
  | ./jq -r ".result | .[] | select(.name == \"${zone_name}\") | .id"`

record_id=`curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records" \
  -H "X-Auth-Key: ${api_key}" -H "X-Auth-Email: ${api_email}" -H "Content-Type: application/json" \
  | ./jq -r ".result | .[] | select(.name == \"${record_name}.${zone_name}\") | .id"`

curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${record_id}" \
  -H "X-Auth-Key: ${api_key}" -H "X-Auth-Email: ${api_email}" -H "Content-Type: application/json"

exit