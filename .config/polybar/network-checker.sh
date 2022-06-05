#!/bin/sh

CHANGE=$(emacsclient -e '(kd/change-network-p)' | cut -d '"' -f 2)
COLOR=$(emacsclient -e '(kd/bar-color)' | cut -d '"' -f 2)

echo $CHANGE
echo $COLOR

if [ $CHANGE = t ]; then
    export BAR_COLOR=$COLOR
    polybar top &
fi
