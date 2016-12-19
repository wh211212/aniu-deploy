#!/bin/bash
###############################################################################################################################
# Functions: check process status
# ###############################
# Changelog:
# 2016-12-09      shaon     initial 
####################################
# Crontab Set:
# */1 * * * * top -b -n 1 >/tmp/top.txt
################################################################################################################################
# variables defined
TABLESPACE=`tail -n +8 /tmp/top.txt | awk '{a[$NF]+=$6}END{for(k in a)print a[k]/1024,k}' | sort -gr | head -10 | cut -d" " -f2`
COUNT=`echo "$TABLESPACE" | wc -l`
INDEX=0
echo '{"data":['
echo "$TABLESPACE" | while read LINE; do
    echo -n '{"{#TABLENAME}":"'$LINE'"}'
    INDEX=`expr $INDEX + 1`
    if [ $INDEX -lt $COUNT ]; then
        echo ','
    fi
done
echo ']}'
