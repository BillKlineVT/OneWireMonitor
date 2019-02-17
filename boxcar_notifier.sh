#!/bin/bash
set -x
# Sends a Boxcar push notification through the Boxcar HTTP API
# Usage examples
#  $ bc 			  # Just sends a notification with title 'bc'
#  $ bc "Done"			  # Sends a notification with title 'Done'
#  $ echo foobar | bc 		  # Sends a notification with title 'bc' and message body 'foobar'
#  $ echo foobar | bc "Done"      # Sends a notification with title 'Done' and message body 'foobar'
#
# Expects a file ~/.boxcar to exist with content like
# BOXCAR_ACCESS_TOKEN=<your boxcar access token goes here>

#. ~/.boxcar
TITLE=${1:-bc}
BOXCAR_SOUND=${2:-score}
if [[ $3 == "B" ]];then
	BOXCAR_ACCESS_TOKEN=<token>
elif [[ $3 == "A" ]];then
	BOXCAR_ACCESS_TOKEN=<token>
fi

# Only read a message if NOT a tty, e.g. if stdin is piped in
#tty -s
#if [[ ! $? == 0 ]]; then
#	read MESSAGE
#fi

MESSAGE=$4

curl -d "user_credentials=${BOXCAR_ACCESS_TOKEN}" \
	    -d "notification[title]=${TITLE}" \
	    -d "notification[long_message]=${MESSAGE}" \
	    -d "notification[sound]=${BOXCAR_SOUND}" \
	    https://new.boxcar.io/api/notifications

set -
