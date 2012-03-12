while true
do
	DATA=`date +"%Y-%m-%d-%H-%M-%S"`
	mkdir "screenshot/$DATA"

	# screenshot:
	import -window root screenshot/$DATA/screenshot.bmp
	convert -quality 75 screenshot/$DATA/screenshot.bmp screenshot/$DATA/screenshot.jpg
#	convert -type grayscale -quality 60 screenshot/$DATA/screenshot.bmp screenshot/$DATA/screenshot.png
	rm screenshot/$DATA/screenshot.bmp
	zip -r tosend/screenshot-$DATA.zip -P 42p6b2V3hy7c92g42p6b2V3hy7c92g screenshot/$DATA
	mv tosend/screenshot-$DATA.zip tosendlater/screenshot-$DATA.zip
	rm screenshot/$DATA/*
	rmdir "screenshot/$DATA"
	sleep $1
done
