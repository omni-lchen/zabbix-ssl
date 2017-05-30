#!/bin/bash

#Author: Long Chen
#Date: 25/01/2017
#Description: A script to send SSL certificates expiry date to zabbix with zabbix sender
#Requires: zabbix sender, openssl client, jq - https://stedolan.github.io/jq/
#Set up cron job to run hourly, example setup below:
#SHELL=/bin/bash
#PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/lib/zabbix/externalscripts
# SSL certificates monitoring, run hourly
#0 * * * * sslCertExpiryCheck.sh DomainGroup1 ZabbixHost1 &>/dev/null
#5 * * * * sslCertExpiryCheck.sh DomainGroup2 ZabbixHost2 &>/dev/null

# Query domains in a group
DOMAIN_GROUP=$1
ZABBIX_HOST=$2
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
ALL_DOMAINS=$SCRIPT_DIR"/ssl/sslCertDomains.json"
QUERY_DOMAINS=$(eval "cat $ALL_DOMAINS | jq -r '."$DOMAIN_GROUP"[] .domain' | xargs 2>/dev/null")

get_SSL_Certs_Expirydate() {
  for domain in $QUERY_DOMAINS; do
  expiry_date=$(timeout 3 openssl s_client -host "$domain" -port 443 -servername "$domain" -showcerts </dev/null 2>/dev/null | sed -n '/BEGIN CERTIFICATE/,/END CERT/p' | openssl x509 -text 2>/dev/null | sed -n 's/ *Not After : *//p')
  if [ -n "$expiry_date" ]; then
    expiry_date_unix=$(date '+%s' --date "$expiry_date")
  else
    expiry_date_unix=0
  fi
  echo $ZABBIX_HOST" ssl.cert.expirydate["$domain"] "$expiry_date_unix
done
}

result=$(get_SSL_Certs_Expirydate | /usr/bin/zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -i - 2>&1)
response=$(echo "$result" | awk -F ';' '$1 ~ /^info/ && match($1,/[0-9].*$/) {sum+=substr($1,RSTART,RLENGTH)} END {print sum}')
if [ -n "$response" ]; then
  echo "$response"
else
  echo "$result"
fi
