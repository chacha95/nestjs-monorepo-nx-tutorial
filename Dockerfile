FROM node:16 as BUILD

# Set the default working directory for the app
# It is a best practice to use the /usr/src/app directory
WORKDIR /usr/src/app

RUN npm update && \
    npm i -g @nestjs/cli

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn
RUN ls -l

COPY ./packages/utils ./packages/utils/
COPY ./apps/core-api/package.json ./apps/core-api/

# Install dependencies.
RUN yarn

# Necessary to run before adding application code to leverage Docker cache
RUN yarn cache clean

COPY ./apps/core-api ./apps/core-api/

# Display directory structure
# RUN ls -l # uncomment for debug

# Build
WORKDIR /usr/src/app/apps/core-api
RUN yarn build


# Multi-Stage Build
FROM node:16-alpine

RUN npm i -g pm2
COPY --from=BUILD /usr/src/app /usr/src/app
WORKDIR /usr/src/app/apps/core-api

ENTRYPOINT [ "sh", "-c", "yarn start:prod;" ]
