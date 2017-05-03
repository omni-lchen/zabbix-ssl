#!/bin/bash

#Author: Long Chen
#Date: 25/01/2017
#Description: A script to get a list of domains in json format
#Requires: jq - https://stedolan.github.io/jq/

DOMAIN_GROUP=$1
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
ALL_DOMAINS=$SCRIPT_DIR"/ssl/sslCertDomains.json"
QUERY_DOMAINS=$(eval "cat $ALL_DOMAINS | jq -r '."$DOMAIN_GROUP"[] .domain' | xargs 2>/dev/null")

for domain in $QUERY_DOMAINS; do
  domainlist="$domainlist,"'{"{#DOMAIN}":"'${domain# }'"}'
done
echo '{"data":['${domainlist#,}']}'