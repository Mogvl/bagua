# ============================================================
# 命语（mingyu）镜像构建脚本 —— Windows PowerShell
# ------------------------------------------------------------
# 用法：
#   1. 安装 Docker Desktop（https://www.docker.com/products/docker-desktop/）
#   2. 在 PowerShell 中运行：  .\build-image-win.ps1
#   3. 构建完成后，把 mingyu-image.tar 拷贝到绿联 NAS，
#      在绿联 Docker 应用「镜像 → 导入」选择该文件即可
# ============================================================

$ErrorActionPreference = "Stop"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "[错误] 未检测到 Docker，请先安装 Docker Desktop" -ForegroundColor Red
    exit 1
}

# 进入源码目录（本脚本位于 mingyu-deploy/ 下）
Set-Location (Join-Path $PSScriptRoot "mingyu")

Write-Host "[1/3] 构建镜像 mingyu:latest（首次约需 5~15 分钟）..." -ForegroundColor Cyan
docker build -t mingyu:latest .

Write-Host "[2/3] 导出镜像到 mingyu-image.tar ..." -ForegroundColor Cyan
docker save -o (Join-Path $PSScriptRoot "mingyu-image.tar") mingyu:latest

Write-Host "[3/3] 完成！镜像文件：$PSScriptRoot\mingyu-image.tar" -ForegroundColor Green
Write-Host "接下来：把该文件拷到绿联 NAS，在 Docker 应用里「镜像 → 导入」，然后创建容器（端口 3000:3000，重启策略 always）。详见《绿联NAS部署指南.md》。"
