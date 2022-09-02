FROM gitlab/gitlab-runner:alpine

RUN apk update && \
    apk add --no-cache openrc docker docker-compose && \
    rc-update add docker boot \
