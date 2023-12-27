FROM node:18-alpine AS base
ENV APP_HOME=/app
RUN mkdir "$APP_HOME"
RUN apk add --no-cache g++ make py3-pip libc6-compat
WORKDIR "$APP_HOME"
COPY package*.json "$APP_HOME"
EXPOSE 3000

FROM base AS builder
WORKDIR "$APP_HOME"
COPY . "$APP_HOME"
RUN npm run build

FROM base AS production
WORKDIR "$APP_HOME"

ENV NODE_ENV=production
RUN npm ci

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs


COPY --from=builder --chown=nextjs:nodejs "$APP_HOME"/.next ./.next
COPY --from=builder "$APP_HOME"/node_modules ./node_modules
COPY --from=builder "$APP_HOME"/package.json ./package.json
COPY --from=builder "$APP_HOME"/public ./public

CMD npm start

FROM base AS dev
ENV NODE_ENV=development
RUN npm install
COPY . "$APP_HOME"
CMD npm run dev
