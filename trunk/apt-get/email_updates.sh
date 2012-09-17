#!/bin/bash

# $Id$
# $HeadURL$

# Test script

IFS=$'\n'
testing=($(apt-get dist-upgrade -s | grep -iE '^Inst.*$'))
#echo ${testing[@]}

for i in "${testing[@]}" 
do
    if [[ "$i" == "Inst libexchange-storage1.2-3 [2.28.3.1-0ubuntu6] (2.28.3.1-0ubuntu6.1 Ubuntu:10.04/lucid-updates)" ]]; then
        echo "$i equals the string" 
    fi
done
