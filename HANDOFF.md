# dsh-Go 魔改版 · 项目交接文档

> 用途：跨设备 / 跨账号 / 跨对话恢复本项目。任何人（或未来的我）拿到这份文档 + 两个仓库地址，就能从零把环境、签名、APK 全部重建出来。
> 最后更新：2026-11-14
> 权威副本：本文件同时放在仓库根目录 `HANDOFF.md`（随 Git 推送，跨设备可用）。
>
> **当前状态（2026-11-14 09:38）**：1.0.29 已出包，buildNumber `11140932`。**1.0.28 全部 + 聊天页长按选字边缘自动滚**（`chat_list.dart` 全局指针路由 + `TickerProviderStateMixin`）。`main` = `phone` = `b5bd8e7`。1.0.28 的选区弹层滚动代码保留未删。APK 已存 `D:\Android\apk\dsh-go-1.0.29-11140932-mogai-arm64.apk`，待装机验证长按选字拖边缘是否真的滚。

> **新对话记忆**：`/root/workspace/AGENTS.md` 是指向 [`PROJECT_STATE.md`](PROJECT_STATE.md) 的软链，新对话会自动加载；换机/重装后运行 `bash tooling/install-workspace-memory.sh`。

---

## 一、项目是什么

| 项 | 内容 |
| --- | --- |
| 上游项目 | dsh-Go（DeepSeek Harness 的 Android 客户端，Flutter 编写） |
| 上游版本 | 1.0.15（基线提交 `40c73ab`，未改动） |
| 本项目性质 | **个人魔改版**（去统计 / 锁默认模型档位 / 去隐私分享 / 去自动更新 / 关闭关于页入口），自签名，不跟随官方更新 |
| 主仓库（GitHub） | https://github.com/chuyang931914/dsh-Go.git （默认分支 `main`，由 Gitee Push 镜像自动同步；原上游历史镜像已弃用，见 8.2） |
| 镜像仓库（Gitee） | https://gitee.com/chuyang931914/dsh-go-mogai.git （`main` = 魔改版，含本交接文档） |
| Git 身份 | `chuyang` / `200414988+chuyang931914@users.noreply.github.com` |
| 分支 | Gitee `main`（唯一事实源）；GitHub `main`/`phone`（镜像自动同步，`mogai` 已删除） |
| 包名 / 版本 | `io.github.ccch1mneyyy.dsh_app`；versionName `1.0.15`（历史），自 `1.0.16` 起按第十节递增；versionCode 由构建脚本按 `MMDDHHmm` 生成 |

**重要：魔改版用自建签名，与官方签名不同 → 官方 APK 覆盖安装会失败，官方"应用内更新"天然装不上（双保险，即使忘了关更新也装不进去）。**

---

## 二、产物在哪

