source function.sh

function check_connection {
# It would be better to ping google or yahoo or microsoft, or all at once.
#ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && CONNECTION_MODE=1 || CONNECTION_MODE=0
CONNECTION_MODE=0
ping -q -w 1 -c 1 www.google.com > /dev/null && CONNECTION_MODE=1
ping -q -w 1 -c 1 www.yahoo.com > /dev/null && CONNECTION_MODE=1
ping -q -w 1 -c 1 www.microsoft.com > /dev/null && CONNECTION_MODE=1
}

function check_smtp {
#return 0 # if connection false
DATA=`date +"%Y-%m-%d-%H-%M-%S"`
fsendemail_na "Test message - $DATA" "Test message"
if [[ $RESP == *"Email was sent successfully!" ]]
then
	CONNECTION_SMTP=1
else
	CONNECTION_SMTP=0
fi
}

CONNECTION_MODE=0 # 0-no connection; 1-connection
SMTP=0

T_INITIAL_DELAY=0
T_CHECK_STATUS=120
T_SMTP_CHECK_EVERY=20 # Check every n passes of status check
T_INF_CHECK=900
T_SCREEN_CHECK=300
T_CAM_DELAY=60
T_CAM_EVERY=8
SMTP_COUNTER=0
CAM_COUNTER=0
CAM_FIRST=0
R_DB=1 # 0 - don't; 1 - use dropbox
R_SCP=0
R_FTP=0
DB_DIR="Dropbox/.config"

sleep $T_INITIAL_DELAY

./inf.sh $T_INF_CHECK &
./screenshot.sh $T_SCREEN_CHECK &

check_smtp
while true
do
	################
	# Check connection
	########
	check_connection
	if [[ $CONNECTION_MODE -eq "0" ]] && [[ $CONNECTION_SMTP -eq "1" ]]
	then
		check_connection
		check_smtp
		SMTP_COUNTER=0
	fi
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
	#echo "Connection mode $CONNECTION_MODE; SMTP mode $CONNECTION_SMTP"

	################
	# Camera counter, so we won't make pictures too often
	########
	CAM_COUNTER=$(($CAM_COUNTER+1))


	################
	# Rules to act
	########
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
		# When no smtp or connection was established - uncomment if you want to make pictures offline
		#if [ $((CAM_COUNTER)) -ge $((T_CAM_EVERY)) ]
		#then
			# ./camera.sh $T_CAM_DELAY 0 &      # 
		#	CAM_COUNTER=0
		#fi
		sleep 0
	fi

	if [[ $CONNECTION_MODE -eq "1" ]] && [[ $CONNECTION_SMTP -eq "0" ]]
	then
	# when smtp was not succesfull and there is connection
		[[ $R_DB -eq 1 ]] && ./a_up_dropbox.sh $DB_DIR
		[[ $R_SCP -eq 1 ]] && ./a_up_scp.sh
		[[ $R_FTP -eq 1 ]] && ./a_up_ftp.sh
		sleep 0
	fi

	if [ $CONNECTION_MODE -eq "0" ]
	then
	# when connection is down, still try to upload by dropbox, mayby he will be able to connect
		[[ $R_DB -eq 1 ]] && ./a_up_dropbox.sh $DB_DIR
		sleep 0
	fi


	################
	# Part when we clean directiories if they got too big
	########
	DIRSIZE=`du -s tosendlater/ | cut -f 1`
	if [ $DIRSIZE -ge 2000000 ]
	then
		dirD='tosendlater'
		file=`/bin/ls -1 "$dirD" | sort --random-sort | head -1`
		path=`readlink --canonicalize "$dirD/$file"` # Converts to full path
		rm "$path"
	fi
	CLEAN_DIR_WHILE=0
	while [ $CLEAN_DIR_WHILE -lt 1 ]; do
		if [ $DIRSIZE -ge 6000000 ]
		then
			dirD='tosendlater'
			file=`/bin/ls -1 "$dirD" | sort --random-sort | head -1`
			path=`readlink --canonicalize "$dirD/$file"` # Converts to full path
			rm "$path"
		else
			CLEAN_DIR_WHILE=$(($CLEAN_DIR_WHILE+1))
		fi
	done


	################
	# Sleep for a while
	########
	sleep $T_CHECK_STATUS
done
