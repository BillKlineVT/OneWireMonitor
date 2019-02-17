#!/bin/bash
#set -x

#topic for garage door contacts = home/garage/b_garage_door, home/garage/a_garage_door
#topic for garage door openers = home/garage/b_garage_opener, home/garage/a_garage_opener
#topic for temperature = home/floor1/frontroom/temperature, home/floor2/mediaroom/temperature, home/garage/temperature

alarm_log=/tmp/alarm_log.txt
MQTT_HOST=192.168.1.27
ALARM_SWITCH_DIR=/mnt/1wire/29.741507000000
GARAGE_SWITCH_DIR=/mnt/1wire/29.7C1507000000
e_FRONT_DOORS=0
e_MASTER_BDRM_WINDOWS=3
e_PATIO_DOOR=2
e_DOWNSTAIRS_WINDOWS=1
e_UPSTAIRS_WINDOWS=4
e_A_CLOSED_SENSOR=6
e_A_OPEN_SENSOR=3
e_B_OPEN_SENSOR=5
e_B_CLOSED_SENSOR=4
e_A_OPENER_TRIGGER=1
e_B_OPENER_TRIGGER=0
status_b_garage=-1
status_a_garage=-1

#loop counter
counter=5
TEMP_UPDATE_PERIOD=60
temp_counter=$TEMP_UPDATE_PERIOD

function ALERT
{
  # args passed in: date (epoch time), message (string)
  # convert date to human readable string
  int_date=$1
  str_date=`date -d @$int_date`
  alert_mqtt_topic=$2
  alert_value=$3
  echo -e $str_date " ::: " "$alert_mqtt_topic $alert_value\n"  >> $alarm_log
  mosquitto_pub -h $MQTT_HOST -t $2 -m $3
}

function status_FRONT_DOORS { return `cat $ALARM_SWITCH_DIR/sensed.$e_FRONT_DOORS`; }
function status_MASTER_BDRM_WINDOWS { return `cat $ALARM_SWITCH_DIR/sensed.$e_MASTER_BDRM_WINDOWS`; }
function status_PATIO_DOOR { return `cat $ALARM_SWITCH_DIR/sensed.$e_PATIO_DOOR`; }
function status_DOWNSTAIRS_WINDOWS { return `cat $ALARM_SWITCH_DIR/sensed.$e_DOWNSTAIRS_WINDOWS`; }
function status_UPSTAIRS_WINDOWS { return `cat $ALARM_SWITCH_DIR/sensed.$e_UPSTAIRS_WINDOWS`; }

function status_A_CLOSED_SENSOR { return `cat $GARAGE_SWITCH_DIR/sensed.$e_A_CLOSED_SENSOR`; }
function status_A_OPEN_SENSOR { return `cat $GARAGE_SWITCH_DIR/sensed.$e_A_OPEN_SENSOR`; }
function status_B_CLOSED_SENSOR { return `cat $GARAGE_SWITCH_DIR/sensed.$e_B_CLOSED_SENSOR`; }
function status_B_OPEN_SENSOR { return `cat $GARAGE_SWITCH_DIR/sensed.$e_B_OPEN_SENSOR`; }
function status_A_OPENER_TRIGGER { return `cat $GARAGE_SWITCH_DIR/sensed.$e_A_OPENER_TRIGGER`; }
function status_B_OPENER_TRIGGER { return `cat $GARAGE_SWITCH_DIR/sensed.$e_B_OPENER_TRIGGER`; }

function C_to_F
{
	#args: temp in celsius
	temp_C=$1
	temp_F=`echo "9*$temp_C/5+32" | bc -l`
	echo $temp_F
}

