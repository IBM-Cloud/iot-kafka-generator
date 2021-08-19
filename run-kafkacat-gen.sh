if [ -z "$KAFKA_BROKERS_SASL" ]; then echo "Error: environment variable KAFKA_BROKERS_SASL is not set." && exit 1; fi
if [ -z "$PASSWORD" ]; then echo "Error: environment variable PASSWORD is not set." && exit 1; fi
if [ -z "$TOPIC_NAME" ]; then echo "Error: environment variable TOPIC_NAME is not set." && exit 1; fi

timestamp=`date +"%Y-%m-%d %H:%M:%S"`
awk -v timestamp="$timestamp" '{sub("CURRENT TIMESTAMP", timestamp)}1' sample-payload-iotmessages.json > payload.temp

echo Sending IOT Messages with message_timestamp=\"$timestamp\" to topic \"$TOPIC_NAME\"
kafkacat -b $KAFKA_BROKERS_SASL -P -X sasl.mechanism=PLAIN -X security.protocol=SASL_SSL -X sasl.username=token -X sasl.password=$PASSWORD -t $TOPIC_NAME -l payload.temp

