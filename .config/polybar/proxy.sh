#!/bin/bash
set -eu

# プロキシ設定を表示するコマンド

status=`gsettings get org.gnome.system.proxy mode | sed -e "s/^'//" -e "s/'$//"`
declare result

if [ $status == "manual" ]; then
    result="%{F#008000}%{F-}"
elif [ $status == "none" ]; then
    result="%{F#990000}%{F-}"
fi

echo $result
