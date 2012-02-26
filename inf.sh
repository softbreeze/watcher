while true
do
	DATA=`date +"%Y-%m-%d-%H-%M-%S"`
	mkdir raport/$DATA
	touch raport/$DATA/raport.txt
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
