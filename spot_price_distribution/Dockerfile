FROM alpine:3.18

RUN apk add --no-cache python3 py3-pip curl mosquitto-clients jq
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
