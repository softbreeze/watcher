
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
		else
			rm $FILENAME
			find "$DIR" -type f -exec ./send_later_command.sh {} \;
		fi
	else
		find "$DIR" -type f -exec ./send_later_command.sh {} \;
	fi
fi

