FROM node:15.5.0-alpine

WORKDIR /app

RUN apk update  && \
    npm install -g \
	@vue/cli \
	firebase \
	firebase-tools && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/ash"]
