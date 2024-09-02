#FROM node:20-alpine3.18 AS base
#Corrige vulnerabilidad
FROM node:20-alpine3.20 AS base


WORKDIR /app

RUN apk add curl bash --no-cache
RUN curl -sf https://gobinaries.com/tj/node-prune | sh

#----------------BUILD-----------------
FROM base AS builder
COPY ./src ./src
COPY package*.json ./

RUN npm install
#Limpia y deja solo lo que se ocupa
RUN npm prune --production && node-prune

#----------------RELEASE-----------------
#Corrige vulnerabilidad
FROM node:20-alpine3.20 AS release
#FROM node:20-alpine3.18 AS release
RUN apk add dumb-init
#Ejecutarse como usuario node si no tiene esta sentencia
#se esta ejecutando como root
USER node

#Dar permiso a carpetas para que el usuario nodepueda acceder
COPY --chown=node:node --from=builder /app/ ./


ARG APP_ENV
ENV APP_ENV=${APP_ENV}

EXPOSE 3000

CMD ["dumb-init", "node", "src/main.js"]
