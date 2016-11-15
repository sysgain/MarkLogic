######################################################################################################
#	File         : database-create.sh
#	Description  : This script will create a database in the local host
#	Author	     : T S Pradeep Kumar
#	Date		     : 11/15/2016
# Version		 : V1.0
######################################################################################################

#!/bin/bash

hostname=$1
username=$2
password=$3
dbname=$4
curl -X POST  --anyauth -u $username:$password --header "Content-Type:application/json" \
  -d '{"database-name":"'"$dbname"'"}' http://$hostname:8002/manage/v2/databases
