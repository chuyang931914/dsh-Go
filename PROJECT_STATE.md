# dsh-Go 项目记忆（新对话先读这一页）

> 最后更新：2026-11-12 07:33（Asia/Shanghai）
>
> 这一页是给每个新对话的“开机记忆”：项目是什么、当前状态、双端分工、必须遵守的规则、正在做的事和下一步。
> 详细实现与历史看 [`HANDOFF.md`](HANDOFF.md)；长期用户指令与决策看 [`project_memory.md`](project_memory.md)。
> 本文件同时是 `/root/workspace/AGENTS.md` 的软链目标，新对话会把它作为工作区指令自动加载。

## 1. 项目是什么

- **dsh-Go 个人魔改版**：DeepSeek Harness 的 Android 客户端（Flutter 原生界面 + 纯 Dart 客户端 + PRoot 里跑 `dsh web` 的引擎运行时）。
- 上游 1.0.15；本仓库是自用魔改，**不发布、不跟随官方更新**，自签名（证书 SHA-256 `fb462eb1…3c2f`，keystore `D:\Android\keystore\dsh-go-release.jks`）。
- Gitee 是唯一事实源：`gitee.com/chuyang931914/dsh-go-mogai`；GitHub `chuyang931914/dsh-Go` 由 Gitee Push 镜像自动同步；默认分支都是 `main`。
- 手机端仓库：`/root/workspace/dsh-Go`（兼容软链 `/root/dsh-Go`）；电脑端构建源：WSL `/root/dsh-Go`。

## 2. 当前状态（以仓库当前提交为准）

