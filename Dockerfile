FROM alpine:3.22

RUN apk --no-cache add supervisor mosquitto nginx python3 sqlite

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

RUN mkdir -p /mosquitto/log/ /mosquitto/data/
RUN touch /mosquitto/log/mosquitto.log
RUN chmod 777 /mosquitto/log/ /mosquitto/log/mosquitto.log /mosquitto/data/
COPY mosquitto.conf /mosquitto.conf

############
# django

COPY requirements.txt manage.py /
COPY tp_config /tp_config
COPY tp_core /tp_core

RUN mkdir /static
RUN chmod 777 /static


ENV DJANGO_SUPERUSER_PASSWORD=admin

RUN python3 -m venv venv && \
    python3 manage.py collectstatic --noinput && \
    python3 manage.py migrate && \
    python3 manage.py createsuperuser --username admin --email xxx@xxx.xxx --noinput

############

ENV PATH=/usr/sbin:$PATH

USER root

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]