#!/bin/bash
###################################################################################################################
#	File         : add-other-nodes.sh
#	Description  : Use this script to initialize and add one or more hosts to a
# 				       MarkLogic Server cluster. The first (bootstrap) host for the cluster should already 
#                be fully initialized.
# Usage : sh filename.sh masternode user password auth_mode n_retry retry_interval licensekey licnsee joiningnode
#################################################################################################################

USER=$2
PASS=$3
AUTH_MODE=$4
N_RETRY=$5
RETRY_INTERVAL=$6
LICENSEKEY=$7
LICENSEE=$8
LOGFILEDIR=$9


NOW=$(date +"%Y-%m-%d")
#mkdir /home/$LOGFILEDIR/logfiles

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
  echo "ERROR: Line $3: Failed to restart $1" >> /home/$LOGFILEDIR/logfiles/log-setupadditionalnode-$NOW.log
  exit 1
}

if [ $# -ge 10 ]; then
  BOOTSTRAP_HOST=$1
  shift 9
else
  echo "ERROR: At least two hostnames are required." >&2 >> /home/$LOGFILEDIR/logfiles/log-setupadditionalnode-$NOW.log
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
  echo "Adding host to cluster: $JOINING_HOST..." >> /home/$LOGFILEDIR/logfiles/log-setupadditionalnode-$NOW.log

  # (1) Initialize MarkLogic Server on the joining host
  TIMESTAMP=`$CURL -X POST \
   -H "Content-type:application/x-www-form-urlencoded" \
   --data-urlencode "license-key=${LICENSEKEY}" \
   --data-urlencode "licensee=${LICENSEE}" \
   -d "" http://${JOINING_HOST}:8001/admin/v1/init \
     | grep "last-startup" \
     | sed 's%^.*<last-startup.*>\(.*\)</last-startup>.*$%\1%'`

     sleep 15

  if [ "$TIMESTAMP" == "" ]; then
    echo "ERROR: Failed to initialize $JOINING_HOST" >&2 >> /home/$LOGFILEDIR/logfiles/log-setupadditionalnode-$NOW.log
    exit 1
  fi
  restart_check $JOINING_HOST $TIMESTAMP $LINENO
  
  #Retrieve the joining host's configuration
    JOINER_CONFIG=`$CURL -X GET -H "Accept: application/xml" \
        http://${JOINING_HOST}:8001/admin/v1/server-config`
  echo $JOINER_CONFIG | grep -q "^<host"
  if [ "$?" -ne 0 ]; then
    echo "ERROR: Failed to fetch server config for $JOINING_HOST" >> /home/$LOGFILEDIR/logfiles/log-setupadditionalnode-$NOW.log
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
    echo "ERROR: Failed to fetch cluster config from $BOOTSTRAP_HOST" >> /home/$LOGFILEDIR/logfiles/log-setupadditionalnode-$NOW.log
    exit 1
  fi
  if [ `file cluster-config.zip | grep -cvi "zip archive data"` -eq 1 ]; then
    echo "ERROR: Failed to fetch cluster config from $BOOTSTRAP_HOST" >> /home/$LOGFILEDIR/logfiles/log-setupadditionalnode-$NOW.log
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

  echo "...$JOINING_HOST successfully added to the cluster." >> /home/$LOGFILEDIR/logfiles/log-setupadditionalnode-$NOW.log
done
