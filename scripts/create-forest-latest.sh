######################################################################################################
#	File         : forest-create.sh
#	Description  : This script will create a forest in the local host
#	Author	     : T S Pradeep Kumar
#	Date		     : 11/15/2016
# Version		   : V1.0
# Usage        : sh filename.sh <localhost> <user-name> <password> <forest-name> <database-name>
######################################################################################################

#!/bin/bash

hostname=$1
username=$2
password=$3
forestname=$4
databasename=$5
MLHOSTNAME=`curl --anyauth --user $username:$password -X GET \
-i -H "Content-type: application/json" http://localhost:8002/manage/v2/hosts | grep "<nameref>" | tail -2 | sed s/\<nameref\>// | sed s/\<.nameref\>// | tr -s ' ' '#' | sed s/#//`

curl --anyauth --user $username:$password -X POST \
-d '{"forest-name":"'"$forestname"'", "host": "'"$MLHOSTNAME"'", "database": "'"$databasename"'"}' \
-i -H "Content-type: application/json" http://$hostname:8002/manage/v2/forests
