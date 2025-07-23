FROM alpine:3.22

RUN apk --no-cache add mosquitto

WORKDIR /

COPY mosquitto.conf /mosquitto.conf

# Expose mqtt://
EXPOSE 1883

# Expose ws://
EXPOSE 8080

RUN mkdir -p /mosquitto/log/ /mosquitto/data/
RUN touch /mosquitto/log/mosquitto.log
RUN chmod 777 /mosquitto/log/ /mosquitto/log/mosquitto.log /mosquitto/data/ 

# Add config
ADD mosquitto.conf /mosquitto.conf

ENV PATH /usr/sbin:$PATH

USER root

CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto.conf", "--verbose"]