| 产物 | 路径 |
| --- | --- |
| 魔改版 APK（本地） | `D:\Android\apk\dsh-go-1.0.29-11140932-mogai-arm64.apk`（当前最新，206,214,152 字节，sha256 `c34fb33c…1ee485`） |
| **APK 下载（飞书云空间，优先）** | https://my.feishu.cn/file/RzcFbpFCyokpPqxVIq5cUI1QnuR （`dsh-go-1.0.29-11140932-mogai-arm64.apk`，当前 11140932；点开 → 右上角「...」→ 下载；飞书内直接下载，不走 GitHub/Gitee） |
| **源码包（飞书云空间）** | https://my.feishu.cn/file/K2kCbcXXDowHj4xewIpcTB1onRg （`dsh-go-1.0.29-11140932-mogai-src.zip`，626,822,487 字节 / 598MB，`main` = `4bd6477`，2026-11-14 上传；已排除 `.git`、`app/build`、`.dart_tool`、`runtime/.work`、`runtime/.cache`，保留 `runtime/out` 可直接重建 APK） |
| 源码包（飞书，旧版存档） | https://my.feishu.cn/file/IEqgbC77zoOqWmxo277cr8Wdnue （`dsh-go-1.0.15-mogai-src.zip`，1.0.15 时代，保留未删） |
| 源码包（本地） | `D:\Android\apk\dsh-go-1.0.29-11140932-mogai-src.zip`（同 sha256 `1c71d560…89029`） |
| APK 备份（GitHub Release） | https://github.com/chuyang931914/dsh-Go/releases/download/v1.0.15-mogai/dsh-go-1.0.15-mogai-arm64.apk |
| 构建脚本原始输出 | WSL 内 `/root/dsh-Go/app/build/app/outputs/flutter-apk/app-arm64-release.apk` |
| 签名文件 | `D:\Android\keystore\dsh-go-release.jks` |
| 签名备份（本地） | `D:\Android\keystore\backup\`：`dsh-go-release-backup.jks`、`dsh-go-keystore-20261111.zip`（含 jks + key.properties + 恢复说明 + SHA256SUMS） |
| 签名备份（第二本地） | `D:\备份\keystore-20261111\`（同 zip + 裸 jks，防误删 `D:\Android` 时一并丢失） |
| **签名备份（飞书云空间）** | https://my.feishu.cn/file/HPwebhSADomeoax2hQpcdc9YnXg （`dsh-go-keystore-20261111.zip`，4335 字节，2026-11-11 上传） |
| 签名备份（U 盘） | **待补**：插入 U 盘后拷贝 `dsh-go-keystore-20261111.zip`（第四份介质） |
| 构建源（唯一有效副本） | WSL `Ubuntu24` 内 `/root/dsh-Go` |
| Windows 访问构建源的 UNC 路径 | `\\wsl.localhost\Ubuntu24\root\dsh-Go\`（可直接用编辑器读写） |
| 交接文档（飞书云空间） | https://my.feishu.cn/file/OJSGbqo2IofCYQxm8uycjTGAn7d （`HANDOFF-dsh-Go.md`，每次更新后覆盖上传） |

**源码分发 `1.0.29`（2026-11-14 19:00）**：`dsh-go-1.0.29-11140932-mogai-src.zip` 已上传飞书（file token `K2kCbcXXDowHj4xewIpcTB1onRg`，云端版本 `7707983819785112840`），626,822,487 字节，sha256 `1c71d560f8c3ded5982725af523539ffb52ac2fb2ca44d1ef3dcff0b55089029`，6965 个文件，`pubspec` 1.0.29+1。已排除 `.git`/`app/build`/`.dart_tool`，保留 `runtime/out`。本地同份 `D:\Android\apk\`。**注意**：覆盖旧 token `IEqgbC77zoOqWmxo277cr8Wdnue` 连续两次报服务端 `1061001 unknown error`，改用新建文件上传成功，旧 1.0.15 源码包保留原 token 未删。

**构建 `11140932`（2026-11-14 09:38，1.0.29）**：`main` = `phone` = `b5bd8e7`（1.0.28 全部 + 聊天页长按选字边缘自动滚；本版只动 `chat_list.dart` +71 行，`_ChatListState` 由 `SingleTickerProviderStateMixin` 换 `TickerProviderStateMixin`，`_SelectTextSheet` 滚动代码保留未删；无 Kotlin 改动）。APK 206,214,152 字节，sha256 `c34fb33cfc49ef71b96306dd00b47e777759e1c81508bf08619df8b7131ee485`，证书 `fb462eb1…3c2f`，versionCode `11140932` > `11140025`，release 未开 R8/minify。电脑侧 `dart analyze` 0 error / 0 warning / 24 info；`flutter test test/chat` **1969 通过 / 0 失败**。APK 已存 `D:\Android\apk\dsh-go-1.0.29-11140932-mogai-arm64.apk`。

**分发 `11140932`（2026-11-14 09:45）**：APK `1.0.29+11140932` 已覆盖飞书原 file token（云端版本 `7707836313096981761`，206,214,152 字节）；HANDOFF 已覆盖飞书（file token `OJSGbqo2IofCYQxm8uycjTGAn7d`）与 `D:\HANDOFF.md`。

**构建 `11140025`（2026-11-14 00:25，1.0.28）**：`main` = `phone` = `82cbb8c`（撤回至 1.0.24 基底 `9da1d7c` + 选区全局指针路由 `e252b28` + 唤醒锁按需；隐藏思考已撤）。APK 206,215,379 字节，sha256 `ed984049db4adeceb8874219dab717091c225005c6ce2bd31d467eb53e55517f`，证书 `fb462eb1…3c2f`，versionCode `11140025` > `11131822`。电脑侧 `dart analyze` 0 error / 24 info；`flutter test test/chat` **1969 通过 / 0 失败**（含 message_menu 4 张 golden 全过）。新增 Kotlin 仅 `DshService.kt` + `RuntimePlugin.kt` 的 `setBusy` ~26 行。APK 已存 `D:\Android\apk\dsh-go-1.0.28-11140025-mogai-arm64.apk`。

**分发 `11140025`（2026-11-14 00:35）**：APK `1.0.28+11140025` 已覆盖飞书原 file token（云端版本 `7707699211113860288`，206,215,379 字节）；HANDOFF 已覆盖飞书（云端版本 `7707698589039856935`）与 `D:\HANDOFF.md`。

**构建 `11121309`（2026-11-12 13:09，1.0.21）**：`main` ← `phone` 快进（`f5306f9..c3bf654`，含 `197368c` 选字修复）；APK 206,211,961 字节，sha256 `e67678f34658c9bcf8cbc779203973b2967208d7ba5ab4a61788d66a9c75401d`，证书 `fb462eb1…3c2f`，versionCode `11121309` > `11120812`。电脑侧 `dart analyze` = 0 error / 0 warning / 24 info；`flutter test test/chat` = **1967 通过 / 0 失败**（含 message/image menu 4 张 golden 全通过）。手机端报告的 4 张 golden 红为字体像素漂移（Rule 31），**未重建金色基准**。APK 已存 `D:\Android\apk\dsh-go-1.0.21-11121309-mogai-arm64.apk`。

**构建 `11121734`（2026-11-12 17:34，1.0.23）**：`main` ← `phone` 快进到 `58fbe22`（含 `fbd7474`/`665475e` 等：顶部 17px 边界修复 + 1.0.22 直选/引用/翻译折叠 + 抽屉分组顺序 + 新对话自动加载 PROJECT_STATE）。APK 206,211,017 字节，sha256 `9580eb7380e0fe6940ba21cd842e648577afb86338d4d42787a71ac8ef5484e1`，证书 `fb462eb1…3c2f`，versionCode `11121734` > `11121454`。电脑侧 `dart analyze` 0/0/24；`test/chat` **1968 通过 / 0 失败**（`chat_top_boundary_test` 全绿，31 张 golden 按新 user_bubble 重建）。APK 已存 `D:\Android\apk\dsh-go-1.0.23-11121734-mogai-arm64.apk`；1.0.22（`11121454`）跳过未装。

**构建 `11121454`（2026-11-12 14:54，1.0.22）**：`main` ← `phone` 快进到 `705f46b`（直选/引用/翻译折叠 + 抽屉分组顺序）。APK 206,211,242 字节，sha256 `9d850a4299459332fc5edfd80af6a1804d4b789f19b859c1868589514428deb3`，证书 `fb462eb1…3c2f`，versionCode `11121454` > `11121309`。电脑侧 `dart analyze` 0/0/24；`test/chat` **1967 通过 / 1 失败**。为匹配新交互：`message_flow`/`fork_toast`/`secret_mask` 改用 `user-more`/`reply-action-more` 键进入菜单（不再长按/按 tooltip 找“更多”），39 张 chat golden 按新 UI 重建；唯一红 `chat_top_boundary_test` 为短历史顶部边界少算 17.04px（`min=424`，实际需 `441.04`，首行 `14.96` vs `32.0`），**待 phone 修**。APK 已存 `D:\Android\apk\dsh-go-1.0.22-11121454-mogai-arm64.apk`。

**分发 `11121734`（2026-11-12 17:40）**：APK `1.0.23+11121734` 待覆盖飞书 file token；HANDOFF 待覆盖飞书与 `D:\HANDOFF.md`。

**分发 `11121454`（2026-11-12 15:10）**：APK `1.0.22+11121454` 已覆盖飞书原 file token（云端版本 `7707176757484326126`，206,211,242 字节）；HANDOFF 已覆盖飞书与 `D:\HANDOFF.md`。

**分发 `11121309`（2026-11-12 13:28）**：APK `1.0.21+11121309` 已覆盖飞书原 file token（云端版本 `7707152225507806485`，206,211,961 字节），并发送到「城南」单聊 `oc_ef1b285c3aa75900a8d4221654d58b20`（message_id `om_x100b6060a811f0acdfc0fe9e49b0b72`），附「长按自己消息 → 选择文字」复验清单；HANDOFF 已覆盖飞书与 `D:\HANDOFF.md`。

**分发 `11120812`（2026-11-12 08:18）**：APK `1.0.20+11120812` 已覆盖飞书原 file token（云端版本 `7707072743111445690`），并发送到「城南」单聊 `oc_ef1b285c3aa75900a8d4221654d58b20`（message_id `om_x100b6064131680a0de3549dac57d65b`）。

**分发 `11120055`（2026-11-12 07:46）**：APK `1.0.19+11120055` 已覆盖飞书原链接，并以 user 身份发到「城南」当前单聊 `oc_ef1b285c3aa75900a8d4221654d58b20`（message_id `om_x100b607baa11c4a4c0ebfee8b0c0f2a`），附时间戳/全局切换与 8–40dp 边缘手势复验清单。

**最近一次分发（2026-11-11 01:26）**：APK `11110113` + 本交接文档已上传飞书云空间，并已发到「城南」私聊（message_id `om_x100b600175a05ca0dd7af731446ceea`）。

**分发 `11111711`（2026-11-11 17:28）**：已发到「城南」私聊（message_id `om_x100b60771c11c8a4dfb095d0331603d`）。走云空间链接（APK 196MB > 飞书 IM 100MB 上限），提示覆盖安装 + 验 `firstInstallTime`。

**本次重建（2026-11-11 17:11）**：APK `11111711`（`dsh-go 1.0.15`），源码 `0583f58`（main ← phone 快进合并，`6ccfbd7` + `0583f58` 两个手机端 commit），206.2 MB，SHA-256 `8a5ffc763a24ae49f8fb42428e22a42b2e12f36af99e7b02122c86ad6f563e9d`；验签证书 SHA-256 `fb462eb1…3c2f`（与 keystore 一致）。

**电脑端构建验证（2026-11-11 17:08 前）**：
- `dart analyze app` = 0 error / 0 warning / （未全量跑，只跑过 phone 接手的四线）
- `test/chat` = **1961 通过 / 0 失败**（含 turn_settle 7/7、message_actions、message_flow、goldens）
- GitHub 镜像 main/phone 均在 `0583f58`，0 差异（`git rev-list --left-right --count origin/main...github/main` = `0 0`）

**手机端接手验证（2026-11-11，phone 分支 `0583f58`）**：
- `dart analyze app` = 0 error / 0 warning / 23 info
- `turn_settle_test` 7/7，`message_actions + message_flow` 28/28
- 手机端环境：`/root/workspace/dsh-Go`（软链 `/root/dsh-Go`），Flutter 3.47.7 linux-arm64；**仍不构建 APK**（只负责验证）

**Gitee 合并历史**：phone 分支自 `c07ad5c`（电脑端最后一次 docs）增加两个 commit → `0583f58`。main 直接 `--ff-only` 合并（merge-base `c07ad5c`），无冲突。main 与 phone 现在 **同一个 HEAD** `0583f58`。

**版本号编码**：`11111711` = 2026-11-11 17:11 (UTC+8)，由 `tooling/build-apk.sh` 传入 `--build-number`，高于上一版 `11111558`（15:58）。APK 可覆盖安装。

**首次覆盖安装验证（✅ 已完成，2026-11-11 17:37）**：`11111558 → 11111711`，数据保留。证据见 3.5 节覆盖安装条。`firstInstallTime` 因手机端无 dumpsys 权限未读；等价证据已充分（卸载重装会清空数据目录）。电脑侧若连手机可补跑：
```bash
adb shell dumpsys package io.github.ccch1mneyyy.dsh_app | grep -E "firstInstallTime|lastUpdateTime"
```

**40px 抽动修复（`eb94753`）**：手机端给中间回复加独立 ⋯ 按钮（`IconButton` + `VisualDensity.compact` = 40px）后，**轮尾那条回复**在结算前也会出现 ⋯，结算后 ⋯ 让位给操作行 → 完成那一帧凭空少 40px，正文被顶一下（`turn_settle_test` 的 `The handoff must not insert a header-sized jump` 就是拦这个）。修法：`AssistantMessage` 增加 `isTurnTail`，由 `chat_list` 传入「当前轮最后一条助手正文」，轮尾不再补独立 ⋯（它的 ⋯ 在操作行里）。**没有改任何断言**（断言是设计约束）。

**验证结果（电脑侧，2026-11-11）**：`dart analyze` 0 error；`test/chat/turn_settle_test.dart` 7/7 通过；`test/chat` 全量 **1961 通过 / 0 失败**；重建 7 张金色图（`auto_approve_*`、`conversation*`、`en_conversation_light`，仅因轮尾不再出现 ⋯ + 选字排版变化）。

**当前 APK 与代码的差异（2026-11-11）**：`11110113` 构建于「物理删除关于/隐私/sharedLinks 残留 + 指南修正」提交。`11111558` 在此基础上含手机端聊天改进 + 40px 修复，均与源码一致。装上后设置里彻底没有「关于 DSH Go」与「隐私与分享」，搜索「关于」「版本」「开源许可」均无结果。

> 注意：`C:\Users\Administrator\Documents\Trae-CN\temp_20261110_04\dsh-Go` 是早期解压副本，**已过时，不要用来构建**。

---

## 三、环境（已装好，勿重装）

### 3.1 宿主与 WSL

- Windows + WSL2
- 发行版名：`Ubuntu24`（Ubuntu 24.04 noble，root 用户，无密码登录）
- 虚拟磁盘位置：`D:\WSL\Ubuntu24`（占用 C 盘以外的 D 盘）
- 进入方式：PowerShell 执行 `wsl.exe -d Ubuntu24`
- 从 Windows 侧访问文件：`\\wsl.localhost\Ubuntu24\...`
- 从 WSL 侧访问 D 盘：`/mnt/d/...`
- **WSLg 已禁用**（`C:\Users\Administrator\.wslconfig` 里 `guiApplications=false`）：WSL 3.0 的 `msrdc.exe` 与 Win10 旧版 `mstscax.dll` 不兼容会弹错，本项目只用命令行构建，禁用 GUI 无影响。详见第九节 Rule 16。

### 3.2 工具链（全部在 `/root/dev`）

| 组件 | 路径 | 版本 |
| --- | --- | --- |
| JDK | `/root/dev/jdk-17` | 17 |
| Flutter | `/root/dev/flutter` | 3.47.7 |
| Android SDK | `/root/dev/android-sdk` | platform 36 / build-tools 36.0.0 / NDK 28.2.13676358 |
| Gradle | 由 Gradle Wrapper 管理 | 9.3.1 |
| CJK 字体（**仅测试机需要，不影响 APK**） | apt `fonts-noto-cjk`，默认目录 `/usr/share/fonts/noto-cjk`（可用 `DSH_TEST_FONT_DIR` 覆盖） | 缺 `NotoSansCJK-{Light,Regular,Bold}.ttc` 时测试故意 fail-fast；真机中文由 Android 系统字体兜底 |

### 3.3 环境变量脚本（构建前必须 source）

`/root/dsh-Go/tooling/env.sh`：

```bash
export JAVA_HOME="/root/dev/jdk-17"
export ANDROID_HOME="/root/dev/android-sdk"
export ANDROID_SDK_ROOT="/root/dev/android-sdk"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
export PATH="/root/dev/jdk-17/bin:/root/dev/flutter/bin:/root/dev/android-sdk/cmdline-tools/latest/bin:/root/dev/android-sdk/platform-tools:/root/dev/android-sdk/emulator:$PATH"
```

### 3.4 手机端辅助环境（2026-11-11，Android 手机 proot Ubuntu 24.04，aarch64）

- **分工**：9.3 五批清账已于 2026-11-11 由电脑（WSL）侧完成（新基线见 9.2）；手机端只做 `dart analyze` / `flutter test`（非金色图判定）/ 文档维护 / 独立分支提交。**手机端不构建、不分发 APK**（四个硬阻断见 Rule 30）。
- 布局：`/root/workspace/dsh-Go`（DSH 工作区实际仓库；`/root/dsh-Go` 是指向它的兼容软链）、`/root/dev/flutter`（3.47.7，linux-arm64；官方无 arm64 预编译包，用 Gitee 镜像 `gitee.com/mirrors/Flutter` 按 tag `3.47.7` 浅克隆自举）、`/root/dev/dsh-env.sh`（测试环境变量，含 PATH / PUB / FLUTTER_STORAGE / DSH_TEST_FONT_DIR）、`/root/dev/dsh-push.sh`（推送脚本，只推 Gitee）。
- 使用：`source /root/dev/dsh-env.sh` 后 `cd /root/dsh-Go/app` 即可 analyze/test。env 内 `DSH_TEST_FONT_DIR=/usr/share/fonts/opentype/noto`（noble 的 `fonts-noto-cjk` 装在 opentype 下；Light 字重要另装 `fonts-noto-cjk-extra`，两个包都要）。
- 凭据：`~/.git-credentials`（chmod 600，`credential.helper=store`）已存 Gitee 与 GitHub 令牌，推送可用。
- 基线（2026-11-11）：电脑侧五批清账后，回归面 `test/settings test/star test/ui_config` = 473 通过 / 0 跳过 / 0 失败，全量 `flutter test` = 10845 通过 / ~288 跳过 / 0 失败；`dart analyze` = 0 error / 0 warning / 23 info。手机端复跑时金色图会因字体渲染不同而像素漂移（见 Rule 31），只验收 analyze 与非金色图结果。手机端交叉验证（`d746042`）：电脑侧改动过的 12 个测试文件 = 381 通过 / 39 金色图漂移 / 0 真实失败。

### 3.5 四线一致性（2026-11-12 17:40，1.0.23 已构建待真机覆盖）

| 线 | 事实 | 状态 |
| --- | --- | --- |
| 仓库 | `main` = `phone`（`58fbe22`，1.0.23 + 顶部 17px 修复） | ✅ |
| 代码 | 1.0.23：修复短历史顶部边界少算 17.04px；1.0.22 直选/引用/翻译折叠 + 抽屉分组顺序；桌面侧自动加载 PROJECT_STATE | ✅ |
| APK | `11121734`（1.0.23），206,211,017 字节，sha256 `9580eb73…4e1`，证书 `fb462eb1…3c2f` | ✅ |
| 实机 | 已装 1.0.21+11121309；**直接覆盖装 1.0.23+11121734**，跳过 1.0.22 | ⏳ 待装 |
| 测试 | `dart analyze` 0/0/24；`test/chat` 1968/0（`chat_top_boundary_test` 全绿） | ✅ |
| 文档 | 本文件为权威；D 盘/飞书随 1.0.23 覆盖 | ✅ |

手机端环境与验证（本机）：
- 仓库 `/root/workspace/dsh-Go`（`/root/dsh-Go` 软链）；Flutter 3.47.7 linux-arm64（`/root/dev/flutter`）；Dart 3.13.5。
- `source /root/dev/dsh-env.sh` → `cd /root/dsh-Go/app`。
- `flutter pub get` 成功；`dart analyze --format machine` = 0 error / 0 warning / 23 info。
- `flutter test test/chat/turn_settle_test.dart` = 7/7；`message_actions_test` + `message_flow_test` = 28/28。
- `flutter test test/settings/index test/ui_config` = 203 通过 / 4 金色图像素漂移（0.00%–0.04%，Rule 31）/ 0 真实失败。
- 金色图不在手机端验收（Rule 31），未跑 `--update-goldens`。
- 覆盖安装：**已实测通过（2026-11-11 17:37 手机端）**。`11111558 → 11111711` 覆盖安装，证据：
  - 安装前 17:36:29 的两个应用内标记文件仍在（未被卸载清理）
  - `sessions` 目录 mtime 仍是 16:15、数量 1（旧数据保留）
  - 仓库 HEAD `0583f58` 未丢（应用自身的 Git 快照未重置）
  - `proot` 子进程已被系统重启但数据目录未重建（数据未被 app wipe）
  - APK 独立校验：sha256 `8a5ffc763a24ae49f8fb42428e22a42b2e12f36af99e7b02122c86ad6f563e9d` ✓、证书 `fb462eb1…` ✓、versionCode `11111711` ✓
  - 注：手机端无 `dumpsys` 权限读不到 `firstInstallTime`；但「数据目录未重建 + sessions 保留」已构成 Android 覆盖安装的等价证明（卸载重装 = 数据目录被删）。电脑侧 `adb shell dumpsys package io.github.ccch1mneyyy.dsh_app | grep -E "firstInstallTime|lastUpdateTime"` 可补证，需要 PC 连手机时跑一下。
  - 下一版：versionCode 必须 > `11111711`、证书不变。

---

## 四、从零重建（换新电脑时照做）

> 前提：D 盘可用、能访问 GitHub（不通就走 `https://gh-proxy.com/` 前缀）。

