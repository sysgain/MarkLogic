######################################################################################################
#	File         : forest-create.sh
#	Description  : This script will create a forest in the local host
#	Author	     : T S Pradeep Kumar
#	Date		 : 11/15/2016
#   Version		 : V1.0
######################################################################################################

#!/bin/bash

hostname=$1
username=$2
password=$3
forestname=$4
databasename=$5

curl --anyauth --user $username:$password -X POST \
-d '{"forest-name":"'"$forestname"'", "host": "'"$hostname"'.marklogic.com", "database": "'"$databasename"'"}' \
-i -H "Content-type: application/json" http://$hostname:8002/manage/v2/forests
