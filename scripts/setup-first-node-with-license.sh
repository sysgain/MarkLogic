######################################################################################################
#	File         :setup-first-node.sh
#	Description  : This script will setup the head/first node in the cluster
######################################################################################################

#!/bin/bash

BOOTSTRAP_HOST=$1
USER=$2
PASS=$3
AUTH_MODE=$4
SEC_REALM=$5
N_RETRY=$6
RETRY_INTERVAL=$7
LICENSEKEY=$8
LICENSEE=$9

#BOOTSTRAP_HOST="localhost"
#USER="sysgain1"
#PASS="Sysga1n4205!"
#AUTH_MODE="anyauth"
#SEC_REALM="public"
#N_RETRY=5
#RETRY_INTERVAL=10

#Log file to record all the activities
NOW=$(date +"%Y-%m-%d")
mkdir /home/tspadmin/logfiles
#############################################################
# restart_check(hostname, baseline_timestamp, caller_lineno)
#
# Use the timestamp service to detect a server restart, given a
# a baseline timestamp. 
# Returns 0 if restart is detected, exits with an error if not.
#
function restart_check {
  LAST_START=`$AUTH_CURL "http://$1:8001/admin/v1/timestamp"`
  for i in `seq 1 ${N_RETRY}`; do
    if [ "$2" == "$LAST_START" ] || [ "$LAST_START" == "" ]; then
      sleep ${RETRY_INTERVAL}
	LAST_START=`$AUTH_CURL "http://$1:8001/admin/v1/timestamp"`
    else 
      return 0
    fi
  done
  echo "ERROR: Line $3: Failed to restart $1" >> /home/tspadmin/logfiles/log-setup-first-node-$NOW.log
  exit 1
}

# Suppress progress meter, but still show errors
CURL="curl -s -S"
# Add authentication related options, required once security is initialized
AUTH_CURL="${CURL} --${AUTH_MODE} --user ${USER}:${PASS}"

###################################################################
# Bring up the first (or only) host in the cluster. The following
# requests are sent to the target host:
#   (1) POST /admin/v1/init
#   (2) POST /admin/v1/instance-admin?admin-user=X&admin-password=Y&realm=Z
# GET /admin/v1/timestamp is used to confirm restarts.
###################################################################

# (1) Initialize the server
echo "Initializing $BOOTSTRAP_HOST..." >> /home/tspadmin/logfiles/log-setup-first-node-$NOW.log
#$CURL -X POST -d "" http://${BOOTSTRAP_HOST}:8001/admin/v1/init
#sleep 10

$CURL --anyauth -i -X POST \
   -H "Content-type:application/x-www-form-urlencoded" \
   --data-urlencode "license-key=${LICENSEKEY}" \
   --data-urlencode "licensee=${LICENSEE}" \
   http://localhost:8001/admin/v1/init


TIMESTAMP=`$CURL -X POST \
   -H "Content-type: application/x-www-form-urlencoded" \
   --data "admin-username=${USER}" --data "admin-password=${PASS}" \
   --data "realm=${SEC_REALM}" \
   http://${BOOTSTRAP_HOST}:8001/admin/v1/instance-admin \
   | grep "last-startup" \
   | sed 's%^.*<last-startup.*>\(.*\)</last-startup>.*$%\1%'`
if [ "$TIMESTAMP" == "" ]; then
  echo "ERROR: Failed to get instance-admin timestamp." >&2 >> /home/tspadmin/logfiles/log-setup-first-node-$NOW.log
  exit 1
fi

# Test for successful restart
restart_check $BOOTSTRAP_HOST $TIMESTAMP $LINENO

echo "Initialization complete for $BOOTSTRAP_HOST..." >> /home/tspadmin/logfiles/log-setup-first-node-$NOW.log
exit 0
