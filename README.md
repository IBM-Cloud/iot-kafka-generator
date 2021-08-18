# iot-kafka-generator

This repository builds a docker image that when run generates a set of IOT message in JSON format and submits them to a Kafka topic in IBM Cloud Event Streams service. In addition the repository includes a setup procedure to deploy this docker container into IBM Cloud Code engine and schedules it to be executed automatically every two minutes.

## IOT Message generator

The script `run-kafkacat-gen.sh` is the actual generator of the IOT messages. It takes a sample message template file (`sample-payload-iotmessages.json`) updates it with the current timestamp as a the message times and then uses `kafkacat` in order to send the json messages to Kafka. The entire generator setup is assembled into a docker image.

## Build the image

Run `build.sh` to build the image. You may need to edit the script and inject your own docker hub account name if you want the image to be pushed there.

## Test the image

Run `test_container.sh` to test the image locally running against one of your IBM Cloud Event Streams instances for Kafka. 

You need to be logged on to IBM Cloud with the ibmcloud CLI tool in order to run the test script because it retrieves the required credentials from your Event Streams instance.

The script expects as first parameter the name (or alternatively the unique CRN instance ID) of your event streams instance. The second parameter is the topic name in your Event Streams instance that you want to send the messages to.

## Deploy the container for scheduled execution in IBM Cloud

Run `setup_job.sh` to create a project in IBM Cloud Code engine (named `iot-kafka-generator`).

The script further sets up a job in there with the docker image in `torsstei/iot-kafka-generator` (edit the script if you want to take your own image build from your own docker hub account).

Finally the script sets up a cron schedule that submits the job every two minutes.

You need to be logged on to IBM Cloud with the ibmcloud CLI tool in order to run the test script because it retrieves the required credentials from your Event Streams instance.

The script expects as first parameter the name (or alternatively the unique CRN instance ID) of your event streams instance. The second parameter is the topic name in your Event Streams instance that you want to send the messages to.
