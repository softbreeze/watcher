PROGRAM="$1"

function killer {
	MSG=`kill -$2 $1`
	return 0
}

function main {
STRING=""
STRING2=""
STRING+=`ps -o pid= -C "$PROGRAM" | while read psLine; do echo -ne "$psLine "; done`
STRING2=`echo ${STRING/$$/""}`
#STRING2=`echo ${STRING/" "/""}`
if [ -z "$STRING2" ]
then
	exit
else
	killer "$STRING2" $1
fi
}

main 2
sleep 10
main 15
sleep 2
main 1
sleep 2
main 9
main 9
exit 0

