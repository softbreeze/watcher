./kill_soft2.sh "camera.sh" &
./kill_soft2.sh "inf.sh"  &
./kill_soft2.sh "screenshot.sh"  &
./kill_soft2.sh "send_later.sh"  &
./kill_soft2.sh "a_up_dropbox.sh"  &
./kill_soft2.sh "watcher.sh"  &
COUNTER=0
MaxTimes=20
COUNTER2=0
while [  $COUNTER -lt 1 ]; do
	sleep 1
	if [ -z "$(pgrep kill_soft2.sh)" ]
	then
		let COUNTER=COUNTER+1
	fi
	let COUNTER2=COUNTER2+1
	if [ "$COUNTER2" -gt "$MaxTimes" ]
	then
		let COUNTER=COUNTER+1
	fi
done
exit 0
 		
