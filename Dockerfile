FROM ubuntu

# Install basics
RUN apt-get -y update \
&& apt-get -y upgrade \
&& apt-get -y install build-essential python libssl-dev openssl \
&& apt-get install -y git \
&& apt-get -y install curl \
&& apt-get -y install libcurl3-dev \
&& apt-get -y install librdkafka-dev \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata \
&& apt-get -y install pkg-config \
&& apt-get -y install libjansson-dev \
&& apt-get -y install cmake \
&& git clone https://github.com/edenhill/kafkacat.git \
&& cd kafkacat \
&& ./bootstrap.sh

# Copy scripts and payload
RUN ln -s /kafkacat/kafkacat /usr/local/sbin/kafkacat
COPY sample-payload-iotmessages.json /
COPY run-kafkacat-gen.sh /

CMD ["/bin/bash", "-c", "/run-kafkacat-gen.sh"]
