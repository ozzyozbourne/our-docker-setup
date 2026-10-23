# The app: SvelteKit server (and, from M1, the Rivet actors), built with pnpm.
FROM node:26.12.1-trixie-slim AS build
RUN npm install -g pnpm@12.15.0
WORKDIR /repo
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY apps/web/package.json apps/web/
COPY packages/db/package.json packages/db/
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build
RUN pnpm --filter web deploy --prod --legacy /out && cp -r apps/web/build /out/build

FROM node:26.12.1-trixie-slim
ENV NODE_ENV=production PORT=3000
WORKDIR /app
COPY --from=build /out .
USER node
EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=3s --start-period=20s CMD node -e "fetch('http://127.0.0.1:3000/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "build"]
