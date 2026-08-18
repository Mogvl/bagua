#!/usr/bin/env bash
# ============================================================
# 命语（mingyu）· 绿联 NAS 一键部署脚本
# ------------------------------------------------------------
# 用法：
#   bash setup.sh          交互式（全部可回车跳过，用默认值）
#   bash setup.sh --yes    全默认，无需任何输入
#
# 功能：
#   1. 检查 Docker 环境
#   2. 自动清理旧容器（避免端口映射错误/同名冲突）
#   3. 首次自动生成 .env（默认端口 9801、AI 关闭）
#   4. 交互配置端口 / DeepSeek API Key（可跳过）
#   5. 构建镜像并启动容器（restart: always 自动拉起）
# ============================================================
set -euo pipefail
cd "$(dirname "$0")"

YES=0
[ "${1:-}" = "--yes" ] && YES=1

echo "== [1/5] 检查 Docker 环境 =="
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

echo "== [2/5] 清理旧容器（避免同名冲突与旧端口映射） =="
if docker ps -a --format '{{.Names}}' | grep -qx mingyu; then
  if [ "$YES" = "1" ]; then
    echo "发现旧容器 mingyu，自动删除并用新配置重建 ..."
    docker rm -f mingyu
  else
    read -r -p "发现已存在的 mingyu 容器（可能是旧配置，端口映射可能不对）。删除后用新配置重建？[Y/n] " ans
    case "${ans:-Y}" in
      n|N) echo "已跳过删除，继续部署（注意：可能因同名冲突失败）。" ;;
      *)   docker rm -f mingyu; echo "已删除旧容器。" ;;
    esac
  fi
fi

echo "== [3/5] 生成 .env（首次） =="
if [ ! -f .env ]; then
  cp .env.example .env
  echo "已生成 .env（默认端口 9801，AI 关闭）"
fi

echo "== [4/5] 配置端口 / AI（直接回车用默认值） =="
cur_port=$(sed -n 's/^UGREEN_PORT=//p' .env | tail -1)
cur_port=${cur_port:-9801}
port=$cur_port
if [ "$YES" != "1" ]; then
  read -r -p "访问端口 [当前 $cur_port，回车不变]: " p
  [ -n "$p" ] && port=$p
fi
sed -i "s/^UGREEN_PORT=.*/UGREEN_PORT=$port/" .env
echo "端口: $port"

if [ "$YES" != "1" ]; then
  read -r -p "DeepSeek API Key（不需要 AI 解读，直接回车）: " key
  if [ -n "$key" ]; then
    sed -i "s|^AI_API_KEY=.*|AI_API_KEY=$key|; s|^AI_BUILTIN_ENABLED=.*|AI_BUILTIN_ENABLED=true|" .env
    echo "已写入 API Key 并启用 AI 解读。"
  fi
fi

echo "== [5/5] 构建镜像并启动容器（首次约 5~15 分钟） =="
"${COMPOSE[@]}" up -d --build
"${COMPOSE[@]}" ps

echo
echo "============================================================"
echo " ✅ 部署完成！浏览器访问： http://NAS的IP:$port"
echo "    查看日志: ${COMPOSE[*]} logs -f"
echo "    停止服务: ${COMPOSE[*]} down"
echo "============================================================"