1. **装 WSL2 + Ubuntu 24.04**（导入到 D 盘）
   ```powershell
   # 以 cloud-images 的 noble rootfs 为例
   wsl --import Ubuntu24 D:\WSL\Ubuntu24 <ubuntu-noble-rootfs.tar.gz> --version 2
   ```
2. **换 apt 源为清华源，装基础依赖**：`build-essential curl git unzip zip python3 openjdk 依赖库…`（本项目实际把 JDK 单独放在 `/root/dev/jdk-17`，不用 apt 的 JDK）
3. **装 Flutter 3.47.7 到 `/root/dev/flutter`**，执行 `flutter --version` 让它自举
4. **装 Android SDK 到 `/root/dev/android-sdk`**：
   ```bash
   sdkmanager --sdk_root=/root/dev/android-sdk "platform-tools" "platforms;android-36" "build-tools;36.0.0" "ndk;28.2.13676358"
   ```
5. **拉源码**（GitHub 直连不通时用镜像前缀）：
   ```bash
   git clone https://gh-proxy.com/https://github.com/chuyang931914/dsh-Go.git /root/dsh-Go
   ```
6. **构建 runtime**（一次性产物，约 153MB，**已构建好，不要删**）：
   ```bash
   cd /root/dsh-Go/runtime
   ./build-runtime.local.sh          # 只用 arm64-v8a
   ```
   - 输出：`/root/dsh-Go/runtime/out/arm64-v8a/`（`r15-dsh0.2.2-rc.1`）
   - 该脚本已打过补丁：走 `https://gh-proxy.com/` 镜像、proot 固定 5.1.107.102
   - `runtime/locks/ubuntu-noble-arm64.json` 已用 `UPDATE_DEB_LOCK=1` 重新解析好，**不要随意再动**