while [[ true ]]; do
	# loop and poll DS2408 switch for any latched events
	if [ -e $ALARM_SWITCH_DIR ]; then
	  #echo "alarm 1wire appears to be up..." at `date`
	  #parse latch values into indiv. zones
	  if [[ `cat $ALARM_SWITCH_DIR/latch.$e_FRONT_DOORS` = 1  || $counter = 5 ]];then
	    #echo "front doors latched"
	    # latch occurred, check current state of door
	    status_FRONT_DOORS
	    if [ "$?" -eq 1 ]; then
	      	ALERT `date +%s` "home/floor1/front_door" "OPEN"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "Front Door OPEN" bell-modern B ""
	    else
	      	ALERT `date +%s` "home/floor1/front_door" "CLOSED"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "Front Door CLOSED" "done" B ""
	    fi
	  fi
	  if [[ `cat $ALARM_SWITCH_DIR/latch.$e_MASTER_BDRM_WINDOWS` = 1  || $counter = 5 ]];then
            #echo "master bedroom windows latched"
	    # latch occurred, check current state of windows
            status_MASTER_BDRM_WINDOWS
            if [ "$?" -eq 1 ]; then
              	ALERT `date +%s` "home/floor1/master_bedroom/windows" "OPEN"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "Master Bedroom Windows OPEN" bell-modern B ""
            else
              	ALERT `date +%s` "home/floor1/master_bedroom/windows" "CLOSED"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "Master Bedroom Windows CLOSED" "done" B ""
            fi
          fi
	  if [[ `cat $ALARM_SWITCH_DIR/latch.$e_PATIO_DOOR` = 1  || $counter = 5 ]];then
            #echo "patio door latched"
            status_PATIO_DOOR
            if [ "$?" -eq 1 ]; then
              	ALERT `date +%s` "home/floor1/living_room/patio_door" "OPEN"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "Patio Door OPEN" bell-modern B ""
            else
	        ALERT `date +%s` "home/floor1/living_room/patio_door" "CLOSED"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "Patio Door CLOSED" "done" B ""
            fi
          fi
	  if [[ `cat $ALARM_SWITCH_DIR/latch.$e_DOWNSTAIRS_WINDOWS` = 1  || $counter = 5 ]];then
            #echo "downstairs windows latched"
            # latch occurred, check current state of windows
            status_DOWNSTAIRS_WINDOWS
            if [ "$?" -eq 1 ]; then
              	ALERT `date +%s` "home/floor1/all_rooms/windows" "OPEN"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "Downstairs Windows OPEN" bell-modern B ""
            else
              	ALERT `date +%s` "home/floor1/all_rooms/windows" "CLOSED"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "Downstairs Windows CLOSED" "done" B ""
            fi
	    echo
          fi
	  if [[ `cat $ALARM_SWITCH_DIR/latch.$e_UPSTAIRS_WINDOWS` = 1  || $counter = 5 ]];then
            #echo "upstairs windows latched"
	    # latch occurred, check current state of windows
            status_UPSTAIRS_WINDOWS
            if [ "$?" -eq 1 ]; then
              	ALERT `date +%s` "home/floor2/all_rooms/windows" "OPEN"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "Upstairs Windows OPEN" bell-modern B ""
            else
              	ALERT `date +%s` "home/floor2/all_rooms/windows" "CLOSED"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "Upstairs Windows CLOSED" "done" B ""
            fi
            echo
          fi

	  #clear latch
	  echo 0 > $ALARM_SWITCH_DIR/latch.$e_FRONT_DOORS

	else
	  echo "alarm 1wire interface is down..." >> $alarm_log
	fi

	if [ -e /mnt/1wire/28.4BB507050000 ];then
		if [[ $temp_counter = $TEMP_UPDATE_PERIOD ]];then
        		echo "downstairs front room temp: " + `cat /mnt/1wire/28.4BB507050000/temperature`
			temp_F=$(C_to_F `cat /mnt/1wire/28.4BB507050000/temperature`)
			ALERT `date +%s` "home/floor1/frontroom/temperature" $temp_F
		fi
	fi

	if [ -e /mnt/1wire/28.B80208050000 ];then
		if [[ $temp_counter == $TEMP_UPDATE_PERIOD ]];then
	        	echo "upstairs media room temp: " + `cat /mnt/1wire/28.B80208050000/temperature`
			temp_F=$(C_to_F `cat /mnt/1wire/28.B80208050000/temperature`)
			ALERT `date +%s` "home/floor2/mediaroom/temperature"  $temp_F
		fi
	fi

	# loop and poll DS2408 switch for any latched events
        if [ -e $GARAGE_SWITCH_DIR ]; then
          #echo "garage 1wire appears to be up..." at `date`
          #parse latch values into indiv. zones
          if [[ `cat $GARAGE_SWITCH_DIR/latch.$e_A_CLOSED_SENSOR` = 1  || $counter = 5 ]];then
            # latch occurred, check current state of door
            status_A_CLOSED_SENSOR
            if [[ "$?" = 0 && $status_a_garage != "CLOSED" ]]; then
		status_a_garage="CLOSED"
              	ALERT `date +%s` "home/garage/a_garage_door" "CLOSED"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "A's Garage CLOSED" notifier-1 B ""
            fi
          fi
          if [[ `cat $GARAGE_SWITCH_DIR/latch.$e_A_OPEN_SENSOR` = 1  || $counter = 5 ]];then
            # latch occurred, check current state of door
            status_A_OPEN_SENSOR
            if [[ "$?" = 0 && $status_a_garage != "OPEN" ]]; then
                status_a_garage="OPEN"
              	ALERT `date +%s` "home/garage/a_garage_door" "OPEN"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "A's Garage OPEN" up B ""
            fi
          fi

          if [[ `cat $GARAGE_SWITCH_DIR/latch.$e_B_CLOSED_SENSOR` = 1  || $counter = 5 ]];then
            # latch occurred, check current state of door
            status_B_CLOSED_SENSOR
	    if [[ "$?" = 0 && $status_b_garage != "CLOSED" ]]; then
                status_b_garage="CLOSED"
              	ALERT `date +%s` "home/garage/b_garage_door" "CLOSED"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "B's Garage CLOSED" notifier-1 B ""
            fi
          fi
          if [[ `cat $GARAGE_SWITCH_DIR/latch.$e_B_OPEN_SENSOR` = 1  || $counter = 5 ]];then
            # latch occurred, check current state of door
            status_B_OPEN_SENSOR
	    if [[ "$?" = 0 && $status_b_garage != "OPEN" ]]; then
                status_b_garage="OPEN"
              	ALERT `date +%s` "home/garage/b_garage_door" "OPEN"
		/home/pi/boxcar_notifier/boxcar_notifier.sh "B's Garage OPEN" up B ""
            fi
          fi
          if [[ `cat $GARAGE_SWITCH_DIR/latch.$e_A_OPENER_TRIGGER` = 1  || $counter = 5 ]];then
            # latch occurred, check current state of door
            status_A_OPENER_TRIGGER
            if [ "$?" -eq 0 ]; then
              ALERT `date +%s` "home/garage/a_garage_opener" "ON"
            fi
          fi
          if [[ `cat $GARAGE_SWITCH_DIR/latch.$e_B_OPENER_TRIGGER` = 1  || $counter = 5 ]];then
            # latch occurred, check current state of door
            status_B_OPENER_TRIGGER
            if [ "$?" -eq 0 ]; then
              ALERT `date +%s` "home/garage/b_garage_opener" "ON"
            fi
          fi
	  #clear latch
          echo 0 > $GARAGE_SWITCH_DIR/latch.$e_A_OPEN_SENSOR
	fi

#        if [ $counter -lt 5 ];then
#                ((counter++))
#        else
#                counter=1
#        fi
	# use counter to send status when this script starts
	if [ $counter -eq 5 ];then
		counter=0
	fi

	# used so the temperature is only updated once per specified update period
	if [ $temp_counter -lt $TEMP_UPDATE_PERIOD ];then
		((temp_counter++))
	else
		temp_counter=1
	fi

	sleep 1
done

#set -
