FROM node:18-slim

WORKDIR /app

COPY package.json ./
RUN npm install --production

COPY . .

ENV PORT=3000
ENV SERVICE_NAME=nodejs-express-app

EXPOSE 3000

CMD ["node", "app.js"]