- 仓库：`main` 已合并 `phone 3bf2914`，电脑侧金色图/测试适配为 `81bcd98`；`phone = 3bf2914`。
- 实机：仍是 **`1.0.18+11112142`**；1.0.19 已出包，待装机验时间戳/全局切换与 8–40dp 手感。
- 1.0.19 APK：`11120055`，证书 `fb462eb1…3c2f`，sha256 `0db5bb9a…ba4c`，在 `D:\Android\apk\`；电脑重建 44 张金色图，`test/chat + test/shell` 2184 全通过。APK 与 HANDOFF 已覆盖飞书原链接。
- 1.0.17 已交付：长按菜单裁剪（复制/全选/翻译 + ⋯ 分享/朗读/问AI）、问AI填入输入框、聊天页宠物关闭、左右滑只保留边缘 24dp、系统翻译。
- 1.0.17 真机反馈两个问题：翻译跳到了 vivo **浏览器**、朗读语速太快；菜单/问AI/宠物/滑动手势三项未报问题。
- 1.0.18 已收口：`SelectionPlugin.kt` 优先 `com.vivo.translator`、排除浏览器；朗读 `rate: 0.8, pitch: 1.0`；真机两项复验通过。

## 3. 双端分工

| 端 | 做什么 | 不做什么 |
| --- | --- | --- |
| 电脑（Windows + WSL `Ubuntu24`） | APK 构建/签名/分发、飞书与 D 盘同步、全量 `flutter test`、金色图重建、上游升级 | 不把没跑过测试的代码推 `main` |
| 手机（Android proot Ubuntu，aarch64） | `dart analyze`、非金色图测试、交叉复跑、文档维护、装机校验、分支整理 | **不构建/不分发 APK**；不重生成金色图 |

手机端环境：Flutter 3.47.7 linux-arm64 `/root/dev/flutter`；`source /root/dev/dsh-env.sh`；字体 `DSH_TEST_FONT_DIR=/usr/share/fonts/opentype/noto`。

## 4. 每次新对话必须先做

1. 读完这一页，再回答项目问题；**不要凭旧对话里的版本/状态直接下结论**。
2. 在仓库里确认当前事实：
   ```bash
   cd /root/workspace/dsh-Go
   git fetch origin
   git log -1 --format='%h %s'
   grep '^version:' app/pubspec.yaml
   ```
3. 需要实现细节、Rules、构建命令时读 `HANDOFF.md`；长期偏好/决策读 `project_memory.md`。
4. 改动前先看工作树/分支/上游，按 HANDOFF 8.3/第十四节走 `phone`；不要动 `main`。

## 5. 不可违反的规则

- 编辑/删除任何文件前先完整读取核验；大改先给方案。
- 提交前必须 `cd app && dart analyze` + 受影响目录的非金色图测试；测试没过不说“完成”。
- 文档/代码改动先 commit + 推 Gitee `phone`/`main`，推完才算完成（HANDOFF Rule 33）。
- **不要把 Gitee 令牌、keystore 密码写进文档/仓库/聊天**；凭据在 `~/.git-credentials`（600）。
- versionName 按发布 patch +1（当前 1.0.19），versionCode 由构建脚本按 `MMDDHHmm` 生成；APK 名带 versionName + buildNumber。
- 手机端不构建 APK；出包/分发只在电脑侧，走飞书云空间链接。
- 用户偏好：中文、手机屏幕小要简洁；先结论后细节；给绝对路径；不擅自扩大改动范围。

## 6. 当前待办（按顺序）

1. **1.0.19 待真机**：从飞书原链接安装 `11120055`，验时间戳显示/全局切换与 8–40dp 边缘手感。新问题继续追加 [`BACKLOG.md`](BACKLOG.md)。
2. **Live2D 聊天页宠物**：用户在确认素材/绑定能否做完；能做完做实时交互，做不完再议，未排期（见 `BACKLOG.md`）。
3. 安全项（令牌与 keystore 密码复用）用户已决定暂缓，不主动提。
4. 新对话可直接接手，不用重复 1.0.18 验收。

## 7. 最近关键决策

- 2026-11-11：长按菜单只保留复制/全选/翻译，⋯ 放分享/朗读/问AI；AI搜索、浏览器搜索、爱奇艺、快速搜索、搜视频、问问 DeepSeek、系统翻译全部剔除。
- 翻译不接新模型：走 Android `ACTION_PROCESS_TEXT`，优先 vivo 翻译本体；问AI只填入输入框，不自动发送。
- 聊天页宠物直接关闭（`PetStage(showPet: false)`）；悬浮窗/设置里的宠物保留。
- 聊天页中间左右滑禁用，只保留屏幕左右边缘 **8–40dp** 起手（0–8dp 留给系统返回手势）；抽屉/快捷面板仍可用。
- 每条消息显示时间戳：默认精简，点任意时间全聊天切换完整（周几+秒）；日期只在每天第一条。
- 1.0.16 是版本号冒烟包，不装机；验证基线仍以 `11111711` 为准，1.0.17 已覆盖安装成功。
- Gitee 令牌与 keystore 密码复用是已知低优先级安全问题：不写进文档/仓库，轮换时再处理。

## 8. 关键路径与命令

```bash
# 手机端
cd /root/workspace/dsh-Go
source /root/dev/dsh-env.sh
cd app && dart analyze && flutter test <受影响目录>

# 电脑端（WSL）
cd /root/dsh-Go && source tooling/env.sh
DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64
```

- 交接文档：`HANDOFF.md`
- 1.0.19 待办：`BACKLOG.md`
- 进度日志：`PROGRESS.md`
- 长期记忆：`project_memory.md`
- 安装/覆盖验证：`/sdcard/Download/DSH-Go/` 下的反馈与标记文件
- APK 下载（飞书）：`https://my.feishu.cn/file/RzcFbpFCyokpPqxVIq5cUI1QnuR`（当前 `1.0.19+11120055`）

## 9. 维护这一页

- **已验证（2026-11-11 23:05）**：新会话的工作区指令会自动包含本页（`/root/workspace/AGENTS.md` 软链生效），不需要用户先说“读 HANDOFF”。

- 每次发版、装机反馈、重要决策后，更新第 2、6、7 节；与 `HANDOFF.md` 同一次提交推送。
- 换机/重装后，克隆仓库并运行 `bash tooling/install-workspace-memory.sh`，重建 `/root/workspace/AGENTS.md` 软链。
- 这一页控制在 6KB 以内：它是“开机记忆”，不是详细文档。
