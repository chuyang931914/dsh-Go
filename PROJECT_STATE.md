# dsh-Go 项目记忆（新对话先读这一页）

> 最后更新：2026-11-13 19:47（Asia/Shanghai）
> 新对话的开机记忆：项目、状态、分工、规则、待办。实现细节看 [`HANDOFF.md`](HANDOFF.md)，版本与装机看 [`UPGRADE_TABLE.md`](UPGRADE_TABLE.md)，流水账看 [`PROGRESS.md`](PROGRESS.md)。
> 本文件也是 `/root/workspace/AGENTS.md` 的软链目标，会自动加载。

## 1. 项目是什么

- **dsh-Go 个人魔改版**：DeepSeek Harness 的 Android 客户端（Flutter 原生界面 + 纯 Dart 客户端 + PRoot 里跑 `dsh web` 的引擎）。
- 上游 1.0.15 起，自用、不发布、**不跟随官方**；自签名，证书 `fb462eb1…3c2f`，keystore `D:\Android\keystore\dsh-go-release.jks`。
- Gitee 是唯一事实源：`gitee.com/chuyang931914/dsh-go-mogai`；GitHub `chuyang931914/dsh-Go` 走 Gitee 镜像自动同步。
- 手机端仓库 `/root/workspace/dsh-Go`（软链 `/root/dsh-Go`）；电脑端构建源 WSL `/root/dsh-Go`。

## 2. 当前状态

- 仓库：`phone` = `7b938e6`；`main` 落后，构建前由电脑快进到 `phone`。
- 版本：`app/pubspec.yaml` = `1.0.28+1`；1.0.28 **代码已好、攒着一起出包**（用户 19:22 决定）。
- 实机：已装 `1.0.27+11131822`（19:11 装，基线已记）。选字恢复正常；拖到边缘自动滚动无效，1.0.28 已改全局指针路由，未验。
- 验证基线：`dart analyze` 0 error / 0 warning / 24 info；`message_menu` + `message_actions` 非金色 19 通过；电脑侧 `test/chat` 1969 通过。
- 1.0.25 的分层宠物是实验版，默认关，已停做。

## 3. 双端分工

| 端 | 做什么 | 不做什么 |
| --- | --- | --- |
| 电脑（Windows + WSL） | 构建签名分发、全量测试、金色图重建、D 盘与飞书同步 | 不把没跑过测试的代码推 `main` |
| 手机（Android proot，aarch64） | `dart analyze`、非金色图测试、文档、装机校验、分支整理 | 不构建 APK、不重构金色图 |

手机端：Flutter 3.47.7 `/root/dev/flutter`；`source /root/dev/dsh-env.sh`；`DSH_TEST_FONT_DIR=/usr/share/fonts/opentype/noto`。

## 4. 新对话先做

1. 读完这页，别凭旧聊天猜状态。
2. 核对事实：`git fetch origin` → `git log -1 --format='%h %s'` → `grep '^version:' app/pubspec.yaml`；看工作树与分支。
3. 改动走 `phone`，**不要动 `main`**；涉及时间先 `date '+%F %T %Z'`，不写“约/左右”。

## 5. 规则（不可违反）

- 编辑/删除前先完整读；大改先给方案。
- 提交前 `cd app && dart analyze` + 受影响非金色图测试；红测试不提交、不出包。
- 改动先 commit + 推 `phone`，推完才算完成；`main` 只在构建前由电脑快进。
- 不把令牌、keystore 密码写进文档/仓库/聊天；凭据在 `~/.git-credentials`（600）。
- 仓库是唯一源头：代码、插件源码、`config/ui.json`、文档都要入库；只 `secrets.json`、`node_modules/` 例外。
- versionName 每次出包 patch +1（当前 1.0.28），versionCode 由 `build-apk.sh` 按 `MMDDHHmm` 生成。
- 一轮只做一个主题；出包后同版本不再改代码，修复进下一个 patch。
- 手机端不构建、不分发 APK。
- 私钥/密钥不落明文：只走系统 Keystore，解锁后临时文件 5 分钟内删除。

