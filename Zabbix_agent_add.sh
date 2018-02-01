#!/bin/bash
#####################################################
# Zabbix Agent Add Script
#  Author: Vivek Lanjekar.
#####################################################
# Contact:
#  vivek.lanjekar@gmail.com.
#####################################################
# Description:
#  Use this script to add agents via zabbix api, this
#  can be used if u want to bulk add servers to zabbix
#  for any active checks without agents.
#
# HOW TO USE:
# This script takes parameters from $1 and $2
# Example : sh /Zabbix_agent_add.sh IPaddress Hostname
# This Script works with latest Zabbix 3.4.4.
#####################################################

IP=$1
HOST_NAME=$2
ZABBIX_USER='Zabbix_user'
ZABBIX_PASS='Zabbix_password'
ZABBIX_SERVER='Zabbix_URL'
API='$ZABBIX_SERVER/api_jsonrpc.php'
HOSTGROUPID='xx'
TEMPLATEID='xxxxx'

authenticate() {
echo `curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${ZABBIX_USER}"\",\"password\":\""${ZABBIX_PASS}"\"},\"auth\": null,\"id\":0}" $API`
}
AUTH_TOKEN=`echo $(authenticate)|jq -r .result`


create_host() {
echo `curl -k -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"host.create\",\"params\":{\"host\":\"$HOST_NAME\",\"interfaces\":[{\"type\":1,\"main\":1,\"useip\":1,\"ip\":\"$IP\",\"dns\":\"\",\"port\":\"10050\"}],\"groups\":[{\"groupid\":\"$HOSTGROUPID\"}],\"templates\":[{\"templateid\":\"$TEMPLATEID\"}],\"inventory_mode\":0,\"inventory\":{}},\"auth\":\"$AUTH_TOKEN\",\"id\":1}"  $API`
}


 output=$(create_host)


 echo $output | grep -q "hostids"
 rc=$?
 if [ $rc -ne 0 ]
  then
      echo -e "Error in adding host ${HOST_NAME} at `date`:\n"
      echo $output | grep -Po '"message":.*?[^]",'
      echo $output | grep -Po '"data":.*?[^]"'
      exit
 else
      echo -e "\nHost ${HOST_NAME} added successfully\n"
      # start zabbix agent
      #service zabbix-agent start
      exit
 fi
