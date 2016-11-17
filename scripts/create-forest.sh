######################################################################################################
#	File         : forest-create.sh
#	Description  : This script will create a forest in the local host
#	Author	     : T S Pradeep Kumar
#	Date		 : 11/15/2016
# Version		 : V1.0
######################################################################################################

#!/bin/bash

username=$1
password=$2
forestname=$3
databasename=$4
localhostname=`hostname`

MLHOSTNAME=`curl --anyauth --user $username:$password -X GET \
-i -H "Content-type: application/json" http://localhost:8002/manage/v2/hosts | grep "<nameref>" | grep "$localhostname" | sed s/\<nameref\>// | sed s/\<.nameref\>// | tr -s ' ' '#' | sed s/#//`

curl --anyauth --user $username:$password -X POST \
-d '{"forest-name":"'"$forestname"'", "host": "'"$MLHOSTNAME"'", "database": "'"$databasename"'"}' \
-i -H "Content-type: application/json" http://localhost:8002/manage/v2/forests