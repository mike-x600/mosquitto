FROM alpine:3.22

RUN apk --no-cache add mosquitto

WORKDIR /

COPY mosquitto.conf /mosquitto.conf

# Expose mqtt://
EXPOSE 1883

# Expose ws://
EXPOSE 8080

RUN mkdir -p /mosquitto/{log,data}/
RUN chmod 777 /mosquitto/{log,data}/
VOLUME ["/mosquitto/data", "/mosquitto/log"]

# Add config
ADD mosquitto.conf /mosquitto.conf

ENV PATH /usr/sbin:$PATH

USER root

CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto.conf", "--verbose"]