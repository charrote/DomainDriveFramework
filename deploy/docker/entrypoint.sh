#!/bin/sh
# ============================================================
# DDF Server — 入口脚本
# ============================================================

set -e

echo "[Entrypoint] Initializing database..."
su-exec ddf npx prisma db push --skip-generate --accept-data-loss 2>&1 || true

echo "[Entrypoint] Seeding data..."
su-exec ddf node /app/src/seed.js 2>&1 || true

echo "[Entrypoint] Starting server..."
exec su-exec ddf "$@"
