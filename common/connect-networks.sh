#!/usr/bin/env bash -e

wifiint=""
wifissid=""
wifipsk=""

usage() {                                      # Function: Print a help message.
  echo "Usage: $0 [ -i WIFI_INT_NAME ] [ -s SSID ] [ -p PSK]" 1>&2 
}

exit_abnormal() {                              # Function: Exit with error.
  usage
  exit 1
}

while getopts "i:s:p:" option; do
   case "${option}"
      in
         i) wifiint=${OPTARG};;
         s) wifissid=${OPTARG};;
         p) wifipsk=${OPTARG};;
	 :) exit_abnormal;;
   esac
done

#echo interface "$wifiint", psk  "$wifipsk", ssid  "$wifissid"

#echo iwctl station "$wifiint" scan
iwctl station "$wifiint" scan
iwctl station "$wifiint" get-networks
iwctl --passphrase "$wifipsk" station "$wifiint" connect "$wifissid"
#/usr/bin/ip -4 addr show $wifiint
exit 0
