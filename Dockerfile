FROM node:12-alpine 
RUN mkdir -p /usr/app
WORKDIR /usr/app

COPY ./ ./


FROM base as build-front

RUN npm install
RUN npm run build

RUN cp -r ./dist ./server/public
RUN cd server
RUN npm install

ENV PORT=8083
EXPOSE 8083

ENTRYPOINT [ "node", "server" ]
