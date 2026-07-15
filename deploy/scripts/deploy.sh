#!/bin/bash
# ============================================================
# DDF 部署管理脚本
# 用法: bash deploy.sh {up|down|restart|logs|status|update}
# ============================================================

set -euo pipefail

DEPLOY_DIR="/data/ddf"
COMPOSE_FILE="$DEPLOY_DIR/docker-compose.yml"
ENV_FILE="$DEPLOY_DIR/.env"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查部署目录
check_env() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        error "未找到 docker-compose.yml，请先运行 setup.sh"
        exit 1
    fi
    if [ ! -f "$ENV_FILE" ]; then
        warn "未找到 .env 文件，将使用默认配置"
    fi
}

case "${1:-help}" in
    up)
        check_env
        info "启动 DDF 服务..."
        cd "$DEPLOY_DIR"
        docker compose --env-file "$ENV_FILE" up -d
        info "服务已启动"
        info "  前端: http://localhost:80"
        info "  API:  http://localhost:3000"
        info "  健康: http://localhost:3000/api/health"
        ;;

    down)
        check_env
        info "停止 DDF 服务..."
        cd "$DEPLOY_DIR"
        docker compose down
        info "服务已停止"
        ;;

    restart)
        $0 down
        $0 up
        ;;

    logs)
        check_env
        cd "$DEPLOY_DIR"
        shift
        docker compose logs -f "$@"
        ;;

    status)
        check_env
        cd "$DEPLOY_DIR"
        echo ""
        echo "服务状态:"
        docker compose ps
        echo ""
        echo "资源占用:"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null || true
        ;;

    update)
        check_env
        info "更新 DDF 服务..."
        cd "$DEPLOY_DIR"
        docker compose pull
        docker compose up -d --force-recreate
        info "更新完成"
        ;;

    health)
        check_env
        echo "健康检查..."
        curl -sf http://localhost:3000/api/health && info "✅ API 正常" || error "❌ API 异常"
        curl -sf http://localhost:80 && info "✅ 前端正常" || error "❌ 前端异常"
        ;;

    *)
        echo "用法: bash deploy.sh {up|down|restart|logs|status|update|health}"
        echo ""
        echo "命令说明:"
        echo "  up       启动所有服务"
        echo "  down     停止所有服务"
        echo "  restart  重启所有服务"
        echo "  logs     查看日志 (可选: 服务名称)"
        echo "  status   查看服务状态"
        echo "  update   更新到最新版本"
        echo "  health   健康检查"
        ;;
esac
