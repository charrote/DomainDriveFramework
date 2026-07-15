# ============================================================
# DDF App — Vue 3 前端
# Multi-stage: build → nginx
# ============================================================

# ---- Stage 1: Build ----
FROM node:20-alpine AS builder

WORKDIR /app

# 安装依赖
COPY app/package.json app/package-lock.json* ./
RUN npm ci

# 构建
COPY app/ ./
RUN npm run build

# ---- Stage 2: Serve ----
FROM nginx:stable-alpine

# 复制 nginx 配置
COPY deploy/docker/nginx.conf /etc/nginx/conf.d/default.conf

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
