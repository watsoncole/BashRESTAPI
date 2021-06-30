#!/bin/bash

# ncat command on one terminal
# on other terminal enter curl command
#write down all the errors here
#status is number of rows total
#input data
read input
#check if it is 'GET' 'POST' 'DELETE'
command="$(echo $input | awk '{print $1}')"
#check the label ie messages or status
label="$(echo $input | awk -F '/' '{print $2}')"
#check the name if its alphabetical or numeric
name="$(echo $input | awk '{print $2}'| awk -F '/' '{print $3}')"
#check for the http thing
http="$(echo $input | awk -F' ' '{print $3}')"
#id -u get the name of the account if it is alphabetical and return the ID associated with it
ifStatus="$(echo $input | awk -F' ' '{print $2}')"
#if (echo $name | grep -E ^[a-zA-Z]+$)
echo " s" #without this nothing prints I have no idea why
checknameAlpha="$(echo "$name" | grep -E ^[a-zA-Z]+$)"
checknameNumeric="$(echo "$name" | grep -E ^[0-9]+$)"
if [[ "$checknameAlpha" != '' && "$ifStatus" != "/status" ]]
then
     #process alphabetical username
    tag="$(grep $name /etc/passwd | awk -F':' '{print$3}')"
    if [ "$tag" = '' ];
    then
	echo "HTTP/1.1 404"
	exit 404
    fi
elif [[ "$checknameNumeric" != '' && "$ifStatus" != "/status" ]]
then
    #handles numeric name
    checkexist="$(grep $name /etc/passwd)"
    if [ "$checkexist" == '' ]
    then
	echo "HTTP/1.1 404 Not Found"
	exit 404
    fi 
elif [ "$ifStatus" != "/status" ]
then
    echo "HTTP/1.1 404"
    exit 404
fi

#search through messages.dat for stuff
lines="$(cat messages.dat | grep -E ^$tag | sort -t',' -k 3 | head -n 1)"
message="$(echo $lines | awk -F',' '{print $4}')"
date="$(echo $lines | awk -F',' '{print $3}')"
ndate="$(date -d @$date)"
status="$(grep -c . messages.dat)"
if [ "$lines" = "" ]
then
    echo "HTTP/1.1 200 OK"
    echo "Content-Type: application/json"
    echo " "
    echo '"{}"'
    exit 404
elif [[ "$command" = "GET" && "$label" = "messages" ]];
then
    echo "HTTP/1.1 200 OK"
    echo "Content-Type: application/json"
    echo " "
    echo -n '{"sender": "'$name'", '
    echo -n '"message": "'$message'" '
    echo '"timestamp": "'$ndate'"}'
elif [ "$ifStatus" == "/status" ]
then
    #gets the status
    echo "HTTP/1.1 200 OK"
    echo "Content-Type: application/json"
    echo " "
    echo -n '{"record_count": "'
    echo -n $status
    echo '"}'
else
    echo "HTTP/1.1 400 Bad Request"
    exit 400
fi
