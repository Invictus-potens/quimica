FROM node:22-alpine

WORKDIR /app

COPY package.json server.js ./
COPY cliente ./cliente
COPY gestora ./gestora
COPY login.html ./

EXPOSE 12159

CMD ["npm", "start"]
