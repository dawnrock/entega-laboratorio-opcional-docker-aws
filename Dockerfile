FROM node:12-alpine
RUN mkdir -p /usr/app
WORKDIR /usr/app

COPY ./ ./

RUN npm install
RUN npm run build

RUN cd server
RUN npm install

ENV PORT=8083
EXPOSE 8083

ENTRYPOINT [ "node", "server" ]
