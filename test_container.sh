#!/usr/bin/env bash

if [ $# -ne 2 ]; then
   echo 'Usage: test_container.sh "<Event Streams Instance Name>"|<Event Streams Instance CRN> <Topic Name>'
   exit 1
fi

ibmcloud target -g default &> /dev/null
if [ $? -ne 0 ]; then
	echo You need to be logged on to IBM Cloud with the ibmcloud CLI tool.
	echo Run \"ibmcloud login --sso\" first.
	exit 1
fi

set -e

echo Getting credentials for Event Streams instance \"$1\"...
if [ -z "${1##*$crn:v1:bluemix:public:messagehub*}" ]; then
	event_streams_credentials_id=`ibmcloud resource service-keys --output JSON --instance-id $1 | jq '.[0].id'`
else
	event_streams_credentials_id=`ibmcloud resource service-keys --output JSON --instance-name "$1" | jq '.[0].id'`
fi
event_streams_credentials_id=`echo $event_streams_credentials_id | sed -e 's/^"//' -e 's/"$//'`
echo Found credentials with ID $event_streams_credentials_id

event_streams_kafka_brokers=`ibmcloud resource service-key --output JSON $event_streams_credentials_id | jq '.[0].credentials.kafka_brokers_sasl | join (",")' | sed -e 's/^"//' -e 's/"$//'`
event_streams_password=`ibmcloud resource service-key --output JSON $event_streams_credentials_id | jq '.[0].credentials.password' | sed -e 's/^"//' -e 's/"$//'`
echo Extracted kafka_brokers_sasl=$event_streams_kafka_brokers
echo Extracted password=$event_streams_password

event_streams_topic=$2
echo Using provided topic \"$event_streams_topic\"


docker run -e KAFKA_BROKERS_SASL=$event_streams_kafka_brokers -e TOPIC_NAME=$event_streams_topic -e PASSWORD=$event_streams_password torsstei/iot-kafka-generator

