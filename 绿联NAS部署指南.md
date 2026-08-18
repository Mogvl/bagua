# 命语（mingyu）· 绿联 NAS Docker 部署指南

> 命语（[Brhiza/mingyu](https://github.com/Brhiza/mingyu)，336 ⭐）是目前 GitHub 上功能最全、且**自带 Docker 支持**的易经八卦 Web 应用：
> 六爻、梅花易数、奇门遁甲、大六壬、小六壬、塔罗、灵签、择日、八字、紫微、星盘一站式排盘。
>
> 本仓库采用**镜像化一键部署**：GitHub Actions 每次 push 自动把镜像发布到 `ghcr.io/mogvl/bagua:latest`，
> 在绿联 NAS 上**粘贴一行 compose 即可完成部署**，无需源码、无需构建。

---

## 一、部署方式总览

| 方式 | 难度 | 说明 |
|---|---|---|
| **方式一：绿联「项目」粘贴 Compose**（推荐） | ★☆☆ | 全程 GUI，粘贴保存即完成，最简单 |
| **方式二：SSH 一键脚本** | ★☆☆ | `bash setup.sh` 自动拉镜像并启动 |
| **方式三：电脑构建→导入镜像** | ★★☆ | 适合 NAS 拉不到 ghcr.io 镜像的场景 |

---

## 二、⚠️ 首次部署前必读：镜像什么时候可用？

镜像不是现成的，由 **GitHub Actions 自动构建发布**：

1. 本仓库每次 push 到 `main` 都会触发 CI（约 3~8 分钟），CI 中 `docker` 任务会把镜像推到 `ghcr.io/mogvl/bagua:latest`；
2. **第一次**部署前，确认仓库 Actions 页（https://github.com/Mogvl/bagua/actions）里最近一次运行的两个任务（`pnpm build`、`docker image`）都是 ✅ 绿色；
3. 之后 NAS 才能 `docker pull`/compose 拉到镜像。等不及 CI 的话，用方式二 `bash setup.sh --build` 本地源码构建，效果相同。

---

## 三、方式一：绿联「项目」一键部署（推荐）

1. 绿联 NAS 应用中心 → 安装 **Docker** 应用；
2. 打开 Docker → **项目 → 新建项目**，项目名填 `bagua`；
3. 把本仓库 `docker-compose.yml` 的**全部内容**粘贴进配置框（或在有网络的电脑上打开 [GitHub 上的 docker-compose.yml](https://github.com/Mogvl/bagua/blob/main/docker-compose.yml) 复制）：

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

4. 点击创建/保存 —— 绿联会自动拉取镜像并启动容器；
5. 浏览器访问 `http://NAS的IP:9801`。

> 如果绿联的「项目」功能不支持 `image` 直接拉取（个别旧版本），改用方式二。

---

## 四、方式二：SSH 一键脚本

1. 开启绿联 SSH：**控制面板 → 终端与SNMP → 启用 SSH**；
2. 把本仓库放到 NAS 共享文件夹（git clone 或下载 zip 解压，例如 `/volume1/Docker/bagua`）；
3. SSH 登录后执行：

```bash
cd /volume1/Docker/bagua
bash setup.sh          # 拉取 ghcr.io 镜像并启动
# 或：bash setup.sh --build   # 不拉镜像，直接本地源码构建（约 5~15 分钟）
```

4. 浏览器访问 `http://NAS的IP:9801`。

---

## 五、方式三：电脑构建 → 导入镜像（NAS 拉不到 ghcr.io 时）

NAS 网络拉不到 ghcr.io（国内网络常见）时的离线方案：

**在电脑上构建**（需装 Docker Desktop）：

```powershell
# Windows，在 bagua 目录下
.\build-image-win.ps1
```

```bash
# macOS / Linux
chmod +x build-image-mac.sh && ./build-image-mac.sh
```

得到 `mingyu-image.tar`（约 300~500 MB）后：绿联 Docker → **镜像 → 导入** → 选择该文件 → 创建容器：
- **端口映射**：`9801 → 9801`（左侧宿主机端口，右侧容器端口填 **9801**，即应用 `PORT` 环境变量值）
- **环境变量**：`PORT=9801`（必填，与应用监听端口一致）
- **重启策略**：`总是重启`

启动后浏览器访问 `http://NAS的IP:9801`。

---

## 六、配置 AI 解读（可选）

默认关闭也能完整使用排盘、起卦、卦辞爻辞查询；配置后可获得 DeepSeek 等大模型的个性化解读。

1. 到 [DeepSeek 开放平台](https://platform.deepseek.com) 申请 API Key；
2. 在 compose 中修改两处（方式一在绿联「项目」里编辑，方式二改 `docker-compose.yml`）：

```yaml
    environment:
      AI_API_KEY: "sk-你的Key"     # ← 填入 Key
      AI_BUILTIN_ENABLED: "true"   # ← 置为 true 启用服务端 AI
```

3. 重新部署/重建项目即可生效。

---

## 七、日常管理

```bash
# 查看日志
docker compose logs -f

# 停止 / 启动
docker compose stop
docker compose start

# 更新到新版（镜像由 CI 重新发布后，拉取新镜像即可）
docker compose pull
docker compose up -d

# 完全卸载
docker compose down
```

绿联「项目」方式：在项目详情里直接点 **重新部署/更新** 即可。

---

## 八、常见问题（FAQ）

**Q1：NAS 拉取 `ghcr.io/mogvl/bagua` 失败/超时？**
- 确认 CI 已跑完（见第二节），镜像确实已发布；
- 国内访问 ghcr.io 慢是常见问题：给 NAS 配置代理；或用方式二 `bash setup.sh --build` 源码构建；或用方式三离线导入。

**Q2：端口 9801 被占用？**
把 compose 里 `ports` 和 `PORT` 环境变量一起改成其他端口（如 `8099:8099` + `PORT: 8099`），浏览器访问新端口。

**Q3：NAS 重启后容器没起来？**
compose 已设置 `restart: unless-stopped`，会自动拉起。若手动创建过容器，确认重启策略为 `总是重启`。

**Q4：绿联界面点「访问」提示 failed to forward request？**
界面「访问」是代理转发到**容器端口**。本方案容器内监听 9801（`PORT=9801`），若你手动创建容器时容器端口填成 3000 或其它值就会转发失败；用本仓库 compose 或 `setup.sh` 重建即可。直接浏览器访问 `http://NAS的IP:9801` 最稳妥。

**Q5：怎么更新到最新版？**
仓库更新 push 后等 CI 跑完，执行 `docker compose pull && docker compose up -d`（或绿联项目里点更新）。

**Q6：想改源码自己定制？**
改 `mingyu/` 源码后用 `bash setup.sh --build` 本地构建；或拉取本仓库后自行扩展 CI。

---

## 九、许可证提醒

命语仓库**未标注开源许可证**（无 LICENSE 文件）；本仓库发布的 `ghcr.io/mogvl/bagua` 镜像仅供个人部署使用，**不要公开二次分发或商用**。如果介意，可考虑备选：`RealKai42/liu-yao-divining`（MIT，六爻起卦+AI 解读）或纯静态版 `deeptexas-ai/Zhouyi-Bagua-Divination-Source-Code`（可挂 nginx）。