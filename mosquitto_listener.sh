#!/bin/bash
#set -x

#A_OPENER_PIO=/mnt/1wire/29.7C1507000000/PIO.1
#B_OPENER_PIO=/mnt/1wire/29.7C1507000000/PIO.0

#mosquitto_sub -t home/garage/a_garage_opener >/tmp/a_garage_opener &
#mosquitto_sub -t home/garage/b_garage_opener >/tmp/b_garage_opener &
#mosquitto_sub -t home/floor1/frontroom/temperature >/tmp/floor1_frontroom_temp &
#mosquitto_sub -t home/floor2/office/temperature >/tmp/floor2_office_temp &
#mosquitto_sub -t home/floor2/mediaroom/temperature > /tmp/floor2_mediaroom_temp &
#mosquitto_sub -t home/floor1/master_bedroom/temperature > /tmp/floor1_masterbedroom_temp &
#mosquitto_sub -t home/floor2/office_vent/temperature > /tmp/floor2_officevent_temp &
mosquitto_sub -t home/floor1/livingroom/mediacabinet_temp > /tmp/floor1_mediacabinet_temp &
mosquitto_sub -t home/floor1/livingroom/mediacabinet_relay1 > /tmp/floor1_mediacabinet_relay1 &

while (true); do
	if [ -e /tmp/a_garage_opener ];then
		if [[ `grep GO /tmp/a_garage_opener` != "" ]];then
	  		echo "trigger a opener relay"
			echo 1 > $A_OPENER_PIO
	  		sleep 1
	  		echo "turn off relay"
			echo 0 > $A_OPENER_PIO
	  		echo "" > /tmp/a_garage_opener
		fi
	fi

	if [ -e /tmp/b_garage_opener ];then
                if [[ `grep GO /tmp/b_garage_opener` != "" ]];then
                        echo "trigger b opener relay"
			echo 1 > $B_OPENER_PIO
                        sleep 1
                        echo "turn off relay"
			echo 0 > $B_OPENER_PIO
                        echo "" > /tmp/b_garage_opener
                fi
        fi

        if [ -s /tmp/floor1_mediacabinet_temp ];then
                TEMP=`tail -n1 /tmp/floor1_mediacabinet_temp`
                DATA_STRING='{"version":"1.0.0", "datastreams":[{"id":"floor1_mediacabinet_temp", "current_value":"'"$TEMP"'"}]}'
                curl -ssss \
                 --request PUT \
                 --header "X-ApiKey: <enter your key here>" \
                 --data "$DATA_STRING" \
                 https://api.xively.com/v2/feeds/<feed_number> > /dev/null
		echo "mediacabinet temp message received"
		#clear temp file
		#rm /tmp/floor1_mediacabinet_temp
        fi

        if [ -s /tmp/floor1_mediacabinet_relay1 ];then
                TEMP=`tail -n1 /tmp/floor1_mediacabinet_relay1`
                DATA_STRING='{"version":"1.0.0", "datastreams":[{"id":"floor1_mediacabinet_relay1", "current_value":"'"$TEMP"'"}]}'
                curl -ssss \
                 --request PUT \
                 --header "X-ApiKey: <enter your key here>" \
                 --data "$DATA_STRING" \
                 https://api.xively.com/v2/feeds/<feed_number> > /dev/null
                echo "mediacabinet relay1 message received"
		#clear temp file
		#rm /tmp/floor1_mediacabinet_relay1
        fi


	if [ -s /tmp/floor1_frontroom_temp ];then
		TEMP=`cat /tmp/floor1_frontroom_temp`
		DATA_STRING='{"version":"1.0.0", "datastreams":[{"id":"floor1_frontroom_temp", "current_value":"'"$TEMP"'"}]}'
		curl -ssss \
		 --request PUT \
		 --header "X-ApiKey: <enter your key here>" \
		 --data "$DATA_STRING" \
		 https://api.xively.com/v2/feeds/<feed_number> > /dev/null
	fi

        if [ -s /tmp/floor2_officevent_temp ];then
                TEMP=`cat /tmp/floor2_officevent_temp`
                DATA_STRING='{"version":"1.0.0", "datastreams":[{"id":"floor2_officevent_temp", "current_value":"'"$TEMP"'"}]}'
                curl -ssss \
                 --request PUT \
                 --header "X-ApiKey: <enter your key here>" \
                 --data "$DATA_STRING" \
                 https://api.xively.com/v2/feeds/<feed_number> > /dev/null
        fi

        if [ -s /tmp/floor2_office_temp ];then
                TEMP=`cat /tmp/floor2_office_temp`
                DATA_STRING='{"version":"1.0.0", "datastreams":[{"id":"floor2_office_temp", "current_value":"'"$TEMP"'"}]}'
                curl -ssss \
                 --request PUT \
                 --header "X-ApiKey: <enter your key here>" \
                 --data "$DATA_STRING" \
                 https://api.xively.com/v2/feeds/<feed_number> > /dev/null
        fi

        if [ -s /tmp/floor1_masterbedroom_temp ];then
                TEMP=`cat /tmp/floor1_masterbedroom_temp`
                DATA_STRING='{"version":"1.0.0", "datastreams":[{"id":"floor1_masterbedroom_temp", "current_value":"'"$TEMP"'"}]}'
                curl -ssss \
                 --request PUT \
                 --header "X-ApiKey: <enter your key here>" \
                 --data "$DATA_STRING" \
                 https://api.xively.com/v2/feeds/<feed_number> > /dev/null
        fi

        if [ -s /tmp/floor2_mediaroom_temp ];then
                TEMP=`cat /tmp/floor2_mediaroom_temp`
                DATA_STRING='{"version":"1.0.0", "datastreams":[{"id":"floor2_mediaroom_temp", "current_value":"'"$TEMP"'"}]}'
                curl -ssss \
                 --request PUT \
                 --header "X-ApiKey: <enter your key here>" \
                 --data "$DATA_STRING" \
                 https://api.xively.com/v2/feeds/<feed_number> > /dev/null
        fi

	sleep 1

done
#set -
