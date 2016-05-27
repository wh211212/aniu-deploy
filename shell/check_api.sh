#!/bin/bash
## ####################################
# functions: check api status
#######################################
# ChangeLog:
#   2016-05-27  wh    initial creation      
######################################
#
for apiurl in $(cat ./api_url.txt)
do
status_code=`curl -o /dev/null -m 10 --connect-timeout 10 -s -w %{http_code} $apiurl`
echo "$apiurl status code:\t $status_code"
if [ "$status_code" = "200" ]; then
       echo "api status code:\t $status_code" 
    else
       echo "api status code:\t $apiurl not alive" >> /data/scripts/api_status.log
fi
sleep 3
done
