docker build --tag iot-kafka-generator .
docker tag iot-kafka-generator torsstei/iot-kafka-generator
docker push torsstei/iot-kafka-generator
