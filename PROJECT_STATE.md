# dsh-Go 项目记忆（新对话先读这一页）

> 最后更新：2026-11-13 15:41（Asia/Shanghai）
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

- 仓库：`main` = `phone` = `816408d`（1.0.25 分层宠物 + 1.0.24 长消息选字/思考展开保持）。
- 实机：已装 **`1.0.23+11121734`**；**直接覆盖装 1.0.25+11131541**，跳过 1.0.24。
- 1.0.25 APK：`11131541`，208,013,822 字节，sha256 `7f4f28d3…75cd`，证书 `fb462eb1…3c2f`；飞书 APK token 已覆盖（版本 `7707560777976155127`）。
- 电脑侧验证：`dart analyze` 0 error / 0 warning / 24 info；`test/chat` **1969 通过 / 0 失败**。
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
5. **时间必须精确**：回答涉及时间/计时前先运行 `date '+%F %T %Z'`，写精确值；禁止“约/左右/四舍五入”。聊天页时间戳只是 UI，不作为时钟。

## 5. 不可违反的规则

- 编辑/删除任何文件前先完整读取核验；大改先给方案。
- 提交前必须 `cd app && dart analyze` + 受影响目录的非金色图测试；测试没过不说“完成”。
- 文档/代码改动先 commit + 推 Gitee `phone`/`main`，推完才算完成（HANDOFF Rule 33）。
- **不要把 Gitee 令牌、keystore 密码写进文档/仓库/聊天**；凭据在 `~/.git-credentials`（600）。
- **仓库是唯一源头**：手机/电脑的代码、插件源码、界面配置、文档改动都必须提交并推送；只有密钥（`secrets.json`）和 `node_modules/` 例外。
- versionName 按发布 patch +1（当前 1.0.25），versionCode 由构建脚本按 `MMDDHHmm` 生成；APK 名带 versionName + buildNumber。
- 手机端不构建 APK；出包/分发只在电脑侧，走飞书云空间链接。
- 用户偏好：中文、手机屏幕小要简洁；先结论后细节；给绝对路径；不擅自扩大改动范围。

## 6. 当前待办（按顺序）

1. **1.0.25 待真机覆盖**：直接装 `1.0.25+11131541`（跳过 1.0.24）；验长消息跨页选字、思考展开保持、聊天页分层宠物（呼吸/随机小动作/眨眼）。
2. **AI 费用插件**：`local-ai-cost` 已在用，DeepSeek 余额 + 火山本月账单；凭据在插件 `secrets.json` 600，不入库。
3. **Live2D 聊天页宠物**：用户在确认素材/绑定能否做完；能做完做实时交互，做不完再议，未排期（见 `BACKLOG.md`）。
4. 安全项（令牌与 keystore 密码复用）用户已决定暂缓，不主动提。
5. 新对话可直接接手，不用重复 1.0.18 验收。

## 7. 最近关键决策

- 2026-11-11：长按菜单只保留复制/全选/翻译，⋯ 放分享/朗读/问AI；AI搜索、浏览器搜索、爱奇艺、快速搜索、搜视频、问问 DeepSeek、系统翻译全部剔除。
- 翻译不接新模型：走 Android `ACTION_PROCESS_TEXT`，优先 vivo 翻译本体；问AI只填入输入框，不自动发送。
- 聊天页宠物直接关闭（`PetStage(showPet: false)`）；悬浮窗/设置里的宠物保留。
- 聊天页中间左右滑禁用，只保留屏幕左右边缘 **0–80dp** 起手（最外 0–20dp 可能被系统返回手势拿走）；真机已验证可稳定触发。
- 每条消息显示时间戳：默认精简，点任意时间全聊天切换完整（周几+秒）；日期只在每天第一条；真机已验证。
- 2026-11-12：AI 费用插件 `local-ai-cost` 用官方接口查 DeepSeek 余额与火山本月账单；火山用子账号账单只读 AK/SK，不用 Ark API Key。
- 2026-11-12：聊天页用 `ui.json` 的 `hide: ["pluginCapsule"]` 隐藏「插件」聚合入口；费用条和面板保留。
- 2026-11-13：聊天页分层宠物阶段1，默认关，蓝发少女立绘呼吸/摇晃/点击；后续阶段加眨眼/表情/口型。
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
- 待办/问题：`BACKLOG.md`
- 进度日志：`PROGRESS.md`
- 长期记忆：`project_memory.md`
- 安装/覆盖验证：`/sdcard/Download/DSH-Go/` 下的反馈与标记文件
- APK 下载（飞书）：`https://my.feishu.cn/file/RzcFbpFCyokpPqxVIq5cUI1QnuR`（当前 `1.0.25+11131541`）

## 9. 维护这一页

- **已验证（2026-11-11 23:05）**：新会话的工作区指令会自动包含本页（`/root/workspace/AGENTS.md` 软链生效），不需要用户先说“读 HANDOFF”。

- 每次发版、装机反馈、重要决策后，更新第 2、6、7 节；与 `HANDOFF.md` 同一次提交推送。
- 换机/重装后，克隆仓库并运行 `bash tooling/install-workspace-memory.sh`，重建 `/root/workspace/AGENTS.md` 软链。
- 这一页控制在 6KB 以内：它是“开机记忆”，不是详细文档。

## 10. 电脑端开机记忆（只装一次）

电脑新对话不应每次手贴文档。先确认仓库在 `/root/dsh-Go`，然后运行一次：

```bash
DSH_WORKSPACE=/root/workspace bash /root/dsh-Go/tooling/install-workspace-memory.sh
```

它把 `/root/workspace/AGENTS.md` 指向 `/root/dsh-Go/PROJECT_STATE.md`；之后新对话自动带上当前状态。仓库更新后 `PROJECT_STATE` 本身更新，不用重装软链。

若电脑的工作区不是 `/root/workspace`，把 `DSH_WORKSPACE` 换成实际目录。脚本在父目录是 `/root` 且 `/root/workspace` 存在时也会自动选它。

## 11. 每轮固定动作（防漂移）

1. 手机改：`dart analyze` + 受影响非金色测试 → commit → push `phone`；插件源码、`config/ui.json`、文档同一轮入库。
2. 电脑：`git fetch` → `git merge --ff-only origin/phone` → 测试通过才构建；构建后更新 HANDOFF 并同步 D 盘/飞书。
3. 手机装：先记 baseline → 覆盖安装 → `bash tooling/check-device.sh` → 按本轮清单验 → 结果写 PROGRESS/PROJECT_STATE。
4. 新对话先 `git pull` + `bash tooling/check-device.sh`，读第 2、6 节；不从旧聊天猜版本/配置。
5. 一轮只收一个主题；版本号只在构建时 +1；未验证不写“收口”。
6. **有红测试不出包**：要么修到全绿，要么在 HANDOFF 明确写 waiver 和风险；默认不允许带红构建。
7. **出包后同一版本不再改代码**：任何修复进下一个 patch，避免 1.0.22→1.0.23 这种返工。
8. **构建前 `main` 必须等于 `phone`**；手机装完必须跑 `bash tooling/check-device.sh`。
