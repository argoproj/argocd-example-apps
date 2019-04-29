FROM node:11.14.0-alpine

RUN npm install lerna

ENTRYPOINT ["node","server.js"]