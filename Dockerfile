# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry. Adapted from the fleet's static stack pack.
#
# Two stages: node builds the static bundle (scripts/build.mjs -> dist/), then an
# unprivileged nginx serves it on $PORT, read from the environment AT RUNTIME
# (the nginx image's entrypoint renders /etc/nginx/templates/*.template with
# envsubst before it starts, substituting only variables that are set).
#
# Deviations from the pack, and why:
#   - the server config is a file in the repo (nginx/default.conf.template), COPYed
#     into /etc/nginx/templates (COPY creates the directory the image lacks).
#   - no SPA fallback: a plain multi-page static site, so a missing file is a real 404.

FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime
ARG BUILD_ID=""
ENV PORT=8080 BUILD_ID=$BUILD_ID
COPY --from=build /app/dist /usr/share/nginx/html
# nginx server config (incl. the per-request JSON access log): nginx/default.conf.template.
# The image's entrypoint renders /etc/nginx/templates/*.template into conf.d at start.
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
EXPOSE 8080
