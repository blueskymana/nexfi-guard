#!/bin/sh

. /etc/profile

BSSID=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].bssid)

if [ "$1" = "1" ];
then
    echo -n $2 $3
    uci set netconfig.@adhoc[0].bssid=$2
    uci set netconfig.@adhoc[0].meshid=$3
    uci commit netconfig
elif [ "$1" = "0" ];
then
    echo -n $BSSID
elif [ "$1" = "2" ];
then
    echo -n "network restart"
    $NEXFI_ROOT/script-files/channel-restart.sh
fi
