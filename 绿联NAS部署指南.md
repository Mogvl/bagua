# 命语（mingyu）· 绿联 NAS Docker 部署指南

> 命语（[Brhiza/mingyu](https://github.com/Brhiza/mingyu)，336 ⭐）是目前 GitHub 上功能最全、且**自带 Docker 支持**的易经八卦 Web 应用：
> 六爻、梅花易数、奇门遁甲、大六壬、小六壬、塔罗、灵签、择日、八字、紫微、星盘一站式排盘。
> 本文介绍如何在绿联 NAS（UGOS Pro）上用 Docker 部署它。

---

## 一、本仓库结构

```
bagua/
├── mingyu/                      # 命语源码（来自 Brhiza/mingyu，随包附带）
├── docker-compose.ugreen.yml    # 绿联 NAS 专用 Compose 配置（端口、自启动已调好）
├── .env.example                 # 环境变量模板（端口、AI Key）
├── build-image-win.ps1          # Windows 电脑本地构建镜像脚本
├── build-image-mac.sh           # macOS / Linux 电脑本地构建镜像脚本
└── 绿联NAS部署指南.md            # 本文档
```

**部署方式二选一：**

| 方式 | 难度 | 说明 |
|---|---|---|
| **方式一：NAS 上 SSH 构建**（推荐） | ★★☆ | 需要开启 SSH，一条命令构建+启动，以后更新也方便 |
| **方式二：电脑构建→导入镜像** | ★☆☆ | 不需要 SSH，全程绿联 Docker 界面操作，最稳妥 |

---

## 二、部署前准备

1. 绿联 NAS 应用中心 → 安装 **Docker** 应用（UGOS Pro 自带）；
2. 把本仓库放到 NAS 共享文件夹中（例如 `共享文件/Docker/`），两种方式任选：
   - NAS 支持 git 时：`git clone git@github.com:Mogvl/bagua.git`（或在 GitHub 页面下载 zip 解压）；
   - 或者电脑上 clone/下载后，把整个 `bagua` 文件夹拷贝到 NAS；
3. 国内网络拉取 Docker Hub 基础镜像可能较慢，建议在绿联 Docker 应用 → 设置 → 镜像源中配置加速源（如 `https://docker.m.daocloud.io`），或让 NAS 挂代理；
4. 可选：配置好 DeepSeek API Key（见第五节），不配置也能用。

---

## 三、方式一：SSH 在 NAS 上构建部署（推荐）

### 3.1 开启 SSH

绿联 UGOS Pro：**控制面板 → 终端与SNMP → 启用 SSH**（端口默认 22）。

### 3.2 SSH 登录并部署

在电脑终端（Windows 用 PowerShell，macOS 用「终端」）执行：

```bash
# 登录 NAS（把 nas-ip 换成你 NAS 的 IP）
ssh 用户名@nas-ip

# 进入仓库目录（换成你拷贝/克隆到的实际路径）
cd /volume1/Docker/bagua

# 生成 .env（可选，不配 AI 可直接跳过）
cp .env.example .env

# 一键构建并后台启动（首次构建约 5~15 分钟）
docker compose -f docker-compose.ugreen.yml up -d --build
```

### 3.3 验证

```bash
# 查看容器状态与日志
docker ps | grep mingyu
docker compose -f docker-compose.ugreen.yml logs -f
```

浏览器访问 `http://NAS的IP:3000`，看到命语界面即部署成功。

---

## 四、方式二：电脑构建 → 导入镜像（免 SSH）

适合不想开 SSH 的用户。**在电脑上构建**（电脑需先装 Docker Desktop）：

**Windows：**

```powershell
# 在 bagua 目录下
.\build-image-win.ps1
```

**macOS / Linux：**

```bash
cd bagua
chmod +x build-image-mac.sh
./build-image-mac.sh
```

构建完成后得到 `mingyu-image.tar`（约 300~500 MB），然后：

1. 把 `mingyu-image.tar` 拷贝到绿联 NAS 任意共享文件夹；
2. 绿联 Docker 应用 → **镜像 → 导入** → 选择该文件；
3. 导入完成后在**镜像列表**找到 `mingyu:latest` → **创建容器**：
   - **端口映射**：`3000 → 3000`
   - **重启策略**：`总是重启`（always，保证 NAS 重启后自动拉起）
   - **环境变量**（可选，见第五节）
4. 启动容器后，浏览器访问 `http://NAS的IP:3000`。

---

## 五、配置 AI 解读（可选）

不配置也能完整使用排盘、起卦、解卦原文查询；配置后可获得 DeepSeek 等大模型的个性化解读。

1. 到 [DeepSeek 开放平台](https://platform.deepseek.com) 申请 API Key；
2. 修改 `.env` 文件（方式一），或在创建容器时设置环境变量（方式二）：

```env
AI_API_KEY=sk-你的Key
AI_BASE_URL=https://api.deepseek.com/v1
AI_MODEL=deepseek-chat
AI_PROVIDER_NAME=DeepSeek
AI_BUILTIN_ENABLED=true      # 关键：置为 true 启用服务端 AI
AI_DEFAULT_ENABLED=false     # 建议 false，让用户按需开启
```

方式一修改后重启生效：

```bash
docker compose -f docker-compose.ugreen.yml up -d
```

---

## 六、日常管理

```bash
# 查看日志
docker compose -f docker-compose.ugreen.yml logs -f

# 停止 / 启动
docker compose -f docker-compose.ugreen.yml stop
docker compose -f docker-compose.ugreen.yml start

# 更新到最新版（拉取本仓库更新，再重建镜像）
cd /volume1/Docker/bagua
git pull
docker compose -f docker-compose.ugreen.yml up -d --build

# 完全卸载（容器 + 镜像）
docker compose -f docker-compose.ugreen.yml down
docker rmi mingyu:latest
```

---

## 七、常见问题（FAQ）

**Q1：构建时拉取 `node:22-alpine` 失败 / 极慢？**
国内网络问题。在绿联 Docker 设置中配置镜像加速源（如 `https://docker.m.daocloud.io`），或为 NAS 配置代理后重试。

**Q2：端口 3000 被占用？**
修改 `.env` 中的 `UGREEN_PORT=3000` 为其他端口（如 8099），浏览器访问 `http://NAS的IP:8099`。

**Q3：NAS 重启后容器没起来？**
检查容器「重启策略」是否为 always。Compose 方式默认已设置 `restart: always`。

**Q4：构建报错网络问题（pnpm install 失败）？**
多为国内访问 npm 源慢，可在 NAS 上设置 npm 镜像后重试：

```bash
pnpm config set registry https://registry.npmmirror.com
```

**Q5：改了 `.env` 不生效？**
Compose 环境变量需要重建容器：`docker compose -f docker-compose.ugreen.yml up -d`（会自动重建配置变化的容器）。

**Q6：外面（公网）想访问？**
绿联 NAS 支持 DDNS + 端口转发；建议在 UGOS 防火墙中仅放行对应端口，或经由反向代理（如绿联自带的反向代理组件）加 HTTPS 访问。

---

## 八、许可证提醒

命语仓库**未标注开源许可证**（无 LICENSE 文件），私用完全没问题，但**不要公开二次分发或商用**。如果介意，可考虑备选：`RealKai42/liu-yao-divining`（MIT，六爻起卦+AI 解读，无 Docker 需自建）或纯静态版 `deeptexas-ai/Zhouyi-Bagua-Divination-Source-Code`（可挂 nginx）。