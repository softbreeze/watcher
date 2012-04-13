source function.sh

if [ ! -n "${1+x}" ]; then
	exit 1
fi
if [ ! -n "${2+x}" ]; then
	exit 1
fi

FILESIZE=$(\stat -c%s "$2")
if [ $FILESIZE -le $MAX_ATACHEMENT_SIZE ]
then
	DATA=`\date +"%Y-%m-%d-%H-%M-%S"`
	fsendemail "SendLaterCommand - $DATA" "Data" "$2"
	if [[ $RESP == *"Email was sent successfully!" ]]
	then
		\rm "$2"
		exit 0
	fi
else
	echo "Split file and than send"
	echo "Remove original file only if all send succesfull."
	\rm "$2"
fi
exit 1


