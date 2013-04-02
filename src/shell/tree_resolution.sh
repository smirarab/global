#!/bin/sh
sed -e "s/[^(]//g" $1|wc -m|awk '{print $1 - 3}'
