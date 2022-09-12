FROM gitlab/gitlab-runner:alpine-v15.3.0

RUN apk update && \
    apk add --no-cache openrc docker docker-compose && \
    rc-update add docker boot \
