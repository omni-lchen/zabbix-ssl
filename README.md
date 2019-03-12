# Zabbix-SSL

SSL certificates expiry date monitoring separated by groups, suitable for monitoring hundreds of websites.
Support port per domain.

**Installation**

Pre-requisites: Zabbix Sender, Openssl Client, JQ - https://stedolan.github.io/jq/

1. Copy the scripts and SSL configuration to zabbix external scripts directory: /usr/lib/zabbix/externalscripts

2. Add domains and ports to the configuration file: ssl/sslCertDomains.json

3. Create zabbix host and link with SSL template, add macro to the host: {$DOMAIN_GROUP}, macro value should match the group name in the SSL configuration file.

4. Create a cron job to send data to the zabbix host, see description in "sslCertExpiryCheck.sh"
