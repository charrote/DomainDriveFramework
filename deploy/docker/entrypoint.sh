#!/bin/sh
# ============================================================
# DDF Server — 入口脚本
# 支持 PostgreSQL（生产）和 SQLite（开发）双模式
# 自动检测 DATABASE_URL，切换 Prisma provider
# ============================================================

set -e

# ---- 检测数据库类型 ----
if echo "$DATABASE_URL" | grep -q "^postgresql"; then
  DB_TYPE="postgresql"
  echo "[Entrypoint] 检测到 PostgreSQL 数据库"

  # 从 DATABASE_URL 解析连接参数
  PG_HOST=$(echo "$DATABASE_URL" | sed -E 's|^postgresql://[^:]+:[^@]+@([^:/]+).*$|\1|')
  PG_PORT=$(echo "$DATABASE_URL" | sed -E 's|^postgresql://[^:]+:[^@]+@[^:]+:([0-9]+)/.*$|\1|')
  PG_USER=$(echo "$DATABASE_URL" | sed -E 's|^postgresql://([^:]+):.*$|\1|')
  PG_DB=$(echo "$DATABASE_URL" | sed -E 's|^postgresql://[^:]+:[^@]+@[^/]+/([^?]+).*$|\1|')
  PG_HOST="${PG_HOST:-postgres}"
  PG_PORT="${PG_PORT:-5432}"

  echo "[Entrypoint]   Host: $PG_HOST:$PG_PORT"
  echo "[Entrypoint]   User: $PG_USER"
  echo "[Entrypoint]   DB:   $PG_DB"

  # 等待 PostgreSQL 就绪
  echo "[Entrypoint] 等待 PostgreSQL 就绪..."
  for i in $(seq 1 30); do
    if pg_isready -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DB" >/dev/null 2>&1; then
      echo "[Entrypoint] PostgreSQL 已就绪（第 ${i}s）"
      break
    fi
    if [ "$i" -eq 30 ]; then
      echo "[Entrypoint] ⚠️  PostgreSQL 未能就绪，继续尝试初始化..."
    fi
    sleep 1
  done

  # 切换 Prisma provider 为 postgresql
  SCHEMA_FILE="/app/prisma/schema.prisma"
  if [ -f "$SCHEMA_FILE" ]; then
    sed -i 's/provider = "sqlite"/provider = "postgresql"/' "$SCHEMA_FILE"
    echo "[Entrypoint] Prisma provider 已切换为 postgresql"
  fi

else
  DB_TYPE="sqlite"
  echo "[Entrypoint] 检测到 SQLite 数据库"
  DB_DIR=$(dirname "$(echo "$DATABASE_URL" | sed 's|^file:||')")
  if [ "$DB_DIR" != "." ] && [ "$DB_DIR" != "" ]; then
    mkdir -p "$DB_DIR" 2>/dev/null || true
  fi
fi

# ---- 初始化数据库 Schema ----
echo "[Entrypoint] 初始化数据库 Schema..."
su-exec ddf npx prisma db push --skip-generate --accept-data-loss 2>&1 || {
  echo "[Entrypoint] ⚠️  Schema 初始化出现警告（非致命）"
}

# ---- 填充初始数据 ----
echo "[Entrypoint] 填充初始数据..."
su-exec ddf node /app/src/seed.js 2>&1 || {
  echo "[Entrypoint] ⚠️  数据填充出现警告（非致命）"
}

# ---- 启动服务 ----
echo "[Entrypoint] 启动 DDF Server (${DB_TYPE})..."
exec su-exec ddf "$@"
