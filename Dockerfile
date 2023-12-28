FROM node:18-alpine AS base
ENV APP_HOME=/app
RUN mkdir "$APP_HOME"
RUN apk add --no-cache g++ make py3-pip libc6-compat
WORKDIR "$APP_HOME"
COPY package-lock.json "$APP_HOME"
EXPOSE 3000

FROM base AS builder
WORKDIR "$APP_HOME"
ENV NODE_ENV=production
COPY package-production.json "$APP_HOME"/package.json
RUN npm ci
COPY . "$APP_HOME"
COPY package.json "$APP_HOME"
RUN npm run build
RUN npm prune --production

FROM base AS production
WORKDIR "$APP_HOME"

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs


COPY --from=builder --chown=nextjs:nodejs "$APP_HOME"/.next ./.next
COPY --from=builder "$APP_HOME"/node_modules ./node_modules
COPY --from=builder "$APP_HOME"/package.json ./package.json
COPY --from=builder "$APP_HOME"/public ./public

CMD npm start

FROM base AS dev
COPY package.json "$APP_HOME"
ENV NODE_ENV=development
RUN npm install
COPY . "$APP_HOME"
CMD npm run dev
