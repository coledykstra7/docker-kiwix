#!/bin/sh
# Script to restart kiwix-serve
pkill kiwix-serve
sleep 2
nohup /kiwix-serve-cmd.sh &
