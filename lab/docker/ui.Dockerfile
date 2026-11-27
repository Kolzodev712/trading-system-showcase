# syntax=docker/dockerfile:1
# Additional context `ui` is the private trading-system-ui repository.
FROM node:22-bookworm-slim AS build
WORKDIR /src
COPY --from=ui /package.json /package-lock.json ./
RUN npm ci
COPY --from=ui /index.html /vite.config.ts /tsconfig.json /tsconfig.app.json /tsconfig.node.json /tsconfig.server.json /tailwind.config.js /postcss.config.js ./
COPY --from=ui /src ./src
COPY --from=ui /server ./server
COPY --from=ui /public ./public
ENV VITE_GRPC_WEB_URL=/grpc
RUN npx tsc -b --pretty false && npx vite build && npx tsc -p tsconfig.server.json

FROM node:22-bookworm-slim AS auth
WORKDIR /app
COPY --from=ui /package.json /package-lock.json ./
RUN npm ci --omit=dev
COPY --from=build /src/dist-server ./dist-server
ENV AUTH_PORT=3001
EXPOSE 3001
HEALTHCHECK --interval=5s --timeout=3s --start-period=10s --retries=12 \
  CMD node -e "fetch('http://127.0.0.1:3001/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "dist-server/index.js"]

FROM nginx:1.27-bookworm AS web
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/dist /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=12 \
  CMD ["nginx", "-t"]
