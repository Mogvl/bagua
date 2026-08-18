# 命语（mingyu）· 绿联 NAS Docker 部署指南

> 命语（[Brhiza/mingyu](https://github.com/Brhiza/mingyu)，336 ⭐）是目前 GitHub 上功能最全、且**自带 Docker 支持**的易经八卦 Web 应用：
> 六爻、梅花易数、奇门遁甲、大六壬、小六壬、塔罗、灵签、择日、八字、紫微、星盘一站式排盘。
> 本仓库为它在**绿联 NAS（UGOS Pro）**上的 Docker 部署包，提供标准 Compose 配置与一键部署脚本。

---

## 一、仓库结构

```
├── docker-compose.yml      # 标准 Compose 配置（默认端口 9801，AI 关闭，零编辑可用）
├── setup.sh                # ★ 一键部署脚本
├── .env.example            # 环境变量模板（setup.sh 自动生成 .env）
├── mingyu/                 # 命语源码（随包附带，NAS 上直接构建）
├── build-image-win.ps1     # 备选：Windows 电脑本地构建镜像脚本
├── build-image-mac.sh      # 备选：macOS / Linux 电脑本地构建镜像脚本
└── 绿联NAS部署指南.md       # 本文档
```

**三种部署方式任选：**

| 方式 | 难度 | 说明 |
|---|---|---|
| **方式一：一键脚本**（推荐） | ★☆☆ | SSH 一条命令 `bash setup.sh`，自动完成全部配置与排错 |
| **方式二：电脑构建→导入镜像** | ★★☆ | 免 SSH，全程绿联 Docker 界面操作 |
| **方式三：绿联「项目」用 Compose** | ★★☆ | 在绿联 Docker 界面里创建 compose 项目 |

---

## 二、部署前准备

1. 绿联 NAS 应用中心 → 安装 **Docker** 应用（UGOS Pro 自带）；
2. 把本仓库放到 NAS 共享文件夹（例如 `共享文件/Docker/bagua/`）：
   - NAS 支持 git：`git clone git@github.com:Mogvl/bagua.git`；
   - 或电脑上下载 zip 解压后拷贝整个 `bagua` 文件夹到 NAS；
3. 国内网络拉取 Docker Hub 基础镜像可能较慢：绿联 Docker → 设置 → 镜像源，配置加速源（如 `https://docker.m.daocloud.io`）后重试。

---

## 三、方式一：一键部署（推荐）

### 3.1 开启 NAS 的 SSH

绿联 UGOS Pro：**控制面板 → 终端与SNMP → 启用 SSH**（端口默认 22）。

### 3.2 SSH 登录并执行一键脚本

在电脑终端（Windows 用 PowerShell，macOS 用「终端」）：

```bash
ssh 用户名@nas-ip

cd /volume1/Docker/bagua    # 换成你实际的仓库路径

bash setup.sh
```

脚本会自动完成：

1. 检查 Docker 环境；
2. **清理旧容器**（如果你之前用 GUI 建过端口映射不对的容器，会提示删除并用新配置重建 —— 解决「failed to forward request」这类问题）；
3. 首次自动生成 `.env`（默认端口 9801、AI 关闭）；
4. 交互询问**访问端口**和 **DeepSeek API Key**（全部直接回车用默认值，之后想改再改 `.env`）；
5. 构建镜像并启动容器（首次构建约 5~15 分钟），输出 `restart: always` 的容器状态。

不想交互？直接全默认：

```bash
bash setup.sh --yes
```

### 3.3 验证

```bash
docker compose ps
docker compose logs -f        # Ctrl+C 退出日志查看
```

浏览器访问 `http://NAS的IP:9801`，看到命语界面即部署成功。

---

## 四、方式二：电脑构建 → 导入镜像（免 SSH）

**在电脑上构建**（电脑需先装 Docker Desktop，Windows 用 PowerShell，macOS/Linux 用终端）：

```powershell
# Windows，在 bagua 目录下
.\build-image-win.ps1
```

```bash
# macOS / Linux，在 bagua 目录下
chmod +x build-image-mac.sh
./build-image-mac.sh
```

构建完成后得到 `mingyu-image.tar`（约 300~500 MB），然后：

1. 把 `mingyu-image.tar` 拷贝到绿联 NAS 任意共享文件夹；
2. 绿联 Docker 应用 → **镜像 → 导入** → 选择该文件；
3. 在**镜像列表**找到 `mingyu:latest` → **创建容器**：
   - **端口映射**：`9801 → 3000`（左侧宿主机端口，右侧容内端口务必填 **3000**，应用只监听 3000）
   - **重启策略**：`总是重启`（always）
   - **环境变量**（可选，见第六节）
4. 启动后浏览器访问 `http://NAS的IP:9801`。

> 提示：如果绿联界面建容器时把「容器端口」填成了 9801，界面「访问」按钮会转发失败（failed to forward request）—— 容器端口必须填 **3000**。

---

## 五、方式三：绿联「项目」（Compsoe 界面）

绿联 Docker 应用 → **项目 → 新建项目**：

1. 填写项目名（如 `bagua`），把本仓库的 `docker-compose.yml` 内容粘贴进去（或指向 NAS 上的文件路径）；
2. 构建上下文 `./mingyu` 需相对项目所在目录有效，源码必须已在 NAS 上；
3. 若你的绿联版本项目功能**不支持 build**（直接拉镜像），请改用方式一或方式二。

---

## 六、配置 AI 解读（可选）

不配置也能完整使用排盘、起卦、卦辞爻辞查询；配置后可获得 DeepSeek 等大模型的个性化解读。

1. 到 [DeepSeek 开放平台](https://platform.deepseek.com) 申请 API Key；
2. 修改 `.env`（一键脚本部署的，重跑一次 `bash setup.sh` 即可交互配置）：

```env
AI_API_KEY=sk-你的Key
AI_BASE_URL=https://api.deepseek.com/v1
AI_MODEL=deepseek-chat
AI_PROVIDER_NAME=DeepSeek
AI_BUILTIN_ENABLED=true      # 关键：置为 true 启用服务端 AI
AI_DEFAULT_ENABLED=false     # 建议 false，页面里按需开启
```

3. 重启生效：

```bash
docker compose up -d
```

---

## 七、日常管理

```bash
# 查看日志
docker compose logs -f

# 停止 / 启动
docker compose stop
docker compose start

# 更新到最新版（拉取本仓库更新，再重建镜像）
cd /volume1/Docker/bagua
git pull
docker compose up -d --build

# 完全卸载（容器 + 镜像）
docker compose down
docker rmi mingyu:latest
```

---

## 八、常见问题（FAQ）

**Q1：构建时拉取 `node:22-alpine` 失败 / 极慢？**
国内网络问题。绿联 Docker → 设置 → 镜像源配置加速源（如 `https://docker.m.daocloud.io`），或给 NAS 配置代理后重试。

**Q2：端口 9801 被占用？**
改 `.env` 中 `UGREEN_PORT=9801` 为其他端口（如 8099），然后 `docker compose up -d`，浏览器访问 `http://NAS的IP:8099`。

**Q3：NAS 重启后容器没起来？**
检查容器「重启策略」是否为 always。Compose 方式默认已设置 `restart: always`。

**Q4：构建报错网络问题（pnpm install 失败）？**
多为国内访问 npm 源慢，构建时临时设置镜像源重试：

```bash
docker build --build-arg PNPM_REGISTRY=https://registry.npmmirror.com -t mingyu:latest mingyu/
```

（或直接开代理后重试）

**Q5：改了 `.env` 不生效？**
Compose 环境变量需要重建容器：`docker compose up -d`（会自动重建配置变化的容器）。

**Q6：绿联界面点「访问」提示 failed to forward request？**
这个按钮是界面**代理转发到容器端口**，转发失败通常是：
- ① 容器没起来 / 应用没启动成功 → 看 `docker compose logs`；
- ② 创建的容器「容器端口」填错（常见：填了 9801，但应用监听的是 **3000**）→ 容器端口必须为 **3000**；
- ③ 用 `bash setup.sh` 一键重建容器即可自动修正映射；
- ④ 如果浏览器直接访问 `http://NAS的IP:9801` 正常、只有界面按钮报错，那是界面快捷访问的转发端口设置问题，直接在容器设置里把「网页/快捷访问端口」改为容器端口 **3000**，或以后直接用浏览器访问。

**Q7：外面（公网）想访问？**
绿联 NAS 支持 DDNS + 端口转发；建议在 UGOS 防火墙中仅放行对应端口，或经由反向代理加 HTTPS 访问。

---

## 九、许可证提醒

命语仓库**未标注开源许可证**（无 LICENSE 文件），私用完全没问题，但**不要公开二次分发或商用**。如果介意，可考虑备选：`RealKai42/liu-yao-divining`（MIT，六爻起卦+AI 解读，无 Docker 需自建）或纯静态版 `deeptexas-ai/Zhouyi-Bagua-Divination-Source-Code`（可挂 nginx）。