7. **生成签名（仅新机器需要；已有 keystore 直接拷贝过来即可）**
   ```bash
   keytool -genkeypair -v -keystore /mnt/d/Android/keystore/dsh-go-release.jks \
     -alias dsh-go -keyalg RSA -keysize 2048 -validity 10000 \
     -storepass 40b0e359a11b9e6959d1aad77c65974d -keypass 40b0e359a11b9e6959d1aad77c65974d \
     -dname "CN=chuyang, OU=dev, O=dsh-go, L=CN, ST=CN, C=CN"
   ```
8. **配置 `app/android/key.properties`**（仓库里已有，换机器时确认路径）：
   ```properties
   storeFile=/mnt/d/Android/keystore/dsh-go-release.jks
   storePassword=40b0e359a11b9e6959d1aad77c65974d
   keyAlias=dsh-go
   keyPassword=40b0e359a11b9e6959d1aad77c65974d
   ```
9. **构建 APK**（见下一节）
10. **验签**（见第六节）

---

## 五、构建命令（日常出包）

```bash
wsl.exe -d Ubuntu24
cd /root/dsh-Go
source tooling/env.sh
DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64
```

- `DSH_BETA_TOKEN_FILE=` 置空：不注入 beta 渠道 token
- `-f arm64`：只出 arm64-v8a（现役手机都是 arm64；`all` 会同时出 x86_64/armeabi，构建更慢、包更大）
- 产物：`app/build/app/outputs/flutter-apk/app-arm64-release.apk`
- 首次构建较慢（Gradle 下载依赖 + runtime 打包），之后增量快
- 构建前若改了 Dart 代码，脚本会自动带上正确的 `--build-name/--build-number`

---

## 六、验签与装机

```bash
# WSL 内（build-tools 36.0.0）
/root/dev/android-sdk/build-tools/36.0.0/apksigner verify --print-certs \
  /mnt/d/Android/apk/dsh-go-1.0.15-mogai-arm64.apk
```

- 证书 DN：`CN=chuyang, OU=dev, O=dsh-go, L=CN, ST=CN, C=CN`
- 证书 SHA-256：`fb462eb107bea90a9a092ea4e280dbd003625df03a07dbf168cf26425aa03c2f`
- 证书 SHA-1：`28f20713a7bd9ca158a197282886cf5b291ebf63`
- **每次构建指纹必须一致**，不一致说明用错了 keystore
- 装机：直接 `adb install -r`，或手机文件管理器点击安装
- 覆盖安装失败常见原因：签名不一致（用错 keystore）/ 版本号低于已装版本

---

## 七及以后

魔改明细、Git 同步、版本策略、验收清单、隐私审计、双端约定已移到 [`docs/archive/HANDOFF-deep.md`](docs/archive/HANDOFF-deep.md)。
