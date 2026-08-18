# ☯ 易经八卦 Web（命语 mingyu）· 绿联 NAS Docker 部署包

基于 GitHub 开源项目 **命语（[Brhiza/mingyu](https://github.com/Brhiza/mingyu)，336⭐）** 的易经八卦 Web 应用部署包，
专为**绿联 NAS（UGOS Pro）Docker** 优化：

- 🔮 六爻、梅花易数、奇门遁甲、大六壬、小六壬、塔罗、灵签、择日、八字、紫微、星盘一站式排盘
- 🐳 单容器部署，无需数据库，`docker compose up -d --build` 即可
- 🔄 `restart: always`，NAS 重启后自动拉起
- 🤖 可选 DeepSeek AI 解读（不配置也能完整使用）

## 仓库结构

```
├── mingyu/                      # 命语源码（来自 Brhiza/mingyu，随包附带便于 NAS 离线构建）
├── docker-compose.ugreen.yml    # 绿联 NAS 专用 Compose 配置
├── .env.example                 # 环境变量模板（端口 / AI Key）→ 复制为 .env 使用
├── build-image-win.ps1          # Windows 电脑本地构建镜像脚本
├── build-image-mac.sh           # macOS / Linux 电脑本地构建镜像脚本
└── 绿联NAS部署指南.md            # 完整部署手册
```

## 快速开始（绿联 NAS）

```bash
git clone git@github.com:Mogvl/bagua.git
cd bagua
cp .env.example .env        # 可选：配置端口 / DeepSeek AI Key
docker compose -f docker-compose.ugreen.yml up -d --build
```

浏览器访问 `http://NAS的IP:9801`。详细步骤、免 SSH 导入方式、AI 配置与 FAQ 见《绿联NAS部署指南.md》。

## ⚠️ 许可说明

- 本仓库内 `mingyu/` 源码来自 [Brhiza/mingyu](https://github.com/Brhiza/mingyu)，上游**未标注开源许可证**，仅供个人使用，请勿公开二次分发或商用。
- 本仓库其余内容（部署脚本、指南）可按个人需要自由使用。
