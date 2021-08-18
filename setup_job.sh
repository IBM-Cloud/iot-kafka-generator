#!/usr/bin/env bash

if [ $# -ne 2 ]; then
   echo 'Usage: setup_job.sh "<Event Streams Instance Name>"|<Event Streams Instance CRN> <Topic Name>'
   exit 1
fi

ibmcloud target -g default
if [ $? -ne 0 ]; then
	echo You need to be logged on to IBM Cloud with the ibmcloud CLI tool.
	echo Run \"ibmcloud login --sso\" first.
	exit 1
else
	echo Setting up IOT Kafka message sample infrastructure in above IBM Cloud account, region and resource group...
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

echo Creating code engine project (this may take one or two minutes)...
set +e; ibmcloud ce project delete --name iot-kafka-generator --force &> /dev/null; set -e
ibmcloud ce project create --name iot-kafka-generator 

echo Creating code engine job with docker image torsstei/iot-kafka-generator...
ibmcloud ce job create --name iot-kafka-generator-job  --image docker.io/torsstei/iot-kafka-generator:latest \
 -e KAFKA_BROKERS_SASL=$event_streams_kafka_brokers \
 -e TOPIC_NAME=$event_streams_topic \
 -e PASSWORD=$event_streams_password

echo Creating cron based event trigger for code engine job every 2 minutes...
ibmcloud ce subscription cron create -n iot-kafka-generator-job-trigger -d iot-kafka-generator-job --destination-type job  -s '*/2 * * * *'

echo Done!

