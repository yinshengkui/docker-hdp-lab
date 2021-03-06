#!/bin/bash
########
# Author: Ratish Maruthiyodan
# Project: Docker HDP Lab
# Description: The script is called by maggie_tunnel.sh script. The script creates corresponding tunnel device on Altair node
#########

__find_free_ip()
{
	for i in {201..250}
	do
	  ifconfig | grep -q "192.168.$i"
	  if [ $? -ne 0 ]
	  then
		FREE_NW="192.168.$i"
		break
	  fi
	done
}

#set -x
if [ $# -ne 2 ]
then
	echo "expected interface name"
	echo "Usage:: free_tunip.sh <Interface_Name> <Remote_IP>"
	exit 1
fi
INT_NAME=$1
REMOTE_IP=$2

ifconfig -a | grep -q $INT_NAME
if [ $? -eq 0 ]
then
	ip tunnel delete $INT_NAME
fi

ip tunnel | grep -q "$REMOTE_IP"
if [ $? -eq 0 ]
then
	tun=`ip tunnel | grep "$REMOTE_IP" | cut -d ":" -f1`
	ip tunnel delete $tun
fi

ip tunnel add $INT_NAME  mode ipip remote $REMOTE_IP local `hostname -i` dev em1
__find_free_ip
ifconfig $INT_NAME $FREE_NW.1 netmask 255.255.255.0 pointopoint $FREE_NW.2
ifconfig $INT_NAME mtu 1280 up

echo $FREE_NW
