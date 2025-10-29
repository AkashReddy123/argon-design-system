# ---------- Stage 1: builder ----------
FROM node:18-alpine AS builder
WORKDIR /app

# copy package manifest for caching (if exists)
COPY package*.json . 2>/dev/null || true
RUN if [ -f package.json ]; then npm ci --silent; fi

# copy project files
COPY . .

# If gulp or an npm build exists, try to produce a build; don't fail if not present
RUN if [ -f package.json ] && jq -e '.scripts.build' package.json >/dev/null 2>&1; then \
      npm run build || true; \
    elif [ -f gulpfile.js ]; then \
      npx gulp || true; \
    fi

# put build output in /output; prefer dist/ or build/, otherwise copy everything
RUN mkdir -p /output && \
    if [ -d ./dist ]; then cp -a ./dist/. /output/ ; \
    elif [ -d ./build ]; then cp -a ./build/. /output/ ; \
    else cp -a . /output/ ; fi

# ---------- Stage 2: runtime ----------
FROM nginx:stable-alpine
LABEL maintainer="balaakashreddyy"

# remove default nginx content and copy built static files
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /output/ /usr/share/nginx/html/

# keep a small health-check location (optional)
COPY --chown=0:0 ./nginx-default.conf /etc/nginx/conf.d/default.conf 2>/dev/null || true

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
