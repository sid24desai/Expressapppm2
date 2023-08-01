# Dockerfile
FROM node:16.17-bullseye-slim as base
LABEL name=client-base
WORKDIR /home/site/wwwroot
COPY package*.json ./
RUN npm install -g npm@9.8.1 \
    && npm config set fetch-retries 5 \
    && npm config set fetch-retry-factor 2 \
    && npm config set fetch-retry-mintimeout 10000 \
    && npm config set fetch-retry-maxtimeout 60000 \
    && npm config set fund false \
    && npm ci --production \
    && npm cache clean --force
COPY . .
EXPOSE 8080

# Development stage
FROM base as development
LABEL name=client-development
RUN npm i && npm cache clean --force
CMD ["npm", "run", "dev"]

# Production stage
FROM base as production
LABEL name=client-production
COPY --from=base /home/site/wwwroot/server.sh /usr/local/bin/server.sh
RUN chmod +x /usr/local/bin/server.sh
