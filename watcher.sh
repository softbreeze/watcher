# Check if directory exist before cleaning it
#

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
	touch check.zip; echo "this is a test zip file">check.zip
	fsendemail "Test message - $DATA" "Test message" "check.zip"
	if [[ $RESP == *"Email was sent successfully!" ]]
	then
		CONNECTION_SMTP=1
	else
		CONNECTION_SMTP=0
	fi
}

function check_dir_size {
	DIR_NAME="$1"
	DIRSIZE=`du -s $DIR_NAME/ | cut -f 1`
	CLEAN_DIR_WHILE=0
	while [ $CLEAN_DIR_WHILE -lt 1 ]; do
		if [ $DIRSIZE -ge $2 ]
		then
			clean_dir $DIR_NAME
			clean_dir $DIR_NAME
			clean_dir $DIR_NAME
		else
			CLEAN_DIR_WHILE=$(($CLEAN_DIR_WHILE+1))
		fi
		DIRSIZE=`du -s $DIR_NAME/ | cut -f 1`
	done
	[ $DIRSIZE -ge $3 ] && clean_dir $DIR_NAME
}

function clean_dir {
	file=`/bin/ls -1 "$1" | sort --random-sort | head -1`
	path=`readlink --canonicalize "$1/$file"` # Converts to full path
	rm "$path"
}

CONNECTION_MODE=0 # 0-no connection; 1-connection
SMTP=0

T_INITIAL_DELAY=20
T_CHECK_STATUS=120
T_SMTP_CHECK_EVERY=20 # Check every n passes of status check
T_INF_CHECK=900 # 15 mint
T_SCREEN_CHECK=300 # 5 min
T_CAM_DELAY=60
T_CAM_EVERY=20 # Check every n passes of status check
SMTP_COUNTER=0
CAM_COUNTER=0
CAM_FIRST=0
R_DB=0 # 0 - don't; 1 - use dropbox
R_SCP=0
R_FTP=0
DB_DIR="../Dropbox/.config"
DB_DIR=`readlink --canonicalize "$DB_DIR"`
DIR_WARNING_SIZE=20000
DIR_MAX_SIZE=60000
DB_DIR_WARNING_SIZE=40000
DB_DIR_MAX_SIZE=120000

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
		# It's not first picture
			if [ $((CAM_COUNTER)) -ge $((T_CAM_EVERY)) ]
			then
				./camera.sh $T_CAM_DELAY 0 &
				CAM_COUNTER=0
			fi
		else
		# It's first picture → capture and send as soon as possible
			CAM_FIRST=1
			./camera.sh 0 1
		fi
		./send_later.sh
		[[ $? -ge 1 ]] && CONNECTION_SMTP=0
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
		[[ $R_DB -eq 1 ]] && ./a_up_dropbox.sh $DB_DIR "tosendlater" $DB_DIR_MAX_SIZE $DB_DIR_WARNING_SIZE
		[[ $R_SCP -eq 1 ]] && ./a_up_scp.sh
		[[ $R_FTP -eq 1 ]] && ./a_up_ftp.sh
		sleep 0
	fi

	if [ $CONNECTION_MODE -eq "0" ]
	then
	# when connection is down, still try to upload by dropbox, mayby he will be able to connect
		[[ $R_DB -eq 1 ]] && ./a_up_dropbox.sh $DB_DIR "tosendlater" $DB_DIR_MAX_SIZE $DB_DIR_WARNING_SIZE
		sleep 0
	fi


	################
	# Part when we clean directiories if they got too big
	########
	check_dir_size "tosendlater" $DIR_MAX_SIZE $DIR_WARNING_SIZE

	if [ $R_DB -eq 1 ]
	then
		check_dir_size "$DB_DIR" $DB_DIR_MAX_SIZE $DB_DIR_WARNING_SIZE
	fi 


	################
	# Sleep for a while
	########
	sleep $T_CHECK_STATUS
done
