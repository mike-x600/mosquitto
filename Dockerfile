FROM alpine:3.22

RUN apk --no-cache add supervisor mosquitto nginx python3

WORKDIR /

############
# sipervisor

ADD supervisord.conf /etc/
RUN mkdir -p /var/log/supervisor

############
# nginx 

COPY nginx.conf /nginx.conf
RUN mkdir /html
RUN touch /html/example.txt

# expose http:// and ws:// via nginx
EXPOSE 80

############
# mosquitto 

# Expose mqtt://
# EXPOSE 1883

# Expose ws://
# EXPOSE 8080

RUN mkdir -p /mosquitto/log/ /mosquitto/data/
RUN touch /mosquitto/log/mosquitto.log
RUN chmod 777 /mosquitto/log/ /mosquitto/log/mosquitto.log /mosquitto/data/
COPY mosquitto.conf /mosquitto.conf

# Add config
ADD mosquitto.conf /mosquitto.conf

ENV PATH /usr/sbin:$PATH

USER root

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]