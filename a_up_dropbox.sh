# This script is supposed to copy files to dropbox directorySTRING=""
#STRING2=""
#STRING+=`ps -o pid= -C "$PROGRAM" | while read psLine; do echo -ne "$psLine "; done`
#STRING2=`echo ${STRING/$$/""}`

# 1 DB_DIR
# 2 SRC_DIR
# 3 DB_DIR_MAX_SIZE
# 4 DB_DIR_WARNING_SIZE


cp -u $2/* $1/
CLEAN_DIR_WHILE=0
DIRSIZE=`du -s $1/ | cut -f 1`
while [ $CLEAN_DIR_WHILE -lt 1 ]; do
	if [ $DIRSIZE -ge $3 ]
	then
		file=`/bin/ls -1 "$1" | sort --random-sort | head -1 | while read psLine; do [ ! -f "$2/$psLine" ] && echo "$psLine"; done`
		path=`readlink --canonicalize "$1/$file"` # Converts to full path
		[ -f $path ] && rm "$path"
	else
		CLEAN_DIR_WHILE=$(($CLEAN_DIR_WHILE+1))
	fi
	DIRSIZE=`du -s $1/ | cut -f 1`
done
exit 0

