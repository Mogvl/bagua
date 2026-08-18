#!/usr/bin/env bash
# ============================================================
# 命语（mingyu）镜像构建脚本 —— macOS / Linux
# ------------------------------------------------------------
# 用法：
#   1. 安装 Docker Desktop / Docker Engine
#   2. 运行：  chmod +x build-image-mac.sh && ./build-image-mac.sh
#   3. 构建完成后，把 mingyu-image.tar 拷贝到绿联 NAS，
#      在绿联 Docker 应用「镜像 → 导入」选择该文件即可
# ============================================================
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "[错误] 未检测到 Docker，请先安装。" >&2
  exit 1
fi

cd "$(dirname "$0")/mingyu"

echo "[1/3] 构建镜像 mingyu:latest（首次约需 5~15 分钟）..."
docker build -t mingyu:latest .

echo "[2/3] 导出镜像到 mingyu-image.tar ..."
docker save -o ../mingyu-image.tar mingyu:latest

echo "[3/3] 完成！镜像文件：$(cd .. && pwd)/mingyu-image.tar"
echo "接下来：把该文件拷到绿联 NAS，在 Docker 应用里「镜像 → 导入」，然后创建容器（端口 3000:3000，重启策略 always）。详见《绿联NAS部署指南.md》。"
