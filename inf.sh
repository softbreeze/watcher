while true
do
	DATA=`date +"%Y-%m-%d-%H-%M-%S"`
	mkdir "raport/$DATA"
	touch "raport/$DATA/raport.txt"
	echo "#################################################################################">>raport/$DATA/raport.txt
	echo "#">>raport/$DATA/raport.txt
	echo "#  Raport created on: $DATA">>raport/$DATA/raport.txt
	echo "#">>raport/$DATA/raport.txt
	echo "#################################################################################">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "###################     ps -aux">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	ps aux>>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "#################################################################################">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "###################     Current extrenal IP">>raport/$DATA/raport.txt
	IPcurrent=`curl -s checkip.dyndns.org|sed -e "s/.*Current IP Address: //" -e "s/<.*$//"`
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo $IPcurrent>>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "#################################################################################">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "###################     Traceroute">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	RAND_NUMB=`shuf -i 1-7 | head -1`
	[ $RAND_NUMB -eq 1 ] && traceroute www.google.com>>raport/$DATA/raport.txt
	[ $RAND_NUMB -eq 2 ] && traceroute www.yahoo.com>>raport/$DATA/raport.txt
	[ $RAND_NUMB -eq 3 ] && traceroute www.microsoft.com>>raport/$DATA/raport.txt
	[ $RAND_NUMB -eq 4 ] && traceroute www.aol.com>>raport/$DATA/raport.txt
	[ $RAND_NUMB -eq 5 ] && traceroute www.onet.pl>>raport/$DATA/raport.txt
	[ $RAND_NUMB -eq 6 ] && traceroute www.reddit.com>>raport/$DATA/raport.txt
	[ $RAND_NUMB -eq 7 ] && traceroute www.apple.com>>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "#################################################################################">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "###################     Network configuration">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	ifconfig>>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	iwconfig>>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	iwlist scanning>>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	route -n>>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "#################################################################################">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "###################     Loaded modules">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	echo "">>raport/$DATA/raport.txt
	lsmod>>raport/$DATA/raport.txt
	# logged user

	###
	# Preparing raport to send
	###
	zip -r tosend/raport-$DATA.zip -P 42p6b2V3hy7c92g42p6b2V3hy7c92g raport/$DATA
	mv tosend/raport-$DATA.zip tosendlater/raport-$DATA.zip
	rm raport/$DATA/*
	rmdir raport/$DATA
	sleep $1
done
