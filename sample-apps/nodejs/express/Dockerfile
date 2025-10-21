FROM node:18-slim

WORKDIR /app

# Install curl for traffic generation
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY package.json ./
RUN npm install --production

COPY . .

ENV PORT=3000
ENV SERVICE_NAME=nodejs-express-app

EXPOSE 3000

CMD ["node", "app.js"]
