# SMTP data
DEBUG=1
SMTP_SERVERS_NUMBER=2
SMTP_USED=1
SMTP_SEND_COUNT=0
SMTP_MAX_SEND_COUNT=20

SMTP_NAME[1]="default"
SMTP_MAIL_FROM[1]="dd@monkey.de"
SMTP_MAIL_TO[1]="email@deliveryaddress.com"
SMTP_SERVER[1]="smtp.mail.yaoo.com:587"
SMTP_USER[1]="username"
SMTP_PASS[1]="password"
SMTP_ENABLED[1]=1
SMTP_NAME[2]="default2"
SMTP_MAIL_FROM[2]="dd@monkey.de"
SMTP_MAIL_TO[2]="email@deliveryaddress.com"
SMTP_SERVER[2]="smtp.mail.yaoo.com:587"
SMTP_USER[2]="username"
SMTP_PASS[2]="password"
SMTP_ENABLED[2]=1

function fsendemail {
	[ $SMTP_SEND_COUNT -ge $SMTP_MAX_SEND_COUNT ] && echo "$SMTP_SEND_COUNT is greater or equal to $SMTP_MAX_SEND_COUNT" && change_smtp_server
	RESP=`sendemail -f $SMTP_MAIL_FROM -t $SMTP_MAIL_TO -s $SMTP_SERVER -u "$COMP_ID - $1" -m "$2" -a "$3"  -xu "$SMTP_USER" -xp $SMTP_PASS`
	[ $DEBUG -eq 1 ] && echo "DEBUG: sendemail -f $SMTP_MAIL_FROM -t $SMTP_MAIL_TO -s $SMTP_SERVER -u "$COMP_ID - $1" -m "$2" -a "$3"  -xu \"$SMTP_USER\" -xp $SMTP_PASS"
	[ $DEBUG -eq 1 ] && echo "DEBUG: $RESP"
	[[ ! $RESP == *"Email was sent successfully!" ]] && SMTP_SEND_COUNT=$SMTP_MAX_SEND_COUNT
	SMTP_SEND_COUNT=$(($SMTP_SEND_COUNT+1))
	[ $DEBUG -eq 1 ] && echo "DEBUG: SMTP_SEND_COUNT=$SMTP_SEND_COUNT"
}

function change_smtp_server {
	local COUNTER_FOR_CHOOSE_SMTP=0
	while [ $COUNTER_FOR_CHOOSE_SMTP -le 10 ]
	do
		[ $DEBUG -eq 1 ] && echo "DEBUG: shuf SMTP servers"
		[ $DEBUG -eq 1 ] && echo "DEBUG: SERVER_NEMBERS:$SMTP_SERVERS_NUMBER SMTP_USED:$SMTP_USED"
		local SMTP_USED_OLD=$SMTP_USED
		SMTP_USED=$(($SMTP_USED+1))
		[ $SMTP_USED -gt $SMTP_SERVERS_NUMBER ] && SMTP_USED=1 && [ $DEBUG -eq 1 ] && echo "DEBUG: Reseteed SMTP_USED"
		if [[ ${SMTP_ENABLED[$SMTP_USED]} -eq 1 ]]
		then
			SMTP_MAIL_FROM="${SMTP_MAIL_FROM[$SMTP_USED]}"
			SMTP_MAIL_TO="${SMTP_MAIL_TO[$SMTP_USED]}"
			SMTP_SERVER="${SMTP_SERVER[$SMTP_USED]}"
			SMTP_USER="${SMTP_USER[$SMTP_USED]}"
			SMTP_PASS="${SMTP_PASS[$SMTP_USED]}"
			[ $DEBUG -eq 1 ] && echo "DEBUG: shuf: $SMTP_MAIL_TO at $SMTP_USED"
			SMTP_SEND_COUNT=0
			COUNTER_FOR_CHOOSE_SMTP=$(($COUNTER_FOR_CHOOSE_SMTP+10))
		fi
		COUNTER_FOR_CHOOSE_SMTP=$(($COUNTER_FOR_CHOOSE_SMTP+1))
	done
}

