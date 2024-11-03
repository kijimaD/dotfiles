#!/bin/bash
set -eux

######################
# 引数の文字列を通知する
######################

cd `dirname $0`

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

setpriv --euid=1000 notify-send $1
