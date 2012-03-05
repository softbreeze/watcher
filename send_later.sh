# 1 - MAX_ATACHEMENT_SIZE

if [ -n "${1+x}" ]; then
	MAX_ATACHEMENT_SIZE=$1
else
	MAX_ATACHEMENT_SIZE=5000
fi

source function.sh
DIR="tosendlater"
DATA=`date +"%Y-%m-%d-%H-%M-%S"`
FILE=""
if [ "$(ls -A $DIR)" ]; then
	FILENAME="tmp/package$DATA.zip"
	FILESIZE=`du -s $DIR/ | cut -f 1`
	#FILESIZE=$(stat -c%s "tmp/package$DATA.zip")
	if [ $FILESIZE -le $MAX_ATACHEMENT_SIZE ]
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
			FILESIZE2=`du -s $DIR/ | cut -f 1`
			# exit with "2" signal which means that one big email was not send
			[[ $FILESIZE2 -ge $FILESIZE ]] && exit 2
		fi
	else
		find "$DIR" -type f -exec ./send_later_command.sh $MAX_ATACHEMENT_SIZE {} \;
		FILESIZE2=`du -s $DIR/ | cut -f 1`
		# exit with "1" signal which means that mails with single attachements was not send
		[[ $FILESIZE2 -ge $FILESIZE ]] && exit 1
	fi
fi

