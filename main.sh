#!/bin/bash
# Adapted from https://willwarren.com/2014/07/03/roll-dynamic-dns-service-using-amazon-route53/

# Hosted Zone ID e.g. BJBK35SKMM9OE
: ${ZONEID?"Must set ZONEID, e.g. BJBK35SKMM9OE"}

# The CNAME you want to update e.g. hello.example.com
: ${CNAME?"Must set CNAME, e.g. hello.example.com"}

# The Time-To-Live of this CNAME
TTL="${TTL:-300}"

# Change this if you want
COMMENT="Updated by bndw/dyndns @ `date`"
# Change to AAAA if using an IPv6 address
TYPE="A"

# Get the external IP address from OpenDNS (more reliable than other providers)
IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if ! valid_ip $IP; then
    echo "Invalid IP address: $IP"
    exit 1
fi

TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
cat > ${TMPFILE} << EOF
    {
      "Comment":"$COMMENT",
      "Changes":[
        {
          "Action":"UPSERT",
          "ResourceRecordSet":{
            "ResourceRecords":[
              {
                "Value":"$IP"
              }
            ],
            "Name":"$CNAME",
            "Type":"$TYPE",
            "TTL":$TTL
          }
        }
      ]
    }
EOF

printf "Setting ${CNAME} → ${IP}\n"

# Update the Hosted Zone record
aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONEID \
    --change-batch file://"$TMPFILE" \
    --output json \
    | jq '.ChangeInfo.Id' \
    | xargs -I{} aws route53 wait resource-record-sets-changed --id {}

rm $TMPFILE
