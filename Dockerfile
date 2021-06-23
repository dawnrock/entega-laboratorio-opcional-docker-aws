FROM node:12-alpine
RUN mkdir -p /usr/app
WORKDIR /usr/app

COPY ./ ./


RUN npm install
RUN npm run build


