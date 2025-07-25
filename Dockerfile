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

ARG DJANGO_ALLOWED_HOST='localhost'
ARG CSRF_TRUSTED_ORIGIN='http://localhost'
ARG DJANGO_SUPERUSER_USERNAME='admin'
ARG DJANGO_SUPERUSER_EMAIL='xxx@xxx.xxx'
ARG DJANGO_SUPERUSER_PASSWORD='admin'

COPY requirements.txt manage.py /
COPY tp_config /tp_config
COPY tp_core /tp_core

RUN mkdir /static
RUN chmod 777 /static

# "https://some.site.domain/"
ENV DJANGO_ALLOWED_HOST=${DJANGO_ALLOWED_HOST}
ENV DJANGO_SUPERUSER_USERNAME=${DJANGO_SUPERUSER_USERNAME}
ENV DJANGO_SUPERUSER_EMAIL=${DJANGO_SUPERUSER_EMAIL}
ENV DJANGO_SUPERUSER_PASSWORD=${DJANGO_SUPERUSER_PASSWORD}

RUN echo ${DJANGO_ALLOWED_HOST}

RUN python3 -m venv /venv
RUN /venv/bin/python3 -m pip install --upgrade pip
RUN /venv/bin/pip3 install -r requirements.txt
RUN /venv/bin/python3 manage.py collectstatic --noinput
RUN /venv/bin/python3 manage.py migrate
RUN /venv/bin/python3 manage.py createsuperuser --username $DJANGO_SUPERUSER_USERNAME --email $DJANGO_SUPERUSER_EMAIL --noinput

############

ARG TZ='Europe/Moscow'
ENV TZ=${TZ}
RUN date

USER root

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]