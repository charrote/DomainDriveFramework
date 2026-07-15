#!/bin/bash
# ============================================================
# DDF 部署初始化脚本
# 用法: sudo bash setup.sh
# ============================================================

set -euo pipefail

echo "========================================"
echo "  DDF — 部署初始化"
echo "========================================"

# --- 检查依赖 ---
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "❌ 缺少 $1，请先安装"
        exit 1
    fi
    echo "  ✅ $1 $(command -v $1)"
}

echo ""
echo "[1/4] 检查依赖..."
check_command docker
check_command docker compose

# --- 创建目录 ---
echo ""
echo "[2/4] 创建数据目录..."
mkdir -p /data/ddf
echo "  ✅ /data/ddf"

# --- 配置环境变量 ---
echo ""
echo "[3/4] 配置环境变量..."
if [ ! -f /data/ddf/.env ]; then
    cat > /data/ddf/.env << 'EOF'
JWT_SECRET=$(openssl rand -hex 32)
EOF
    echo "  ✅ 已生成 .env 文件"
else
    echo "  ⏭️  .env 已存在，跳过"
fi

# --- 复制部署文件 ---
echo ""
echo "[4/4] 复制部署文件..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cp -r "$PROJECT_DIR/deploy/docker-compose.yml" /data/ddf/
echo "  ✅ docker-compose.yml"
cp -r "$PROJECT_DIR/deploy/.env.example" /data/ddf/.env.example
echo "  ✅ .env.example"

echo ""
echo "========================================"
echo "  ✅ 初始化完成"
echo "  下一步:"
echo "    cd /data/ddf"
echo "    docker compose up -d"
echo "========================================"
