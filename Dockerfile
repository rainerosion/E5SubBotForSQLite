FROM golang:alpine AS builder

WORKDIR /root

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk update && apk add git gcc g++\
    && git clone https://github.com/rainerosion/E5SubBot.git \
    && cd E5SubBot &&  GOPROXY=https://goproxy.cn,direct CGO_ENABLED=1 go build

FROM alpine:latest

ENV TIME_ZONE=Asia/Shanghai

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk update && apk add tzdata \
    && ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone

WORKDIR /root

COPY --from=builder /root/E5SubBot/main /root

CMD [ "/root/main" ]