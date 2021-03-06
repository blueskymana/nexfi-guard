#!/bin/sh

. /etc/profile

RM="/bin/rm"
KILLALL="/usr/bin/killall"
SLEEP="/bin/sleep"
IFCONFIG="/sbin/ifconfig"
IW="/usr/sbin/iw"
BRCTL="/usr/sbin/brctl"
BATCTL="/usr/sbin/batctl"

BSSID=$(uci get netconfig.@adhoc[0].bssid)
MESHID=$(uci get netconfig.@adhoc[0].meshid)
FREQ=$(uci get netconfig.@adhoc[0].freq)

# set channel
CHANNEL_FREQ="2447"

get_channel_freq()
{
    return $(iw dev adhoc0 info | grep channel | awk -F ' ' '{ print $2 }')
}

get_channel_freq;
curr_freq=$?

if [ "$curr_freq" = "3" ];
then
    CHANNEL_FREQ="2447"
elif [ "$curr_freq" = "8" ];
then
    CHANNEL_FREQ="2462"
elif [ "$curr_freq" = "11" ];
then
    CHANNEL_FREQ="2422"
fi

uci set netconfig.@adhoc[0].freq=$CHANNEL_FREQ
uci commit netconfig

$IFCONFIG br-lan down
$IFCONFIG adhoc0 down
$IFCONFIG adhoc0 up
$SLEEP 1
$IW dev adhoc0 set type ibss
$IW dev adhoc0 ibss leave
$IW dev adhoc0 ibss join $MESHID $CHANNEL_FREQ HT20 fixed-freq $BSSID
$SLEEP 2
$IFCONFIG bat0 up
$IFCONFIG br-lan up
$BRCTL addif br-lan bat0
$BATCTL dat 0

$NEXFI_ROOT/script-files/network/nexfi_ebtables.sh
