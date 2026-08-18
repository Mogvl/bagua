# ☯ 易经八卦 Web（命语 mingyu）· 绿联 NAS Docker 一键部署

基于 GitHub 开源项目 **命语（[Brhiza/mingyu](https://github.com/Brhiza/mingyu)，336⭐）** 的易经八卦 Web 应用部署包，专为**绿联 NAS（UGOS Pro）Docker** 优化：

- 🔮 六爻、梅花易数、奇门遁甲、大六壬、小六壬、塔罗、灵签、择日、八字、紫微、星盘一站式排盘
- 🐳 标准 `docker-compose.yml`，**零配置可用**，一条命令构建 + 启动
- 🔄 `restart: always`，NAS 重启后自动拉起
- 🤖 可选 DeepSeek AI 解读（不配置也能完整使用）

## 仓库结构

```
├── docker-compose.yml      # 标准 Compose 配置（默认端口 9801，AI 关闭，无需编辑）
├── setup.sh                # ★ 一键部署脚本（自动清理旧容器、生成配置、构建启动）
├── .env.example            # 环境变量模板（由 setup.sh 自动生成 .env，也可手动改）
├── mingyu/                 # 命语源码（随包附带，NAS 上直接构建）
├── build-image-win.ps1     # 备选：Windows 电脑本地构建镜像脚本
├── build-image-mac.sh      # 备选：macOS / Linux 电脑本地构建镜像脚本
└── 绿联NAS部署指南.md       # 完整部署手册（含 GUI 方式与 FAQ）
```

## 一键部署（推荐，绿联 NAS SSH）

```bash
git clone git@github.com:Mogvl/bagua.git
cd bagua
bash setup.sh
```

交互中全部回车即用默认值（端口 9801、AI 关闭）。部署完成后浏览器访问：

```
http://NAS的IP:9801
```

不想碰 SSH？→ 部署指南里有「电脑构建导入镜像」「绿联 Docker 项目（compose）」两种 GUI 方式。

## 手动方式（等效，不跑脚本）

```bash
cp .env.example .env        # 可选：不复制也能用默认配置
docker compose up -d --build
```

## ⚠️ 许可说明

- 本仓库内 `mingyu/` 源码来自 [Brhiza/mingyu](https://github.com/Brhiza/mingyu)，上游**未标注开源许可证**，仅供个人使用，请勿公开二次分发或商用。
- 本仓库其余内容（部署脚本、指南）可按个人需要自由使用。