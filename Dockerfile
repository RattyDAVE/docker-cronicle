FROM node:26-alpine AS builder
RUN apk add curl yarn patch unzip
WORKDIR /opt/cronicle

RUN curl -L -o /tmp/Cronicle-master.zip https://codeload.github.com/jhuckaby/Cronicle/zip/refs/heads/master
RUN unzip /tmp/Cronicle-master.zip -d /tmp
RUN mv /tmp/Cronicle-master/* .

RUN rm -rf /tmp/*
RUN yarn

COPY docker/docker-entrypoint.js ./bin/

#FROM node:18-alpine
FROM node:26-alpine

RUN apk add procps curl bash docker
COPY --from=builder /opt/cronicle/ /opt/cronicle/
WORKDIR /opt/cronicle

#ENV CRONICLE_base_app_url='http://cronicle:3012'
#ENV CRONICLE_WebServer__http_port=3012
#ENV CRONICLE_WebServer__https_port=443

ENV CRONICLE_foreground=1
ENV CRONICLE_echo=1
ENV CRONICLE_color=1
ENV debug_level=1
ENV HOSTNAME=main

RUN node bin/build.js dist && bin/control.sh setup

VOLUME /opt/cronicle/data
VOLUME /opt/cronicle/logs
VOLUME /opt/cronicle/plugins
VOLUME /root/.docker

CMD ["node", "bin/docker-entrypoint.js"]
