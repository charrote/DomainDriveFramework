# ============================================================
# DDF — 顶级开发命令
# ============================================================

.PHONY: help dev-server dev-app dev-engine build-server build-app \
        generate db-push db-seed docker-up docker-down \
        lint test clean

help: ## 显示帮助
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# === 开发 ===

dev-server: ## 启动后端开发服务器
	cd server && npm run dev

dev-app: ## 启动前端开发服务器
	cd app && npm run dev

dev-engine: ## 验证引擎
	cd engine && node poc.js

# === 构建 ===

build-server: ## 构建后端
	cd server && npm ci && npx prisma generate

build-app: ## 构建前端
	cd app && npm ci && npm run build

generate: ## 生成代码（DSL → 全量文件）
	cd engine && node generator/index.js --out ../generated

# === 数据库 ===

db-push: generate ## 合并 Schema + 推送数据库
	cd server && node ../server/scripts/combine-prisma.js && npx prisma db push

db-seed: ## 填充初始数据
	cd server && node src/seed.js

# === Docker（生产部署 — PostgreSQL） ===

docker-up: ## Docker Compose 启动（PostgreSQL 生产模式）
	cd deploy && docker compose up -d

docker-down: ## Docker Compose 停止
	cd deploy && docker compose down

docker-build: ## Docker Compose 构建
	cd deploy && docker compose build

docker-logs: ## 查看 Docker 日志
	cd deploy && docker compose logs -f

docker-status: ## 查看 Docker 服务状态
	cd deploy && docker compose ps

docker-restart: ## 重启 Docker 服务
	cd deploy && docker compose restart

docker-clean: ## 清理所有 Docker 容器 + 数据卷
	cd deploy && docker compose down -v

docker-pg-shell: ## 进入 PostgreSQL 交互终端
	cd deploy && docker compose exec postgres psql -U ddf -d ddf

docker-reset: docker-down docker-clean docker-up ## 完全重置（清数据后重启）

# === 工具 ===

lint: ## 代码检查
	cd app && npx vue-cli-service lint --fix 2>/dev/null || true

clean: ## 清理构建产物
	rm -rf app/dist server/prisma/dev.db generated-test server/prisma/dev.db
	cd server && npx prisma generate 2>/dev/null || true
