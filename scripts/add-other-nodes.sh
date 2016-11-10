#!/bin/bash
######################################################################################################
#	File         : data-disk-mount.sh
#	Description  : Use this script to initialize and add one or more hosts to a
# 				       MarkLogic Server cluster. The first (bootstrap) host for the cluster should already 
#                be fully initialized.
#	Author	     : T S Pradeep Kumar
#	Date		     : 11/10/2016
# Version		   : V1.0
# Usage        : 
######################################################################################################

USER="sysgain"
PASS="Sysga1n4205!"
AUTH_MODE="anyauth"
N_RETRY=5
RETRY_INTERVAL=10

NOW=$(date +"%Y-%m-%d")

######################################################################################################
# restart_check(hostname, baseline_timestamp, caller_lineno)
#
# Use the timestamp service to detect a server restart, given a
# a baseline timestamp.
# Returns 0 if restart is detected, exits with an error if not.
######################################################################################################

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
  echo "ERROR: Line $3: Failed to restart $1" >> log-setupadditionalnode-$NOW.log
  exit 1
}

if [ $# -ge 2 ]; then
  BOOTSTRAP_HOST=$1
  shift
else
  echo "ERROR: At least two hostnames are required." >&2 >> log-setupadditionalnode-$NOW.log
  exit 1
fi
ADDITIONAL_HOSTS=$@

# Curl command for all requests
CURL="curl -s -S"

# Curl command when authentication is required
AUTH_CURL="${CURL} --${AUTH_MODE} --user ${USER}:${PASS}"

#####################################################################################################
#
# Add one or more hosts to a cluster.
# 
#####################################################################################################

for JOINING_HOST in $ADDITIONAL_HOSTS; do
  echo "Adding host to cluster: $JOINING_HOST..." >> log-setupadditionalnode-$NOW.log

  # (1) Initialize MarkLogic Server on the joining host
  TIMESTAMP=`$CURL -X POST -d "" \
     http://${JOINING_HOST}:8001/admin/v1/init \
     | grep "last-startup" \
     | sed 's%^.*<last-startup.*>\(.*\)</last-startup>.*$%\1%'`
  if [ "$TIMESTAMP" == "" ]; then
    echo "ERROR: Failed to initialize $JOINING_HOST" >&2 >> log-setupadditionalnode-$NOW.log
    exit 1
  fi
  restart_check $JOINING_HOST $TIMESTAMP $LINENO
  
  #Retrieve the joining host's configuration
    JOINER_CONFIG=`$CURL -X GET -H "Accept: application/xml" \
        http://${JOINING_HOST}:8001/admin/v1/server-config`
  echo $JOINER_CONFIG | grep -q "^<host"
  if [ "$?" -ne 0 ]; then
    echo "ERROR: Failed to fetch server config for $JOINING_HOST" >> log-setupadditionalnode-$NOW.log
    exit 1
  fi
  
  #####################################################################################################
  #
  # Send the joining host's config to the bootstrap host, receive
  # the cluster config data needed to complete the join. Save the
  # response data to cluster-config.zip.
  #
  #####################################################################################################
  
  $AUTH_CURL -X POST -o cluster-config.zip -d "group=Default" \
        --data-urlencode "server-config=${JOINER_CONFIG}" \
        -H "Content-type: application/x-www-form-urlencoded" \
        http://${BOOTSTRAP_HOST}:8001/admin/v1/cluster-config
  if [ "$?" -ne 0 ]; then
    echo "ERROR: Failed to fetch cluster config from $BOOTSTRAP_HOST" >> log-setupadditionalnode-$NOW.log
    exit 1
  fi
  if [ `file cluster-config.zip | grep -cvi "zip archive data"` -eq 1 ]; then
    echo "ERROR: Failed to fetch cluster config from $BOOTSTRAP_HOST" >> log-setupadditionalnode-$NOW.log
    exit 1
  fi
  #####################################################################################################
  #
  #     Send the cluster config data to the joining host, completing 
  #     the join sequence.
  #
  #####################################################################################################  
  
  TIMESTAMP=`$CURL -X POST -H "Content-type: application/zip" \
      --data-binary @./cluster-config.zip \
      http://${JOINING_HOST}:8001/admin/v1/cluster-config \
      | grep "last-startup" \
      | sed 's%^.*<last-startup.*>\(.*\)</last-startup>.*$%\1%'`
  restart_check $JOINING_HOST $TIMESTAMP $LINENO
  rm ./cluster-config.zip

  echo "...$JOINING_HOST successfully added to the cluster." >> log-setupadditionalnode-$NOW.log
done
