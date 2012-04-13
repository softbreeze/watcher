# This script is supposed to copy files to dropbox directorySTRING=""

# 1 DB_DIR
# 2 SRC_DIR
# 3 DB_DIR_MAX_SIZE
# 4 DIR_MAX_SIZE

[ ! -d "$1" ] && exit 1

\cp -u $2/* $1/

if [ $3 -ge $4 ]
then
	CLEAN_DIR_WHILE=0
	DIRSIZE=`\du -s $1/ | \cut -f 1`
	while [ $CLEAN_DIR_WHILE -lt 3 ]; do
		if [ $DIRSIZE -ge $3 ]
		then
			/bin/ls -1 "$1" | \sort --random-sort | \head -10 | while \read psLine; do [ ! -f "$2/$psLine" ] && [ -f "$1/$psLine" ] && rm "test/$psLine"; done
		else
			CLEAN_DIR_WHILE=$(($CLEAN_DIR_WHILE+3))
		fi
		CLEAN_DIR_WHILE=$(($CLEAN_DIR_WHILE+1))
		DIRSIZE=`\du -s $1/ | \cut -f 1`
	done
fi
exit 0

