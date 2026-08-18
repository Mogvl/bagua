# ☯ 易经八卦 Web（命语 mingyu）· 绿联 NAS Docker 一键部署

基于 GitHub 开源项目 **命语（[Brhiza/mingyu](https://github.com/Brhiza/mingyu)，336⭐）** 的易经八卦 Web 应用，**镜像一键部署**，专为**绿联 NAS（UGOS Pro）Docker** 优化：

- 🔮 六爻、梅花易数、奇门遁甲、大六壬、小六壬、塔罗、灵签、择日、八字、紫微、星盘一站式排盘
- 🐳 `image: ghcr.io/mogvl/bagua:latest` —— 粘贴 compose 即部署，**无需源码、无需构建**
- 🔄 `restart: unless-stopped`，NAS 重启自动拉起
- 🤖 可选 DeepSeek AI 解读（默认关闭，改一行配置即可开启）
- 📦 镜像由 GitHub Actions 自动构建发布（每次 push 触发 CI）

## 一键部署（绿联 Docker「项目」）

把下面内容粘贴到 绿联 Docker → **项目 → 新建项目**，保存即启动：

```yaml
services:
  mingyu:
    image: ghcr.io/mogvl/bagua:latest
    container_name: mingyu
    restart: unless-stopped
    environment:
      PORT: 9801
      AI_API_KEY: ""
      AI_BASE_URL: https://api.deepseek.com/v1
      AI_MODEL: deepseek-chat
      AI_PROVIDER_NAME: DeepSeek
      AI_BUILTIN_ENABLED: "false"
      AI_DEFAULT_ENABLED: "false"
    ports:
      - "9801:9801"
```

部署完成后浏览器访问：**`http://NAS的IP:9801`**（完整内容见仓库内 `docker-compose.yml`）

> ⚠️ 首次使用需等镜像发布：仓库 push 后 GitHub Actions 会在几分钟内把镜像构建并推送到 `ghcr.io/mogvl/bagua:latest`（可在仓库 Actions 页看状态）。若 NAS 拉不到镜像，可临时用 `bash setup.sh --build` 从源码构建。

## 仓库结构

```
├── docker-compose.yml       # ★ 一键部署（拉取 GHCR 镜像，零配置）
├── docker-compose.build.yml # 备选：从 ./mingyu 源码构建
├── setup.sh                 # 一键脚本：bash setup.sh [--build]
├── mingyu/                  # 命语源码（CI 构建用；--build 时本地用）
├── build-image-win.ps1      # 备选：Windows 构建镜像导出 tar
├── build-image-mac.sh       # 备选：macOS/Linux 构建镜像导出 tar
├── .github/workflows/ci.yml # CI：pnpm 构建检查 + 镜像发布到 GHCR
└── 绿联NAS部署指南.md        # 完整部署手册与 FAQ
```

## 其他方式

| 方式 | 命令 |
|---|---|
| SSH 一键部署（拉镜像） | `bash setup.sh` |
| SSH 一键部署（源码构建） | `bash setup.sh --build` |
| 手动 compose（镜像） | `docker compose up -d` |
| 手动 compose（源码构建） | `docker compose -f docker-compose.build.yml up -d --build` |

## ⚠️ 许可说明

- `mingyu/` 源码来自 [Brhiza/mingyu](https://github.com/Brhiza/mingyu)，上游**未标注开源许可证**，仅供个人使用，请勿公开二次分发或商用；本项目发布镜像仅供部署者本人使用。
- 本仓库其余内容（部署脚本、CI、指南）可按个人需要自由使用。