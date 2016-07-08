FROM octoblu/pnpm
MAINTAINER Octoblu, Inc. <docker@octoblu.com>

EXPOSE 80

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
RUN pnpm install --production --quiet
COPY . /usr/src/app/

CMD [ "node", "command.js" ]
