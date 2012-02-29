
source function.sh
DIR="tosendlater"
DATA=`date +"%Y-%m-%d-%H-%M-%S"`
FILE=""
if [ "$(ls -A $DIR)" ]; then
	FILENAME="tmp/package$DATA.zip"
	FILESIZE=`du -s $DIR/ | cut -f 1`
	#FILESIZE=$(stat -c%s "tmp/package$DATA.zip")
	if [ $FILESIZE -le 5000 ]
	then
		zip -1 -r $FILENAME $DIR
		fsendemail "SendLater - $DATA" "Data" "$FILENAME"
		if [[ $RESP == *"Email was sent successfully!" ]]
		then
			rm $FILENAME
			rm $DIR/*
			exit 0 # which means averything is all rught
		else
			rm $FILENAME
			fsendemail "SendLater - $DATA" "Data" "$FILENAME"
			FILESIZE2=`du -s $DIR/ | cut -f 1`
			# exit with "2" signal which means that one big email was not send
			[[ $FILESIZE2 -ge $FILESIZE ]] && exit 2
		fi
	else
		find "$DIR" -type f -exec ./send_later_command.sh {} \;
		FILESIZE2=`du -s $DIR/ | cut -f 1`
		# exit with "1" signal which means that mails with single attachements was not send
		[[ $FILESIZE2 -ge $FILESIZE ]] && exit 1
	fi
fi

