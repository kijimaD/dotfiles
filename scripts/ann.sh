#!/bin/bash
set -eux

############################################
# 引数で渡された文字列を読み上げるスクリプト
############################################

export XDG_RUNTIME_DIR="/run/user/1000"

cd `dirname $0`

spd-say "$1"
sleep 1
spd-say "$1"
