# DDF 部署指南 — v1.0

> 适用：DomainDriveFramework（DDF）开发部署与生产交付
> 更新：2026-07-15 v1.0

---

## 目录

- [一、系统概览](#一条%E7%BB%9F%E6%A6%82%E8%A7%88)
- [二、本地开发部署（SQLite）](#二%E6%9C%AC%E5%9C%B0%E5%BC%80%E5%8F%91%E9%83%A8%E7%BD%B2sqlite)
- [三、Docker 生产部署（PostgreSQL）](#三docker-%E7%94%9F%E4%BA%A7%E9%83%A8%E7%BD%B2postgresql)
- [四、部署架构](#四%E9%83%A8%E7%BD%B2%E6%9E%B6%E6%9E%84)
- [五、环境变量参考](#五%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F%E5%8F%82%E8%80%83)
- [六、运维操作](#六%E8%BF%90%E7%BB%B4%E6%93%8D%E4%BD%9C)
- [七、安全加固](#七%E5%AE%89%E5%85%A8%E5%8A%A0%E5%9B%BA)
- [八、故障排查](#八%E6%95%85%E9%9A%9C%E6%8E%92%E6%9F%A5)
- [九、升级与迁移](#九%E5%8D%87%E7%BA%A7%E4%B8%8E%E8%BF%81%E7%A7%BB)

---

## 一、系统概览

### 1.1 技术栈

| 层 | 技术 | 端口 |
|:---|:-----|:----:|
| **前端** | Vue 3 + Vite + Pinia + Vue Router | 5173（开发）/ 80（Docker） |
| **后端** | Node.js + Express + Prisma ORM | 3000 |
| **数据库** | SQLite（开发）/ PostgreSQL 16（生产） | — / 5432 |
| **反向代理** | Nginx（仅 Docker 模式） | 80 |
| **认证** | JWT（jsonwebtoken + bcryptjs） | — |

### 1.2 部署模式对比

| 维度 | 本地开发 | Docker 生产 |
|:----|:---------|:------------|
| **目标用户** | 开发者 | 运维/客户 |
| **数据库** | SQLite（零配置） | PostgreSQL 16（持久卷） |
| **启动方式** | 分两个终端 `npm run dev` | `docker compose up -d` |
| **热重载** | 支持（Vite + Node --watch） | 不支持（需重新构建） |
| **依赖** | Node.js 20+ | Docker 24+ |
| **适用阶段** | 编码、调试、测试 | 正式使用、客户演示、SaaS |

---

## 二、本地开发部署（SQLite）

### 2.1 前置条件

```bash
# 检查 Node.js 版本
node --version    # 需 >= 20.x

# 检查 npm 版本
npm --version     # 需 >= 10.x
```

### 2.2 快速启动

使用 Makefile 一键操作（分两个终端）：

```bash
# ── 终端 1：后端 API ──
make dev-server

# ── 终端 2：前端 SPA ──
make dev-app
```

### 2.3 分步启动（首次需初始化）

#### 步骤 1：后端初始化 + 启动

```bash
cd server

# 安装依赖（仅首次）
npm ci

# 生成 Prisma Client
npx prisma generate

# 创建数据库表
npx prisma db push

# 填充测试数据
node src/seed.js

# 启动开发服务器（热重载）
npm run dev
```

预期输出：

```
[DDF] 数据库已初始化 ✨
[Server] DDF MES API 已启动 → http://localhost:3000
[Server] 健康检查 → http://localhost:3000/api/health
```

#### 步骤 2：前端启动

```bash
cd app

# 安装依赖（仅首次）
npm ci

# 启动 Vite 开发服务器
npm run dev
```

预期输出：

```
VITE v6.x  ready in xxx ms
  ➜  Local:   http://localhost:5173/
  ➜  Network: http://xxx.xxx.x.x:5173/
```

> 前端开发服务器已配置代理：`/api/*` 请求自动转发到 `localhost:3000`。

### 2.4 验证部署

```bash
# 1. 健康检查
curl http://localhost:3000/api/health

# 2. 登录测试
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# 3. 浏览器打开
open http://localhost:5173
```

### 2.5 开发常用命令

```bash
make dev-server          # 启动后端
make dev-app             # 启动前端
make dev-engine          # 运行引擎 POC 验证
make db-push             # 合并 Schema + 推送数据库
make db-seed             # 重新填充种子数据
make generate            # DSL → 全量代码生成
make build-server        # 构建后端
make build-app           # 构建前端
make clean               # 清理构建产物
```

---

## 三、Docker 生产部署（PostgreSQL）

### 3.1 前置条件

```bash
# 检查 Docker 版本
docker --version         # 需 >= 24.x
docker compose version   # 需 >= 2.20.x
```

### 3.2 首次部署

```bash
# 克隆代码
git clone git@github.com:charrote/DomainDriveFramework.git
cd DomainDriveFramework

# 构建镜像（首次约 2-3 分钟）
make docker-build

# 启动所有服务
make docker-up

# 查看启动日志
make docker-logs
```

### 3.3 启动流程（自动完成）

```
Step 1: PostgreSQL 容器启动
        └── 健康检查 pg_isready
Step 2: Server 容器启动
        ├── 等待 PostgreSQL 就绪（最多 30 秒）
        ├── 自动切换 Prisma provider 为 postgresql
        ├── prisma db push 创建表结构
        ├── node seed.js 填充种子数据
        └── Express API 启动 → 健康检查通过
Step 3: App 容器启动
        ├── 等待 API 健康检查通过
        └── Nginx 对外服务
```

### 3.4 访问地址

| 服务 | 地址 |
|:----|:-----|
| **前端界面** | `http://<服务器IP>` （80 端口） |
| **后端 API** | `http://<服务器IP>:3000` |
| **健康检查** | `http://<服务器IP>:3000/api/health` |
| **PostgreSQL** | `localhost:5432`（用户 `ddf`，密码 `ddf_secret`） |

### 3.5 登录测试

| 用户名 | 密码 | 角色 | 权限范围 |
|:------|:----:|:----|:---------|
| **admin** | **admin123** | 系统管理员 | 所有实体全权限 |
| **supervisor** | **123456** | 班组长 | 人员/设备/物料/工艺/工单/条码 |
| **operator** | **123456** | 操作员 | 设备/工位/工单/生产记录/条码/容器 |
| **inspector** | **123456** | 质检员 | 物料/品质/缺陷/检验 |

### 3.6 Docker 管理命令

```bash
# ── 服务生命周期 ──
make docker-up          # 启动
make docker-down        # 停止
make docker-restart     # 重启
make docker-status      # 查看状态

# ── 日志 ──
make docker-logs        # 查看全部日志
docker compose logs server   # 仅看后端
docker compose logs app      # 仅看前端
docker compose logs postgres # 仅看数据库

# ── 数据库 ──
make docker-pg-shell    # 进入 PostgreSQL CLI
docker compose exec postgres pg_dump -U ddf ddf > backup.sql  # 备份

# ── 构建 ──
make docker-build       # 构建/重新构建镜像

# ── 重置 ──
make docker-clean       # 停止并删除数据卷（⚠️ 数据全丢）
make docker-reset       # 清数据后完全重启
```

---

## 四、部署架构

### 4.1 架构图

```
┌──────────────────────────────────────────────────────┐
│                     docker-compose                    │
│                                                       │
│  ┌─────────────────┐     ┌────────────────────────┐  │
│  │   PostgreSQL 16  │     │   Server (Node.js)      │  │
│  │   alpine         │◄────│   Express + Prisma      │  │
│  │   :5432          │     │   :3000                 │  │
│  │   volume:pgdata  │     │   JWT 认证              │  │
│  └─────────────────┘     └───────────┬────────────┘  │
│                                       │                │
│                              proxy_pass /api/*         │
│                                       │                │
│                          ┌────────────▼───────────┐   │
│                          │   App (Nginx)            │   │
│                          │   Vue 3 SPA              │   │
│                          │   :80                    │   │
│                          │   gzip + 缓存 + 安全头    │   │
│                          └─────────────────────────┘   │
└──────────────────────────────────────────────────────┘
```

### 4.2 依赖关系

```
postgres (健康)
    │
    ▼
server (健康, depends_on: postgres:healthy)
    │
    ▼
app (depends_on: server:healthy)
```

### 4.3 数据持久化

| 数据 | 存储方式 | 备份命令 |
|:-----|:---------|:---------|
| PostgreSQL 数据 | Docker 命名卷 `pgdata` | `docker compose exec postgres pg_dump -U ddf ddf > backup.sql` |
| 应用日志 | Docker 默认 json-file | 建议配置 logrotate 或切换至 syslog |

---

## 五、环境变量参考

### 5.1 全部变量一览

| 变量 | 默认值 | 说明 | 必需 |
|:-----|:-------|:-----|:----:|
| `PORT` | `3000` | 后端 API 监听端口 | 否 |
| `DATABASE_URL` | `postgresql://ddf:ddf_secret@postgres:5432/ddf` | 数据库连接串 | **是** |
| `JWT_SECRET` | `change-me-in-production` | JWT 签名密钥 | **是**（生产必须改） |
| `JWT_EXPIRES_IN` | `7d` | Token 过期时间 | 否 |
| `NODE_ENV` | `production` | 运行环境 | 否 |
| `PG_USER` | `ddf` | PostgreSQL 用户名 | 否 |
| `PG_PASSWORD` | `ddf_secret` | PostgreSQL 密码 | **是**（生产必须改） |
| `PG_DATABASE` | `ddf` | PostgreSQL 数据库名 | 否 |

### 5.2 配置方式

**Docker 部署**：创建 `deploy/.env` 文件：

```bash
# deploy/.env
JWT_SECRET=$(openssl rand -hex 32)
PG_PASSWORD=$(openssl rand -hex 16)
```

**本地开发**：修改 `server/.env`：

```bash
# server/.env
DATABASE_URL="file:./dev.db"
JWT_SECRET="ddf-mes-dev-secret"
JWT_EXPIRES_IN="7d"
PORT=3000
```

---

## 六、运维操作

### 6.1 数据库备份与恢复

```bash
# ── 备份 ──
docker compose exec postgres pg_dump -U ddf ddf > ddf-backup-$(date +%Y%m%d).sql

# ── 恢复 ──
cat ddf-backup.sql | docker compose exec -T postgres psql -U ddf ddf

# ── 自动定时备份（crontab） ──
0 2 * * * cd /data/ddf && docker compose exec -T postgres pg_dump -U ddf ddf \
  > /data/backups/ddf-$(date +\%Y\%m\%d).sql && find /data/backups -name "*.sql" -mtime +30 -delete
```

### 6.2 查看日志

```bash
# 全部服务日志（实时）
make docker-logs

# 仅看后端（最近 100 行）
docker compose logs --tail=100 server

# 跟踪特定服务
docker compose logs -f server

# 导出日志到文件
docker compose logs server > server-logs-$(date +%Y%m%d).txt
```

### 6.3 监控健康

```bash
# 手动检测
curl http://localhost:3000/api/health

# 持续监控（每 10 秒）
watch -n 10 curl -sf http://localhost:3000/api/health
```

### 6.4 扩容与性能

```bash
# 查看资源占用
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# 限制容器资源（在 docker-compose.yml 中）
# server:
#   deploy:
#     resources:
#       limits:
#         cpus: '2'
#         memory: 1G
```

---

## 七、安全加固

### 7.1 生产环境必改项

| 项目 | 建议值 | 风险 |
|:-----|:-------|:-----|
| `JWT_SECRET` | `openssl rand -hex 32`（64 位随机） | **高** — 泄露可伪造任意用户 |
| `PG_PASSWORD` | `openssl rand -hex 16`（32 位随机） | **高** — 泄露可直连数据库 |
| PostgreSQL 端口 | 内网绑定，不暴露 5432 | **中** — 避免数据库被扫 |

### 7.2 HTTPS 配置

建议使用反向代理（Caddy / Nginx）做 TLS 终止：

```nginx
# 示例：Nginx HTTPS 配置
server {
    listen 443 ssl;
    server_name ddf.yourcompany.com;

    ssl_certificate     /etc/ssl/certs/ddf.crt;
    ssl_certificate_key /etc/ssl/private/ddf.key;

    location / {
        proxy_pass http://localhost:80;
    }
}

server {
    listen 80;
    server_name ddf.yourcompany.com;
    return 301 https://$host$request_uri;
}
```

或使用 Caddy 自动申请 Let's Encrypt：

```caddyfile
ddf.yourcompany.com {
    reverse_proxy localhost:80
}
```

### 7.3 安全头（已内置）

Nginx 配置已包含以下安全头：

```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
```

---

## 八、故障排查

### 8.1 常见问题

| 症状 | 原因 | 解决 |
|:-----|:-----|:-----|
| **Docker 启动后前端白屏** | API 未就绪，Nginx 等待超时 | `make docker-logs app` 检查 |
| **API 返回 500** | 数据库连接失败 | `make docker-logs server` 查看 Prisma 错误 |
| **Login 返回 401** | 密码错误 / 用户不存在 | 重新执行 `make db-seed` |
| **端口被占用** | 3000/80/5432 已被其他进程使用 | `lsof -i :3000` 查找并停用冲突进程 |
| **Docker 构建失败** | npm 网络问题 / 依赖缓存过期 | `docker compose build --no-cache` 重新构建 |
| **Prisma 连接错误** | DATABASE_URL 格式不正确 | 检查连接串是否以 `postgresql://` 开头 |
| **数据丢失** | `docker compose down -v` 清除了数据卷 | 恢复备份（见 6.1 节） |

### 8.2 诊断命令

```bash
# 检查所有容器状态
docker compose ps

# 检查容器资源
docker stats

# 进入容器内部排查
docker compose exec server sh
docker compose exec postgres psql -U ddf -d ddf

# 检查网络连通性
docker compose exec server wget -qO- http://postgres:5432
docker compose exec server wget -qO- http://localhost:3000/api/health

# 查看 Prisma Studio（开发用）
cd server && npx prisma studio
```

### 8.3 日志关键字搜索

```bash
# 查找错误
docker compose logs server | grep -i error

# 查找数据库连接问题
docker compose logs server | grep -i "prisma\|database\|connect"

# 查找启动阶段
docker compose logs server | grep "\[Entrypoint\]"
```

---

## 九、升级与迁移

### 9.1 升级代码

```bash
# 拉取最新代码
git pull origin main

# 重新构建并启动
make docker-build
make docker-up

# 数据库 migration（如有 Schema 变更）
docker compose exec server npx prisma db push --accept-data-loss
```

### 9.2 SQLite → PostgreSQL 迁移

如果本地开发使用 SQLite 积累了大量数据，需要迁移到 PostgreSQL：

```bash
# 1. 从 SQLite 导出数据（需安装 sqlite3）
sqlite3 server/prisma/dev.db ".dump" > sqlite-dump.sql

# 2. 启动 PostgreSQL
make docker-up

# 3. 使用 Prisma 内置迁移
docker compose exec server npx prisma db push

# 4. 导入数据（需转换 SQL 语法）
# 注：SQLite 和 PostgreSQL SQL 语法有差异，建议通过应用层重新 seed
docker compose exec server node /app/src/seed.js
```

### 9.3 服务器迁移

```bash
# 1. 旧服务器备份
docker compose exec postgres pg_dump -U ddf ddf > ddf-backup.sql

# 2. 新服务器部署
git clone git@github.com:charrote/DomainDriveFramework.git
cd DomainDriveFramework
make docker-build
make docker-up

# 3. 恢复数据
cat ddf-backup.sql | docker compose exec -T postgres psql -U ddf ddf
```

---

## 附录

### A. 目录结构参考

```
DomainDriveFramework/
├── app/                    # 前端 Vue 3 SPA
│   ├── src/
│   │   ├── api/            # 33 个 API 服务模块
│   │   ├── views/          # 66 个页面组件
│   │   ├── router/         # 路由 + 权限守卫
│   │   ├── stores/         # Pinia 状态管理
│   │   └── components/     # 通用 Ddf 组件
│   └── vite.config.js      # 端口 5173 + /api 代理
│
├── server/                 # 后端 Express API
│   ├── src/
│   │   ├── routes/         # 35 个 API 路由
│   │   ├── middleware/     # JWT 认证中间件
│   │   └── prisma/        # Prisma 客户端
│   ├── prisma/
│   │   └── schema.prisma  # 数据库 Schema（723 行）
│   └── .env               # 开发环境变量
│
├── deploy/                 # 部署配置
│   ├── docker-compose.yml  # 服务编排
│   ├── docker/             # Dockerfile + Nginx + 入口脚本
│   ├── scripts/            # 部署管理脚本
│   └── .github/workflows/  # CI/CD 流水线
│
├── domain/                 # 领域模型 DSL
│   ├── base/core/          # 24 个实体 YAML
│   ├── base/workflows/     # 3 个工作流
│   └── base/permissions/   # RBAC 权限
│
├── engine/                 # 代码生成引擎
├── generated/              # 生成的代码产物
├── docs/                   # 项目文档
├── Makefile                # 顶级开发命令
└── .dockerignore           # Docker 构建排除
```

### B. 端口速查表

| 端口 | 服务 | 环境 |
|:----:|:-----|:-----|
| 5173 | Vite 前端开发服务器 | 开发 |
| 3000 | Express API | 开发 + Docker |
| 80 | Nginx（Vue SPA） | Docker |
| 5432 | PostgreSQL | Docker |
| 8080 | Adminer（可选，已注释） | Docker |

### C. 账号速查表

| 用户名 | 密码 | 角色 | 说明 |
|:------|:----:|:-----|:-----|
| admin | admin123 | 系统管理员 | 后端 seed 数据 |
| supervisor | 123456 | 班组长 | 后端 seed 数据 |
| operator | 123456 | 操作员 | 后端 seed 数据 |
| inspector | 123456 | 质检员 | 后端 seed 数据 |
| *任意角色* | 123456 | — | 前端 Mock 模式（无后端时） |

---

*文档版本：v1.0 | 更新日期：2026-07-15*
