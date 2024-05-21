#!/bin/bash

# 执行 CloudflareST 测试并生成 yuming.csv 文件
./CloudflareST --allip -f Fandai.txt -n 200 -url https://speedtest.neobirdfly.eu.org/100m -sl 5 -tl 350 -dn 3 -o yuming.csv

# 使用 grep 提取 IP 地址并写入到 yuming.txt 文件中
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' yuming.csv > yuming.txt || { echo "Error: Failed to extract IP addresses from yuming.csv" ; exit 1; }

# Cloudflare API 配置信息
API_EMAIL="gavin8857@gmail.com"
API_KEY="bc638ffbc3fe16388aca041d45bc603a1a23b"
ZONE_ID="0a8b838c05ad59e0c0e8e84a9225408e"
SUBDOMAIN="cfproxy"  # 替换为你的二级域名，不包含主域名部分
DOMAIN="neobirdfly.eu.org"  # 替换为你的主域名

# 完整的二级域名
FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"

# 删除现有的 A 记录
EXISTING_RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$FULL_DOMAIN" \
  -H "X-Auth-Email: $API_EMAIL" \
  -H "X-Auth-Key: $API_KEY" \
  -H "Content-Type: application/json")

echo "Existing records: $EXISTING_RECORDS"

RECORD_IDS=$(echo $EXISTING_RECORDS | jq -r '.result[].id')

for RECORD_ID in $RECORD_IDS; do
  DELETE_RESPONSE=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    -H "X-Auth-Email: $API_EMAIL" \
    -H "X-Auth-Key: $API_KEY" \
    -H "Content-Type: application/json")

  SUCCESS=$(echo $DELETE_RESPONSE | jq -r '.success')
  if [ "$SUCCESS" != "true" ]; then
    echo "Error: Failed to delete DNS record with ID $RECORD_ID"
    echo "Response: $DELETE_RESPONSE"
    exit 1
  fi
  echo "Successfully deleted DNS record with ID $RECORD_ID"
done

# 读取 yuming.txt 文件中的所有 IP 地址
while read -r IP; do
  # 检查是否有 IP 地址
  if [ -z "$IP" ]; then
    echo "Error: No IP address found"
    continue
  fi

  echo "Adding DNS record for $FULL_DOMAIN with IP $IP"

  # 创建新的 A 记录
  RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    -H "X-Auth-Email: $API_EMAIL" \
    -H "X-Auth-Key: $API_KEY" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"ttl\":1,\"proxied\":false}")

  # 检查响应状态
  SUCCESS=$(echo $RESPONSE | jq -r '.success')
  if [ "$SUCCESS" != "true" ]; then
    echo "Error: Failed to create DNS record for IP $IP"
    echo "Response: $RESPONSE"
    continue
  fi

  echo "Successfully added DNS record for IP $IP"
done < yuming.txt
