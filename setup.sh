#!/usr/bin/env bash
# ============================================================
# 命语（mingyu）· 绿联 NAS 一键部署脚本（镜像方式）
# ------------------------------------------------------------
# 用法：
#   bash setup.sh          （默认）拉取 ghcr.io/mogvl/bagua 镜像并启动
#   bash setup.sh --build  （备选）从 ./mingyu 源码本地构建镜像
#
# 功能：
#   1. 检查 Docker 环境
#   2. 自动清理旧容器（避免端口映射错误/同名冲突）
#   3. 启动容器（restart: unless-stopped，NAS 重启自动拉起）
# ============================================================
set -euo pipefail
cd "$(dirname "$0")"

COMPOSE_FILE="docker-compose.yml"
BUILD=0
for a in "$@"; do
  case "$a" in
    --build) BUILD=1; COMPOSE_FILE="docker-compose.build.yml" ;;
  esac
done

echo "== [1/4] 检查 Docker 环境 =="
if ! command -v docker >/dev/null 2>&1; then
  echo "[错误] 未检测到 docker 命令。请先在绿联应用中心安装 Docker 应用，或用 SSH 登录 NAS 后执行本脚本。" >&2
  exit 1
fi

COMPOSE=(docker compose)
if ! docker compose version >/dev/null 2>&1; then
  if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE=(docker-compose)
  else
    echo "[错误] 未检测到 docker compose 插件。" >&2
    exit 1
  fi
fi

echo "== [2/4] 清理旧容器（避免同名冲突与旧端口映射） =="
if docker ps -a --format '{{.Names}}' | grep -qx mingyu; then
  read -r -p "发现已存在的 mingyu 容器（可能是旧配置）。删除后用新配置重建？[Y/n] " ans
  case "${ans:-Y}" in
    n|N) echo "已跳过删除，继续部署（注意：可能因同名冲突失败）。" ;;
    *)   docker rm -f mingyu; echo "已删除旧容器。" ;;
  esac
fi

if [ "$BUILD" = "1" ]; then
  echo "== [3/4] 从源码构建镜像（首次约 5~15 分钟） =="
else
  echo "== [3/4] 拉取镜像 ghcr.io/mogvl/bagua:latest =="
fi

echo "== [4/4] 启动容器 =="
if [ "$BUILD" = "1" ]; then
  "${COMPOSE[@]}" -f "$COMPOSE_FILE" up -d --build
else
  "${COMPOSE[@]}" -f "$COMPOSE_FILE" up -d
fi
"${COMPOSE[@]}" -f "$COMPOSE_FILE" ps

echo
echo "============================================================"
echo " ✅ 部署完成！浏览器访问： http://NAS的IP:9801"
echo "    查看日志: ${COMPOSE[*]} -f $COMPOSE_FILE logs -f"
echo "    停止服务: ${COMPOSE[*]} -f $COMPOSE_FILE down"
echo "============================================================"