## 6. 待办（按顺序）

1. **1.0.28 攒着出包**：修 1.0.27 的边缘自动滚动（改全局指针路由）+ 密钥保险箱（Keystore 绑锁屏、截屏保护、硬件密钥自检）。装后验：拖到边缘能滚、复制/全选/翻译/引用、思考展开保持；设置→密钥保险箱能录入/解锁/清除。
2. **待机耗电**：已定位强嫌疑——`DshService.kt` 启动引擎后无条件 `acquireWakeLock()`（无超时，只有在停服务时释放）；引擎空闲 60 秒约占单核 2.7%。方案：唤醒锁只在服务停止或前台任务时持有。未动手，见 `BACKLOG.md`。
3. **AI 费用插件**：`local-ai-cost` 已用，DeepSeek 余额 + 火山本月账单；凭据在插件 `secrets.json`（600），不入库。
4. **聊天页宠物：停做**（用户 18:21 决定）；WIP 在本地分支 `pets/layered-v2`（未推送）。
5. 安全项（令牌/keystore 复用）用户已决定暂缓，不主动提。

## 7. 关键决策

- 聊天页宠物关闭（`PetStage(showPet: false)`）；悬浮窗与设置里的宠物保留。
- 聊天页中间左右滑禁用，只保留左右边缘 0–80dp 起手（真机验证）。
- 长按菜单只留复制/全选/翻译，⋯ 放分享/朗读/问AI；翻译走 `ACTION_PROCESS_TEXT`，优先 vivo 翻译本体；问AI只填入输入框。
- AI 费用插件走官方接口；火山用子账号只读 AK/SK。
- 聊天页用 `ui.json` 的 `hide: ["pluginCapsule"]` 隐藏插件入口，费用条保留。
- `选择文字` 定为「弹层内边缘自动滚动」，不再把 `SelectionArea` 套到滚动容器外。
- 分层宠物做不好，停做；不再投入。

## 8. 路径与命令

```bash
# 手机端
cd /root/workspace/dsh-Go && source /root/dev/dsh-env.sh
cd app && dart analyze && flutter test <受影响目录>

# 电脑端（WSL）
cd /root/dsh-Go && source tooling/env.sh
DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64
```

- 交接：`HANDOFF.md`｜版本表：`UPGRADE_TABLE.md`｜待办：`BACKLOG.md`｜日志：`PROGRESS.md`
- 装机校验：`bash tooling/check-device.sh`；装包记录在 `$DSH_HOME/dsh-app/install-baseline-*.txt`
- 飞书 APK：`https://my.feishu.cn/file/RzcFbpFCyokpPqxVIq5cUI1QnuR`

## 9. 每轮固定动作

1. 手机改：analyze + 测试 → commit → push `phone`。
2. 电脑：`fetch` → `merge --ff-only origin/phone` → 测试全绿 → `main` 快进 → 构建 → 同步 D 盘/飞书。
3. 手机装：记 baseline → 装 → `check-device.sh` → 按清单验 → 写回 `PROGRESS`/`PROJECT_STATE`。
4. 新对话先 pull + `check-device.sh`，读第 2、6 节。
5. 构建前 `main` 必须等于 `phone`；有红测试不出包。

## 10. 维护这一页

- 保持在 6KB 以内：这是开机记忆，不是详细文档；细节挪 `HANDOFF.md`，历史挪 `PROGRESS.md`。
- 每次发版、装机、重要决策后更新第 2、6、7 节，与 `HANDOFF.md` 同一次提交推送。
- 换机/重装后运行 `DSH_WORKSPACE=/root/workspace bash /root/dsh-Go/tooling/install-workspace-memory.sh` 重建软链。
