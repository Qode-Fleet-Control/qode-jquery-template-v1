# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry. Adapted from the fleet's static stack pack.
#
# Two stages: node builds the static bundle (scripts/build.mjs -> dist/), then an
# unprivileged nginx serves it on $PORT, read from the environment AT RUNTIME
# (the nginx image's entrypoint renders /etc/nginx/templates/*.template with
# envsubst before it starts, substituting only variables that are set).
#
# Deviations from the pack, and why:
#   - /etc/nginx/templates does NOT exist in nginx-unprivileged:1.27-alpine and
#     uid 101 cannot create it, so the template is written as root, then USER 101.
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
USER root
RUN mkdir -p /etc/nginx/templates && printf 'server {\n  listen ${PORT};\n  root /usr/share/nginx/html;\n  location / { try_files $uri $uri/ =404; }\n}\n' \
    > /etc/nginx/templates/default.conf.template
USER 101
EXPOSE 8080
