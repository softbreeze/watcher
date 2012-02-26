source function.sh
DATA=`date +"%Y-%m-%d-%H-%M-%S"`
fsendemail "SendLaterCommand - $DATA" "Data" "$1"
if [[ $RESP == *"Email was sent successfully!" ]]
then
	rm "$1"
fi



