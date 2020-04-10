#!/bin/bash

usage(){
        cat << EOF
Usage: rgw-policy-test.sh
    [-b] Bucket Name
    [-c] s3cmd config file
    [-o] Object Name
    [-h] Print this message
EOF
    exit 0
}

line() { # takes a number as first input Length, and any character as second input, defaults to "-" if no option
        if [ -z $2 ]; then
                printf -v line '%*s' "$1"
                echo ${line// /-}
        else
                printf -v line '%*s' "$1"
                echo ${line// /$2}
        fi
}


BUCKET=bucket1
OBJECT=osd1.txt
CRED=".s3cfg"

while getopts 'b:c:o:h' OPTION; do
        case ${OPTION} in
    b)
        BUCKET=${OPTARG}
        ;;
    c)
        CRED=${OPTARG}
        ;;
    o)
        OBJECT=${OPTARG}
        ;;
    h)
        usage
        ;;
    esac
done

if [ ! -d /root/$BUCKET ];then
    mkdir /root/$BUCKET
fi
cd /root/$BUCKET

line 20 -
echo "LIST buckets"
line 20 -
s3cmd ls -c /root/$CRED
line 20 -
echo "LIST objects in $BUCKET"
line 20 -
s3cmd ls s3://$BUCKET -c /root/$CRED
line 20 -
echo "GET $OBJECT from $BUCKET"
line 20 -
s3cmd get s3://$BUCKET/$OBJECT $OBJECT -c /root/$CRED
line 20 -
echo "DELETE $OBJECT from $BUCKET"
line 20 -
s3cmd rm s3://$BUCKET/$OBJECT -c /root/$CRED
line 20 -
echo "PUT $OBJECT in $BUCKET"
line 20 -
s3cmd put $OBJECT s3://$BUCKET/$OBJECT -c /root/$CRED
line 20 -
echo END
line 20 -

rm -f $OBJECT

cd /root/
