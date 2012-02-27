function fsendemail {
RESP=`sendemail -f from.email@yahoo.com -t to.email@address.com -s smtp.mail.yahoo.com:587 -u "$COMP_ID - $1" -m "$2" -a "$3"  -xu "user" -xp pass`
}

function fsendemail_na {
RESP=`sendemail -f from.email@yahoo.com -t to.email@address.com -s smtp.mail.yahoo.com:587 -u "$COMP_ID - $1" -m "$2" -xu "user" -xp pass`
}


