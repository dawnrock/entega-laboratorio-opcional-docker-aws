FROM node:12-alpine AS base
RUN mkdir -p /usr/app
WORKDIR /usr/app

FROM base AS build-front
COPY ./ ./
RUN npm install
RUN npm run build

FROM base AS release
COPY --from=build-front /usr/app/dist ./public
COPY ./server/package.json ./
COPY ./server/index.js ./
RUN npm install --only=production


ENV STATIC_FILES_PATH=./public
ENV PORT=8083
EXPOSE 8083

ENTRYPOINT [ "node", "index" ]
