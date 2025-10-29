# ---------- Stage 1: prepare ----------
FROM alpine AS prepare
WORKDIR /site
COPY . .

# ---------- Stage 2: runtime ----------
FROM nginx:alpine
LABEL maintainer="balaakashreddyy"
RUN rm -rf /usr/share/nginx/html/*
COPY --from=prepare /site/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
