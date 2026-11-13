# dsh-Go 魔改版 · 项目交接文档

> 用途：跨设备 / 跨账号 / 跨对话恢复本项目。任何人（或未来的我）拿到这份文档 + 两个仓库地址，就能从零把环境、签名、APK 全部重建出来。
> 最后更新：2026-11-13
> 权威副本：本文件同时放在仓库根目录 `HANDOFF.md`（随 Git 推送，跨设备可用）。
>
> **当前状态（2026-11-13 15:41）**：**1.0.25 已出包并验签**（`11131541`，208,013,822 字节，sha256 `7f4f28d3…75cd`，证书 `fb462eb1…3c2f`）。含：1.0.24 长消息跨页选字 + 思考展开保持；1.0.25 聊天页分层宠物（呼吸/随机小动作/真实闭眼眨眼）。电脑侧 `dart analyze` 0/0/24；`test/chat` **1969 通过 / 0 失败**。1.0.24 未出包，直接装 1.0.25。

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
| 魔改版 APK（本地） | `D:\Android\apk\dsh-go-1.0.15-mogai-arm64.apk` |
| **APK 下载（飞书云空间，优先）** | https://my.feishu.cn/file/RzcFbpFCyokpPqxVIq5cUI1QnuR （`dsh-go-1.0.25-11131541-mogai-arm64.apk`，当前 11131541；点开 → 右上角「...」→ 下载；飞书内直接下载，不走 GitHub/Gitee） |
| **源码包（飞书云空间）** | https://my.feishu.cn/file/IEqgbC77zoOqWmxo277cr8Wdnue （`dsh-go-1.0.15-mogai-src.zip`，500MB；已排除 `.git`、`app/build`、`.dart_tool`、`runtime/.work`、`runtime/.cache`，保留 `runtime/out` 可直接重建 APK） |
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

**构建 `11121309`（2026-11-12 13:09，1.0.21）**：`main` ← `phone` 快进（`f5306f9..c3bf654`，含 `197368c` 选字修复）；APK 206,211,961 字节，sha256 `e67678f34658c9bcf8cbc779203973b2967208d7ba5ab4a61788d66a9c75401d`，证书 `fb462eb1…3c2f`，versionCode `11121309` > `11120812`。电脑侧 `dart analyze` = 0 error / 0 warning / 24 info；`flutter test test/chat` = **1967 通过 / 0 失败**（含 message/image menu 4 张 golden 全通过）。手机端报告的 4 张 golden 红为字体像素漂移（Rule 31），**未重建金色基准**。APK 已存 `D:\Android\apk\dsh-go-1.0.21-11121309-mogai-arm64.apk`。

**构建 `11131541`（2026-11-13 15:41，1.0.25）**：`main` ← `phone` 快进到 `816408d`（含 1.0.24 长消息跨页选字 + 思考展开保持；1.0.25 聊天页分层宠物：呼吸/随机小动作/真实闭眼眨眼）。APK 208,013,822 字节，sha256 `7f4f28d3db4b39622156acfa0e54e3758f900778dbc55d860b4d6651668e75cd`，证书 `fb462eb1…3c2f`，versionCode `11131541` > `11121734`。电脑侧 `dart analyze` 0/0/24；`test/chat` **1969 通过 / 0 失败**（同步修正 `stream_motion_test` 旧断言：用户展开的思考在流结束后保持展开，对齐 1.0.24 新规则）。APK 已存 `D:\Android\apk\dsh-go-1.0.25-11131541-mogai-arm64.apk`；1.0.24 未出包。

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

### 3.5 四线一致性（2026-11-13 15:41，1.0.25 已构建待真机覆盖）

| 线 | 事实 | 状态 |
| --- | --- | --- |
| 仓库 | `main` = `phone`（`816408d`，1.0.25 分层宠物 + 1.0.24 长消息选字/思考保持） | ✅ |
| 代码 | 1.0.24：长消息跨页选字、思考展开保持；1.0.25：聊天页分层宠物（呼吸/随机小动作/真实闭眼眨眼） | ✅ |
| APK | `11131541`（1.0.25），208,013,822 字节，sha256 `7f4f28d3…75cd`，证书 `fb462eb1…3c2f` | ✅ |
| 实机 | 已装 1.0.21+11121309；**直接覆盖装 1.0.25+11131541**，跳过 1.0.24 | ⏳ 待装 |
| 测试 | `dart analyze` 0/0/24；`test/chat` 1969/0 | ✅ |
| 文档 | 本文件为权威；D 盘/飞书随 1.0.25 覆盖 | ✅ |

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

## 七、魔改明细（本次改动清单）

改动全部在 `/root/dsh-Go/app` 下；累计改动以 `git log` 为准，截至 commit `c0f5f39` 共 43 个文件（含测试与金色基准）。

### 1）剔除「发送匿名使用统计」

| 文件 | 改动 |
| --- | --- |
| `lib/usage/usage_stats.dart` | `build()` 不再调用 `_watch()`（删掉该方法及 `_engineMode`）；`_load()` 直接置 `enabled:false, noticed:true`，不读开关、不读落盘账本；清理不再使用的 import |
| `lib/usage/usage_net.dart` | `UsageBuild.active` 恒为 `false`（原为 `kReleaseMode \|\| ...`），从源头拦截所有统计上报入口；移除不再使用的 `flutter/foundation.dart` import |
| `lib/ui/onboarding/welcome_page.dart` | 首屏移除 `UsageNoticeRow()` 及 import（不再出现统计告知条） |
| 隐私页整体移除后，`UsageStatsSection` 随之不可达 | 文件已删除（死代码清理） |

效果：不上报、不计数、不落盘；`UsageBuild.active=false` 让所有 `count()/foreground()/send()` 入口在第一行就 return。

### 2）「模型 → 新对话默认」固定为「低」

| 文件 | 改动 |
| --- | --- |
| `lib/state/model_defaults_state.dart` | `defaultModelSelection()` 返回值里思考强度写死 `'low'`（不再读 `reasoningEffort` 字段） |
| `lib/ui/providers/new_chat_defaults_card.dart` | `_save()` 入口把传入的选择归一化为 `reasoningEffort: 'low'`，即使用户在模型面板选了别的档位，落盘也只会写「低」 |

效果：设置 → 模型 → 新对话默认，始终显示并保存为「低」，没有隐藏开关。

### 3）剔除「隐私与分享」及其内部功能

| 文件 | 改动 |
| --- | --- |
| `lib/ui/settings/settings_screen.dart` | 删除「通用」分组里的隐私入口 `SettingsTile` 与 `privacy_page.dart` import |
| `lib/ui/settings/index/spots.dart` | 删除 `Spots.shareConfig` / `Spots.usageStats` / `Spots.chatLogUpload` 三个定义（它们的 `page=privacy` 不在 `_pages` 中，若留在 `_rows` 会导致设置搜索遍历时 `pages[privacy]!` 空断言崩溃 → 灰屏）。`SettingsPageId.privacy` / `sharedLinks` 枚举值保留 |
| `lib/ui/share_hosted/hosted_links_tile.dart` | `SettingsTile` 的 `spot:` 从 `SettingsIndex.entry(SettingsPageId.sharedLinks)` 改为直接传 `title:`（`sharedLinks` 不在 `_pages` 中，`entry()` 会崩溃） |
| `lib/ui/features/feature_catalog.dart` | 移除「分享配置」功能项（`share-profile`），该入口原先通过「全部功能」页可达 `showShareProfileSheet`，与隐私页一起剔除 |

被一并"隐藏"的功能（页面文件仍在，但无入口）：
- 分享链接管理（`HostedLinksTile`）
- 分享配置（`showShareProfileSheet`）
- 本地 OCR 声明入口
- 聊天记录上传开关（`session-log-deepseek`）

已物理删除的死代码文件：`privacy_page.dart`、`usage_stats_section.dart`、`usage_notice_row.dart`（无入口、无引用）。

> `SettingsPageId.privacy` / `sharedLinks` 枚举值保留，但不在 `_pages` 中，任何调用 `SettingsIndex.page(privacy/sharedLinks)` 或 `SettingsIndex.entry()` 的代码都会崩溃。新增代码时务必避开。

### 4）剔除自动更新

| 文件 | 改动 |
| --- | --- |
| `lib/state/update_state.dart` | `autoCheck` 恒为 `false`（不再读 prefs）；`autoCheckIfDue()` 直接 `return false`，启动时不做任何检查 |
| `lib/ui/settings/about_page.dart` | 移除 `AppUpdateTiles()`（关于页不再有"检查更新/下载"入口） |
| `lib/ui/settings/settings_screen.dart` | 关于入口不再显示 `UpdateBadge`，只显示当前版本号 |
| `app/android/app/src/main/AndroidManifest.xml` | 删除 `REQUEST_INSTALL_PACKAGES` 权限（不再具备安装 APK 的能力） |
| `lib/ui/chat/chat_list.dart` | 移除 `CLIENT_UPGRADE_REQUIRED` 错误时的「检查更新」入口（无安装权限，该入口无用）；移除 `update_sheet.dart` import |

效果：不自动检查、不提示、不下载、不能安装更新；关于页只剩版本号。

### 5）聊天界面模型选择器归位（仅打字时在输入框底部显示）

| 文件 | 改动 |
| --- | --- |
| `lib/ui/chat/chat_screen.dart` | 窄屏下 `ChatHeader.trailing` 恒为 `null`（不再在顶栏右上角显示 `ModelChip`）；宽屏保持顶栏显示。模型切换由输入框底部的 `ComposerModelPill` 承接，且仅在打字（键盘弹出）时可见 |

效果：窄屏顶栏干净；模型胶囊回到输入框底部，点击输入框打字时出现，与官方 DeepSeek 位置一致；默认思考强度仍为「低」。

### 6）逆向自查修复记录（2026-11-10）

对 v1.0.15 基线 + 前序魔改做了全项目逆向细查，发现并修复以下问题：

| # | 问题 | 根因 | 修复 |
| --- | --- | --- | --- |
| 1 | 匿名统计仍在上报 | `UsageBuild.active` 未改，仍是 `kReleaseMode \|\| ...`，release 构建中为 `true` | `lib/usage/usage_net.dart`：`UsageBuild.active = false` |
| 2 | 设置页搜索灰屏 | `Spots.shareConfig/usageStats/chatLogUpload` 的 `page=privacy` 不在 `_pages` 中，搜索遍历到 `pages[privacy]!` 空断言崩溃 | `spots.dart`：删除这三个 Spots 定义（连同未引用的 `AppIcons.shareConfig`） |
| 3 | `HostedLinksSettingsTile` 潜在崩溃 | `SettingsTile(spot: SettingsIndex.entry(sharedLinks))`，`sharedLinks` 不在 `_pages` | `hosted_links_tile.dart`：改用 `title:` |
| 4 | 分享配置仍可达 | `showShareProfileSheet` 通过「全部功能」页的 `share-profile` 项可达 | `feature_catalog.dart`：移除该项 |
| 5 | 引擎要求升级时仍有「检查更新」入口 | `chat_list.dart` 在 `CLIENT_UPGRADE_REQUIRED` 时显示「检查更新」，但无安装权限 | `chat_list.dart`：改为 `return null`（不显示操作按钮） |

自查结论：
- 4 项魔改目标均已正确落地（统计禁用、默认低、隐私剔除、自动更新剔除）
- 死代码文件已删除：`privacy_page.dart`、`usage_stats_section.dart`、`usage_notice_row.dart`（含对应测试清理）
- 死代码定义已删除：`Spots.shareConfig/usageStats/chatLogUpload`（`page=privacy` 不在 `_pages` 中，保留有崩溃风险）、`AppIcons.shareConfig`（无引用）
- 关联清理：`usage_upgrade_notice.dart` 移除 `openSpot(Spots.usageStats)` 调用及未使用 import；`settings_search_test.dart` 移除「统计」搜索用例
- 全项目 `dart analyze` 无 error/warning（仅 23 个上游弃用 info）
- 构建验证通过（11102314）：签名 `fb462eb1…`，无 `REQUEST_INSTALL_PACKAGES` 权限，APK 206MB

### 7）失效测试同步（2026-11-10）

魔改把功能整体关掉后，若干上游测试的前提不再成立，已同步改写（**不是**代码回归）：

| 测试文件 | 原断言 | 处理 |
| --- | --- | --- |
| `test/settings/index/index_sync_test.dart`「关于 DSH Go」 | 期望关于页有 `update-check`/`update-auto` 两行 | 方案 A 后这两个 Spot 已从 `_rows` 删除，用例恢复为普通校验，无需 `absent` |
| `test/usage/usage_upgrade_notice_test.dart` | 期望「新增匿名使用统计」告知条出现、可点「了解」跳隐私页、8 秒后自动消失等 10 个用例 + 2 张金色基准图 | 整份改写为「告知条永不出现」：①统计关着时不出现、不计数、不落盘、不发请求；②首启（未连接）同样不出现。删除 `goldens/usage_notice_{light,dark}.png` |
| `test/chat/notice_action_test.dart`「本机引擎需升级 → 检查更新」 | 期望本机 `CLIENT_UPGRADE_REQUIRED` 时有「检查更新」按钮，点击触发一次检查 | 改为断言**没有**动作按钮、`checks == 0`（`chat_list.dart` 魔改已返回 `null`）；远端主机「换模型」用例不变 |
| `test/update/update_golden_test.dart` | 以 `AppUpdateTiles` 为唯一入口，含「关于」分组金色基准、手工检查、自动检查开关等用例 | 改为用一个「打开更新面板」按钮直接 `showUpdateSheet`，仅保留更新面板与启动检查的行为用例；删除 10 张 update 金色图 |

验证：上述文件 + 设置页金色基准合计全部通过；重新生成 `settings/goldens/{about,settings_hub_full}_{light,dark}.png`（关于页少了自动更新两行）。

### 8）死链清理（方案 A，2026-11-10）

问题：自动更新剔除后，设置搜索仍能搜到「检查更新」「自动更新」，点进去的「关于」页却没有这两行（死链）。

| 文件 | 改动 |
| --- | --- |
| `app/lib/ui/settings/index/spots.dart` | 删除 `Spots.updateCheck` / `Spots.updateAuto` 定义，并从 `_rows` 移除两个条目（搜索不再返回） |
| `app/lib/ui/update/update_tiles.dart` | **删除**（`AppUpdateTiles` 已无任何产品入口） |
| `app/lib/ui/theme/app_icons.dart` | 删除仅被 `AppUpdateTiles` 使用的 `checkUpdate` / `autoUpdate` 图标常量 |
| `app/test/update/update_golden_test.dart` | 见上表；同时删除 `app/test/update/goldens/` 下 10 张 update 金色图 |
| `app/test/settings/goldens/about_*.png`、`settings_hub_full_*.png` | 重新生成（关于页不再有自动更新两行） |

保留：`update_sheet.dart`、`update_launch_check.dart`、`update_state.dart` 仍在（`home_shell.dart` 挂着启动检查，`appUpdateProvider` 仍为版本号来源）；本次不删，避免牵连 shell。

构建验证（11102334）：签名 `fb462eb1…`，无 `REQUEST_INSTALL_PACKAGES`，APK 206MB。

构建验证（11110113，2026-11-11）：签名 `fb462eb1…`（与上一版一致，可覆盖升级），无 `REQUEST_INSTALL_PACKAGES`，APK 206.2MB，sha256 `4c616d47873d96e1821263f5d527db4fdcd69c59c0662866725fe06493fc087e`。

### 9）上游既有问题（非本项目改动引入，不修）

全仓 `dart analyze`（在 `/root/dsh-Go` 根目录跑）会报 1 万多条，绝大部分来自**上游随仓库带来、但不在任何构建路径上**的独立包脚本，与本项目构建/发版无关：

| 位置 | 问题 | 说明 |
| --- | --- | --- |
| `packages/dsh_client/benchmark/transcript_5000.dart` | `uri_does_not_exist` / `undefined_class` 等（约 10 条） | 上游基准脚本，未把 `dsh_client` 声明为自己的依赖，独立分析必然报错；不属于 `app/` 构建图 |
| `packages/dsh_client/bin/probe.dart` | 同上（约 9 条） | 上游调试脚本，同样缺依赖声明 |
| `app/` 目录内 23 条 `deprecated_member_use`（info 级） | Riverpod `Ref.exists` → 改用 `provider.exist` | 上游写法，仅 info，不影响编译与运行；发版前不做批量改写，避免引入风险 |

因此验收口径固定为 **`cd app && dart analyze`**（结果：23 info、0 error、0 warning），不要用仓库根目录的数字判断是否"有编译错误"。

#### 9.1 既有测试红灯（基线 `ee2ff5b` 上就已存在；2026-11-11 已修复）

在 `ee2ff5b` 上建 worktree 跑同批测试，结果与当前一致 → 确认非本轮引入。2026-11-11 按方案 A 一并修掉：

| 测试 | 现象 | 根因 | 修复 |
| --- | --- | --- | --- |
| `test/settings/index/guide_nav_test.dart`（zh + en） | 期望存在 `设置 › 手机操控 › Android Shell`，索引里没有 | 指南把 Android Shell 写成「手机操控」下的三级行，但索引里没有这一行（页面只从手机操控页的 `android-shell-entry` 行进入） | 指南改为二级路径 + 正文点名 **Android Shell**，不再冒充索引行；zh/en `04-phone-control.md` 同步改，`python3 app/tool/guide_sync.py` 重新生成技能资源 |
| `test/settings/index/spots_test.dart`「every page is registered once and walks back to the hub」 | `pages` 与 `SettingsPageId.values` 不等：缺 `privacy`、`about`，多 `sharedLinks` | 前序魔改只删页面/入口，没删枚举值；`sharedLinks` 反过来只剩枚举与映射 | 物理删除 `privacy`、`about`、`sharedLinks` 三个枚举值及 `settings_pages.dart` 对应 `case`/import；详见第 11 节 |

`guide_sync.py` 同时暴露 4 条死链（`dshgo://open/shared-links`、`dshgo://open/usage-stats`，zh/en 各一），已在同轮改成分享面板路径 / 「本版本不发送统计」文案。

#### 9.2 全量 `flutter test` 基线（**历史基线，已清零 2026-11-11**）

全量结果：**+10661 通过 / ~387 跳过 / -99 失败**，分布在 26 个文件。已在改动前的 `fe029ba` 建 worktree 做 A/B：`app_icons`、`page_links`、`integration/wiring`、`features/feature_logic` 四个可疑文件在基线同样失败 → 与本次 l10n 清理无关。

> ✅ **新基线（2026-11-11，五批清账后）**：全量 `flutter test` = **+10845 通过 / ~288 跳过（金色图） / 0 失败**；回归面 `test/settings test/star test/ui_config` = **+473 通过 / 0 跳过 / 0 失败**（原 443/30/0，`check_mjs_parity` 30 个用例从 skip → pass，因装了 Linux 原生 Node v24.22.2）。`dart analyze --format machine | grep -c '^ERROR'` = 0。

失败归类（按文件）：

| 类别 | 文件（失败数） | 原因 |
| --- | --- | --- |
| 匿名统计 | `usage_stats_test`(14)、`usage_ui_test`(10)、`usage_e2e_test`(2) | 魔改 `UsageBuild.active=false`，上报逻辑不执行，测试仍按"会发送"断言 |
| 自动更新 | `update_state_test`(3)、`beta_channel_test`(1) | 自动更新已整体剔除 |
| 金色图 | `shell`(10)、`onboarding/parallel_setup`(6)、`local_chat`(4)、`providers`(4)、`chat_golden`(3)、`share_landed`(2)、`drawer`(2)、`wallpaper`(2)、`account`(2) 等 | 魔改 UI 与测试机 CJK 字重（Light）差异，需按文件 `--update-goldens` 重建基线才能绿 |
| 默认模型 | `new_chat_defaults_test`(7)、`new_chat_options_test`(1) | 魔改「新对话默认低」未同步测试期望 |
| 其他 | `chat_features`(5)、`empty_actions`(6)、`seats_pages`(4)、`page_links`(1)、`app_icons`(1)、`feature_logic`(1)、`phone_floating_bar`(1)、`plugin_view_styles_parity`(1)、`model_sheet`(2) | 上游 IA/图标/指南 ID 漂移，基线同样红 |

**验收口径（更新 2026-11-11）**：`test/settings test/star test/ui_config` = **473 通过 / 0 跳过 / 0 失败**；全量 `flutter test` = **10845 通过 / ~288 跳过（金色图） / 0 失败**。

#### 9.3 全量 99 红清账：接手即办（方案已确认 2026-11-11）

> **状态：方案已确认，接手人无需再次沟通，按下面批次直接执行、独立提交。**
> 目标：把 `flutter test` 拉回「0 失败」的可信基线，结束「每次改动都要人工分辨真假红」的状态。

**0. 每批都要做的固定动作**

```bash
wsl -d Ubuntu24
cd /root/dsh-Go/app && source ../tooling/env.sh
```

- 测试一律重定向日志再轮询：`flutter test test/usage > /tmp/b1.log 2>&1`，另开终端 `tail -20 /tmp/b1.log`。**禁止** `flutter test ... | tail -n`——管道会缓冲到进程结束，看起来像"没有任何输出"（Rule 24）。
- 任一命令 3 分钟无新输出，立刻同步「在等什么 / 等了多久 / 推进还是卡住 + 证据（CPU 时间、子进程、日志尾行）」（Rule 23，最高优先级）。
- 每批独立 commit；提交前 `dart analyze --format machine | grep -c '^ERROR'` 必须为 `0`，不要用 `tail` 看结尾。
- 红线：不得用 `skip` 掩盖真实回归、不得把断言放宽成 `expect(true, true)`、不得手改金色图 PNG、不得顺手改产品代码。

**1. 批次 1：匿名统计（26 条）**

| 文件 | 失败数 | 改法 |
| --- | --- | --- |
| `app/test/usage/usage_stats_test.dart` | 14 | 断言改为魔改后的真实行为：`UsageBuild.active=false`（`app/lib/usage/usage_net.dart:36`）时不采集、不落盘、不发送；删除"会发送"类断言 |
| `app/test/usage/usage_ui_test.dart` | 10 | 保留 UI 呈现类断言（`usageStatsTitle` 仍被引用，**不要删这个键**），只改"上报被执行"相关断言 |
| `app/test/usage/usage_e2e_test.dart` | 2 | 端到端链路改为"全程无网络请求"，可断言 `usage_stats.dart` 的发送入口未被调用 |

验证：`flutter test test/usage` → 0 失败。写死"默认关断"是产品决策，测试要锁住它，防止将来误开。

**2. 批次 2：自动更新（4 条）**

| 文件 | 失败数 | 改法 |
| --- | --- | --- |
| `app/test/update/update_state_test.dart` | 3 | 自动更新已整体剔除（`app/lib/state/update_state.dart`、`app/lib/ui/update/update_launch_check.dart` 中 `autoCheckIfDue()` 恒 `false`）→ 删除"会检查更新"用例，改写为「入口不存在 / 恒 false」断言 |
| `app/test/update/beta_channel_test.dart` | 1 | 同上，删 beta 触发检查的期望 |

验证：`flutter test test/update` → 0 失败。删用例前先 `grep -rn <符号> app/lib` 确认代码侧无残留引用。

**3. 批次 3：新对话默认模型（8 条）**

| 文件 | 失败数 | 改法 |
| --- | --- | --- |
| `app/test/engine_settings/new_chat_defaults_test.dart` | 7 | 期望值改为「低」档（魔改固定），并补一条「用户手动选择可覆盖默认」用例 |
| `app/test/chat/new_chat_options_test.dart` | 1 | 同上 |

验证：`flutter test test/engine_settings test/chat/new_chat_options_test.dart` → 0 失败。

**4. 批次 4：金色图（约 35 条）**

| 文件 | 失败数 |
| --- | --- |
| `app/test/shell/shell_golden_test.dart` | 10 |
| `app/test/onboarding/parallel_setup_golden_test.dart` | 6 |
| `app/test/onboarding/local_chat_golden_test.dart` | 4 |
| `app/test/providers/providers_golden_test.dart` | 4 |
| `app/test/chat/chat_golden_test.dart` | 3 |
| `app/test/system_entry/share_landed_golden_test.dart` | 2 |
| `app/test/drawer/drawer_golden_test.dart` | 2 |
| `app/test/account/account_golden_test.dart` | 2 |
| wallpaper 相关（`test/settings/wallpaper_section_test.dart` 或 `test/wallpaper/*`，以日志为准） | 2 |

改法：
1. 先 `flutter test <file>` 看 diff 是否只来自魔改 UI + 测试机 CJK Light 字重，确认无真实布局回归；
2. `flutter test --update-goldens <file>` 重建；
3. `git diff --stat` 确认只改了对应 PNG，再提交。

注意：金色图基线**依赖机器与字体**，换机、换字体、升级 Flutter 都要重跑；禁止手改 PNG。

**5. 批次 5：零散（约 26 条）**

| 文件 | 失败数 | 性质 |
| --- | --- | --- |
| `app/test/chat/empty_actions_test.dart` | 6 | IA/入口漂移 |
| `app/test/chat/chat_features_test.dart` | 5 | 功能开关漂移 |
| `app/test/plugins/seats/seats_pages_test.dart` | 4 | 页面/文案漂移 |
| `app/test/chat/model_sheet_test.dart` | 2 | 模型选择器归位后的期望漂移 |
| `app/test/links/page_links_test.dart` | 1 | 死链清理后的期望 |
| `app/test/icons/app_icons_test.dart` | 1 | 图标漂移 |
| `app/test/features/feature_logic_test.dart` | 1 | 上游逻辑漂移 |
| `app/test/phone/phone_floating_bar_test.dart` | 1 | UI 漂移 |
| `app/test/plugins/view/plugin_view_styles_parity_test.dart` | 1 | 上游样式漂移 |
| 其余零散项（约 4 条，以运行日志为准） | — | — |

改法：逐个定位是「IA/图标/指南 ID 漂移」还是「真实回归」——漂移就更新测试或同步 `app/tool/guide_sync.py` 资源；**判定为真实回归时先停手**，把现象写进本文件并同步用户，不要为了转绿改产品代码。以上均已在 `fe029ba` 基线复现，属历史遗留。

**6. 验收与收尾**

```bash
flutter test test/settings test/star test/ui_config   # 必须 473 通过 / 0 跳过 / 0 失败（原 443/30/0）
flutter test > /tmp/full_test.log 2>&1                # 全量，目标 0 失败
```

1. 每批完成后跑该批文件 + 上面第一行回归命令，确认无新增红；
2. 连续两批无新增红再进下一批；
3. 全量归零后：把 9.2 标注「历史基线」，写入新数字与日期；更新第十二节第 5 条；
4. 收尾时同步 `D:\HANDOFF.md` 与飞书云空间（token `OJSGbqo2IofCYQxm8uycjTGAn7d`），并推送 Gitee `main`（GitHub 由镜像自动同步，见 8.2）。

**接手核对清单**

- [x] 批次 1 `test/usage` 0 失败，已提交（`a2889e5`）
- [x] 批次 2 `test/update` 0 失败，已提交（`a991554`）
- [x] 批次 3 `new_chat_defaults` + `new_chat_options` 0 失败，已提交（`bb8c855`）
- [x] 批次 4 九个 golden 文件重建，diff 仅 PNG，已提交（`e9b58cf`）
- [x] 批次 5 零散项清零，真回归已记录并上报（`886e699`）
- [x] `test/settings test/star test/ui_config` 473 / 0 / 0（原 443/30/0，check_mjs_parity 30 用例从 skip 变 pass）
- [x] 全量 `flutter test` 0 失败（10845 passed / 288 skipped / 0 failed），9.2 已改写为历史基线
- [x] 代码已推 Gitee `main`；GitHub 自 2026-11-11 起由 Gitee Push 镜像自动同步（默认分支 `main`，`mogai` 已删除）
- [ ] `D:\HANDOFF.md` 覆盖 + 飞书云空间覆盖上传（token `OJSGbqo2IofCYQxm8uycjTGAn7d`，电脑侧执行）。2026-11-11 14:xx 曾完成 60,516 字节版（飞书 version `7706799604033768711`）；16:04/16:12 文档又更新，**当前仓库版本已大于该字节数，需重做**

### 10）关闭「关于 DSH Go」入口（2026-11-11）

需求：设置页「帮助与关于」只保留帮助，关闭关于页入口。

| 文件 | 改动 |
| --- | --- |
| `lib/ui/settings/settings_screen.dart` | 删除「关于 DSH Go」`SettingsTile`；移除不再使用的 `appUpdateProvider` 读取及 `about_page.dart` / `update_state.dart` import；分组注释改为「帮助」 |
| `lib/ui/settings/index/spots.dart` | 删除 `SettingsPageMeta(SettingsPageId.about, ...)`；`_rows` 移除 `Spots.version` / `Spots.star` / `Spots.licenses`（搜索不再出现关于页条目） |
| `lib/l10n/parts/hub_zh.arb` / `hub_en.arb` | `hubGroupHelp`：`帮助与关于` → `帮助`；`Help and about` → `Help`；用 `python3 tool/l10n_merge.py` 重新生成 |
| `test/settings/index/index_sync_test.dart` | 删除「关于 DSH Go」索引同步用例与 `about_page` import |
| `test/settings/settings_hub_geometry_test.dart` | 分组标题断言改为 `帮助` |
| `test/settings/goldens/settings_hub_full_{light,dark}.png` | 重新生成（少一个 tile、组名变化） |

~~保留：`AboutPage` 仍在 `settings_pages.dart` 的 `_pages` 中（满足 Rules 15，避免空断言崩溃），但已无任何入口；`Spots.version/star/licenses` 定义保留（`AboutPage` 内部仍引用）。~~ **2026-11-11 更新：`AboutPage`、`Spots.version/star/licenses` 与 `SettingsPageId.about` 已全部物理删除，见第 11 节。**

效果：设置页与设置搜索都不再出现「关于 DSH Go」；版本号不再在设置页展示。

补充（同日回归）：整目录 `flutter test test/settings` 跑出 4 项红灯，其中 **1 项是本轮引入的**——`open_target_test` 报 `share-profile` 无法解析（ui.json 目标仍声明分享配置页）。修法：

| 文件 | 改动 |
| --- | --- |
| `lib/ui_config/ui_config_schema.dart` | `UiSchema.pages` 删除 `'share-profile'` |
| `assets/skills/dsh-go-ui/schema.json` | `page` 枚举同步删除 `share-profile`（否则 `schema_sync_test` 报 drift） |

验证：`flutter test test/ui_config` 143 项全过（30 张金色跳过），`test/settings/index/open_target_test.dart` 2 项全过。

### 11）物理删除「关于」「隐私」与 `sharedLinks` 残留（方案 A，2026-11-11）

目标：让 `flutter test test/settings` 全绿，同时不保留死页面、死枚举、死索引。

| 文件 | 改动 |
| --- | --- |
| `app/lib/ui/settings/about_page.dart` | **删除** |
| `app/lib/ui/settings/index/spots.dart` | 枚举删除 `privacy` / `about` / `sharedLinks`；删除 `Spots.version` / `Spots.star` / `Spots.licenses` |
| `app/lib/ui/settings/index/settings_pages.dart` | 删除 `about_page.dart` / `hosted_links_page.dart` import 与三个 `case` |
| `app/test/settings/about_page_test.dart` | **删除** |
| `app/test/settings/goldens/{about,privacy}_{light,dark}.png` | **删除**（`privacy` 两张早已无测试引用） |
| `app/test/settings/settings_ia_golden_test.dart` | 去掉 about 用例与 import，注释同步 |
| `app/test/settings/index/index_sync_test.dart` | 删除 `about` 的 `_unlisted` 条目与 `AppInfo` import |
| `app/test/star/star_prompt_test.dart` | 删除「设置 › 关于 DSH Go」用例及 `about_page`/`settings_widgets`/`phone/support` import |
| `app/lib/l10n/parts/{hub,search,star}_{zh,en}.arb` | 删除仅被关于页/相关 Spot 使用的 11 个键：`hubAbout*` 6 个、`searchKwVersion`/`Star`/`Licenses`、`starSettingsTitle`、`hubSettingsLicenses`；`python3 tool/l10n_merge.py` + `flutter gen-l10n` 重新生成 |
| `docs/guide/{zh,en}/{04-phone-control,07-sharing,11-faq}.md` 及 `app/assets/skills/dsh-go-guide/*` | 修 Android Shell 路径漂移；分享链接改走分享面板；匿名统计改为「本版本不发送」；`python3 app/tool/guide_sync.py` 生成技能资源 |

代价：设置里不再有「开源许可」入口（用户已确认接受）。

验证：
- `cd app && dart analyze`：0 error / 0 warning（仅上游 23 条 `exists` deprecation info）
- `flutter test test/settings test/star test/ui_config`：443 passed / 30 skipped / 0 failed
- `python3 app/tool/guide_sync.py`：26 files checked and built，无错误

残留（非本轮范围）：`docs/design/settings-ia.md` 的 S4/S7 与 `docs/design/star-prompt.md` 实现表仍按历史记录提到 `about_page.dart`（历史设计稿，不改）。

**l10n 遗留键已于 2026-11-11 清理**：全仓扫描确认 **86 个键**无任何代码/文档引用，已从 `lib/l10n/parts/*_{en,zh}.arb`（30 个文件）删除，`l10n_merge` + `gen-l10n` 后 6201→6115 键。主要构成：`catalog*` 26（整组未接线）、`update*` 11（自动更新魔改残留）、`searchKw*` 9（已删页面的搜索词）、`chatVoice*` 6、`plugslotsIssue*` 6、`bots*` 5、`activity*` 3、`hubPrivacy`/`hubPrivacySharing`/`hubSettingsAbout` 等。**`commonMonthDay` 一度被误删**（扫描排除了整个 `lib/l10n`，漏掉手写 `l10n.dart` 的调用），已恢复并重新生成；教训见 Rules 24/25。注意 `usageStatsTitle` 仍被 `test/usage/usage_ui_test.dart` 使用，**未删**；匿名统计 UI/测试仍在，仅构建期 `UsageBuild.active=false` 关闭发送，彻底移除需另行评估。



### 12）聊天正文长按直接选择（2026-11-11）

需求：聊天页选择文字原先必须「长按 → 菜单 → 选择文字 → 弹出全选面板」，多一步跳转；改为像系统聊天一样，长按正文直接进入选择。

| 文件 | 改动 |
| --- | --- |
| `app/lib/ui/chat/widgets/assistant_message.dart` | 非流式回复 `MarkdownBody(selectable: !streaming)`——长按正文直接起选择手柄与系统工具栏（复制/全选）；菜单去掉「选择文字」项；没有操作行的中间回复补一个右下角 ⋯ 入口打开菜单 |
| `app/test/chat/message_actions_test.dart` | 菜单用例改为点 ⋯ 打开；新增「长按正文进入选字、不弹菜单」用例 |
| `app/test/chat/message_flow_test.dart` | 引用/重新回答等用例改走 ⋯；菜单项列表去掉「选择文字」 |

效果：长按回复正文 → 直接选字 → 工具栏复制，不再跳弹层；消息菜单（复制/引用/分享/重新回答/分叉）走 ⋯（一轮最后一条本来就有 ⋯；中间回复新增 ⋯）。

未改：用户消息（`UserBubble`）仍走菜单里的「选择文字」弹层；如需一致再单独处理。

验证（手机端）：`dart analyze` = 0 error / 0 warning / 23 info；`flutter test test/chat` 除金色图（跨机字体漂移，Rule 31）外 0 失败。**电脑侧需重生成受影响的聊天金色图**（新增 ⋯ 行可能影响 `chat_components`/`conversation` 等基准）。

### 13）选区菜单裁剪 + 问AI + 宠物关闭 + 边缘手势（2026-11-11，1.0.17 · `11111915` 已构建）

- **长按选区菜单**：正文的 `SelectionArea` 改用自定义 `contextMenuBuilder`（`widgets/selection_actions.dart`）。顶层只留 `复制`、`全选`、`翻译`，「⋯」里是 `分享`、`朗读`、`问AI`；AI搜索、爱奇艺、浏览器搜索、快速搜索、搜视频、重复翻译、问问 DeepSeek 不再出现。
- **翻译**：走 Android `ACTION_PROCESS_TEXT`（原生 `selection/SelectionPlugin.kt`，channel `dsh/selection`），优先命中名称带 translate 的处理器（本机是 vivo 翻译），没有就给系统选择器；不新增模型调用。
- **问AI**：把选中文字填进输入框并聚焦，不自动发送（只读对话不显示这一项）。
- **朗读**：手机系统 TTS；**分享**：系统分享面板。
- **聊天页宠物**：`PetStage(showPet: false)`，聊天页不再画宠物；悬浮窗/设置里的宠物保留（`pet_stage.dart` 新增可选 `showPet`）。
- **左右滑动**：聊天页中间不再触发抽屉/快捷面板；只保留左右内容边缘 24dp 起手（`drawer_drag.dart` 新增 `acceptAt`，`home_shell.dart` 按 `MediaQuery` padding 计算边界）。快捷面板测试已改为边缘起手；中间滑动断言为「不打开」。
- **验证**：`dart analyze` = 0 error / 0 warning / 23 info；`message_actions + message_flow + turn_settle + quick_panel` = 74/74；`message_actions` 新增自定义工具栏与「问AI填入」用例。Kotlin 原生通道需电脑侧构建验证；**OEM 系统菜单能否完全压住需真机验证**。
- 版本：`app/pubspec.yaml` = `1.0.17+1`；指南同步 1.0.17。
- **真机反馈（2026-11-11 21:xx，已装 11111915）**：① 翻译跳到了 vivo 浏览器（`com.vivo.browser/.TranslateActivity`），不是 vivo 翻译本体；② 朗读语速太快；③ 菜单裁剪/问AI/宠物关闭/边缘手势未报问题。
- **1.0.18 修复**：`SelectionPlugin.kt` 按包名优先 `com.vivo.translator`，其次任意 translator 包，最后才认名称带 translate 的非浏览器处理器；朗读改为 `rate: 0.8, pitch: 1.0`（`CompanionVoice.speak` 支持按次覆盖）；版本 `1.0.18+1`。
- **1.0.18 构建（2026-11-11 21:42）**：APK `dsh-go-1.0.18-11112142-mogai-arm64.apk`，`versionCode 11112142`（> `11111915`）、`versionName 1.0.18`，证书 `fb462eb1…3c2f`，sha256 `52f0cdc0fe9f99635b2c4608dde663a0809892845bc8735bb81f1314b997b770`；`classes.dex` 含 `com.vivo.translator`，`dsh/selection` 通道仍在。`dart analyze` 0 error；`test/chat + test/companion` 2295 通过 0 失败。**待真机只复验翻译与朗读两项。**
- **电脑侧构建（2026-11-11 19:15）**：`main` ← phone `92a0283` 快进合并；`flutter build apk` / Gradle `assembleArm64Release` 成功 → `SelectionPlugin.kt` 与 `MainActivity.kt` 注册均编译通过；APK `dsh-go-1.0.17-11111915-mogai-arm64.apk`，206.2MB，`versionCode 11111915`（> `11111751`）、`versionName 1.0.17`，证书 `fb462eb1…3c2f`，无 `REQUEST_INSTALL_PACKAGES`，sha256 `3246493b4e54058a35a92e7552613562d3e7d5e892420156388b034d7782fd97`；`classes.dex` 内含 `dsh/selection` 通道字符串（证明插件已打包）。
- **测试**：`test/chat` 2152 通过（0 失败）；`test/shell` 仅 `quick_panel_golden_test` 6 张红——原测试从屏幕中间（`width*0.75`）起手，被新 `acceptAt` 边缘限制拦下，面板没打开；改 `_pullPanel` 从右边缘 `width-1` 起手后 10/10 通过，**未改任何 PNG、未改产品代码**（`bdee58a`）。
- **待真机**：vivo 翻译能否被 `ACTION_PROCESS_TEXT` 直接命中（找不到会落系统选择器）；长按菜单是否只剩 复制/全选/翻译/⋯；问AI 填入不发送；聊天页宠物消失；中间横滑无反应、边缘 24dp 可拉。
- **1.0.18 真机验收（2026-11-11 23:1x）**：`11111915 → 11112142` 覆盖安装成功，数据保留；翻译直接进 **vivo 翻译**（不再跳浏览器），朗读 0.8× 正常；菜单/问AI/宠物/边缘手势维持通过。**1.0.18 收口。**

### 14）1.0.19/1.0.20：消息时间戳 + 边缘手势（2026-11-12）

- **时间戳**：每条用户/助手消息气泡外侧下方一行小灰字；默认精简：今天 `HH:mm`、昨天 `昨天 HH:mm`、更早 `11月9日 HH:mm`；日期只在每天第一条出现。
- **完整格式**：点任意一条时间，整个当前聊天统一切换（周几 + 秒），再点收回；示例 `昨天 周一 23:42:53`、`11月9日 周一 23:42:53`，跨年带年份。
- **实现**：`widgets/message_time.dart`（格式化 + 点击组件）；`ChatList` 持有 `_timestampsExpanded`，按天计算 `showDate`；`UserBubble`/`AssistantMessage` 增加时间参数；待发送消息用 `PendingPrompt.time`，助手流式期间不显示。
- **边缘手势**：1.0.19 为 8–40dp，真机实测仍不灵敏；**1.0.20 改为 0–80dp**，中间仍不响应。最外 0–20dp 仍可能被系统返回手势拿走。
- **手机验证**：`dart analyze` 0 error / 0 warning / 23 info；`message_time_test` 5/5；`message_actions + message_time + turn_settle + quick_panel` 62/62。
- **电脑合并与金色图**：`main` 快进至 `3bf2914`；重建 44 张 chat/shell PNG。`quick_panel_golden_test` 起手从外侧 1dp 修正到有效带内 20dp；`run_info_golden_test` 删除“展开后仍读取回复屏幕坐标”的过期断言（内容增高后回复可离屏，保留展开方向与折叠回原位校验）。提交 `81bcd98`，**未改产品代码**。
- **电脑回归**：`dart analyze` 0 error / 0 warning / 24 info（新增一条为 `message_time.dart` 冗余 import，按本轮“不改产品代码”保留）；`test/chat + test/shell` **2184 通过 / 0 失败**。
- **构建**：`dsh-go-1.0.19-11120055-mogai-arm64.apk`，206,211,210 字节，versionCode `11120055` > `11112142`，证书 `fb462eb1…3c2f`，sha256 `0db5bb9a3c1f5f1da6a9de59350b795ac76981fcb633693f8bce82f25144ba4c`；已复制到 `D:\Android\apk\`。
- **分发/待真机**：2026-11-12 07:33 飞书授权恢复，APK 已覆盖原 file token（版本 `7707061086150757632`），HANDOFF 同步覆盖；链接不变。1.0.19 已装，时间戳待确认；8–40dp 边缘实测不灵敏。
- **1.0.20 已出包并分发**：边缘触发带改为 **0–80dp**（`home_shell.dart`），中间仍不响应；`pubspec 1.0.20`。电脑侧 `dart analyze` 0 error / 0 warning / 24 info，`test/shell` **217 全通过**（无需重建金色图）。APK `dsh-go-1.0.20-11120812-mogai-arm64.apk`，206,211,199 字节，versionCode `11120812` > `11120055`，证书 `fb462eb1…3c2f`，sha256 `817a30088e2c03083cbd6b7066d365a44727964f6667c750bfa8ed5fb6567d99`；已覆盖飞书原链接并发送私聊。装后只验 0–80dp 边缘起手与中间不响应。
- **1.0.20 真机验收（2026-11-12 08:3x）**：安装 `11120812` 成功、数据保留；0–80dp 边缘起手可稳定拉抽屉/快捷面板，中间横滑仍不响应；1.0.19 时间戳显示与全局切换也确认正常。**1.0.19/1.0.20 收口。**

### 15）1.0.21：自己消息的「选择文字」用新工具栏（2026-11-12，代码完成，待出包）

- **问题**：长按自己的消息 → 选择文字，弹出的 `_SelectTextSheet` 仍然用 `region.contextMenuButtonItems`，会带出 OEM/系统搜索、翻译等旧菜单；助手正文早已换新。
- **修法**：`showSelectTextSheet` 增加 `SelectionActions?`；`_SelectTextSheet` 改用 `SelectionToolbar`（复制/全选/翻译/⋯），并删掉旧的「引用」插入项；`UserBubble` 从 `ChatList` 拿到选区动作后传入。
- **验证**：`dart analyze` 0 error / 0 warning / 23 info；`message_actions + message_time + message_menu` 22 非金色用例通过；`message_menu` 4 张旧菜单 golden 变红是手机字重/菜单布局，待电脑确认/重建。
- **真机验收（2026-11-12 13:4x）**：安装 `1.0.21+11121309` 成功、数据保留；长按自己消息→选择文字只剩复制/全选/翻译/⋯，无「引用」；「编辑后重发」仍在消息菜单。**1.0.21 收口。**

### 16）AI 费用插件 local-ai-cost（2026-11-12，已安装并运行）

- **位置**：`$DSH_HOME/dsh-go/plugins/local-ai-cost`；`dsh plugin --profile web add` 安装；原生插件，不需要改 App/出包。
- **源码入库**：2026-11-12 起源码在仓库 `plugins/local-ai-cost/`（含 package.json/lock、lib、README、secrets.example）；`secrets.json` 和 `node_modules/` 由 `.gitignore` 排除。界面配置在 `config/ui.json`。
- **界面**：输入框上方 `composer.strip` 一行（火山本月 + DeepSeek 余额），点开 `panels` 的「AI 费用」；每 30 分钟自动刷新，面板可手动刷新。
- **入口**：`ui.json` 加 `hide: ["pluginCapsule"]`，隐藏聊天页 App 自带的「插件」聚合入口（红线那个）；插件费用条/面板仍在，面板可从费用条或「全部功能」进入。
- **DeepSeek**：`GET https://api.deepseek.com/user/balance`，显示可用余额；Key 由插件独立配置，不读 App 里的 Key。
- **火山**：官方 `@volcengine/openapi` 的 `billing.ListBillOverviewByProd`，查当前自然月账单（`BillPeriod` 走 query，不走 body）；需要子账号 **账单只读** AK/SK，不能用 Ark API Key。
- **凭据**：`$DSH_HOME/dsh-go/plugins/local-ai-cost/secrets.json`，权限 600；没有写进代码、清单、视图、聊天或仓库。临时导入文件已删除。
- **验证**：插件检查器 0 错误；用真实凭据跑通数据函数，DeepSeek 余额与火山本月账单均返回；界面待引擎重启后显示。
- **状态**：费用条/面板已在使用；密钥 600，临时文件已删除。账本里的每日上限/预留未调整（用户决定不动）。

### 17）1.0.22：自己消息直选 + 引用 + 翻译折叠（2026-11-12，代码完成，待出包）

- **自己消息**：已发送气泡长按直接 `SelectionArea` 选字；右下小「⋯」菜单：复制 / 选择文字 / 引用 / 编辑后重发。乐观气泡仍走长按菜单。
- **选字工具栏**：顶层复制 / 全选 / 引用 / ⋯；翻译移进 ⋯，与分享/朗读/问AI 同列；双方正文共用。
- **引用**：`SelectionActions.onQuote` 接 `ChatScreen._quote`，选中段落放进输入框上方引用；用户消息的「引用」引用整条。
- **验证**：`dart analyze` 0 error / 0 warning / 23 info；`message_actions` 12/12；`message_menu` 6 个非金色通过，4 张旧菜单 golden 为手机字体漂移（电脑侧 1.0.21 已全通过，待 1.0.22 复核）。
- **抽屉顺序修复**：`drawer_list.dart` 原先把 PinnedBlock 写死在 FolderBlock 前，`ui.json` 的 `drawer.groups` 解析了但没用；1.0.22 新增 `uiDrawerGroupsProvider`，按配置重排块（组内保持原顺序）。当前配置 `folders → pinned → today…`。
- **待电脑**：合并 phone → 跑 test/chat（确认 4 张 golden）→ 构建 1.0.22（versionCode > `11121309`）→ 装机验长按直选、引用、编辑后重发。

### 18）1.0.23：短历史顶部边界修复（2026-11-12，真机通过）

- **问题**：1.0.22 用户气泡右下「⋯」用了 `IconButton` 默认 28dp 最小点击区，比时间行高 17px；短历史拖到顶时 `chat_top_boundary_test` 首行 top 14.96，期望 32.0。
- **修法**：`IconButton` 改 20×16、`tapTargetSize: shrinkWrap`，行高回到时间行；顶部边界恢复。
- **验证**：`dart analyze` 0/0/23；`message_actions + chat_top_boundary` **22/22**。
- **真机验收（2026-11-12 17:57）**：安装 `1.0.23+11121734` 成功、数据保留；直选/引用/翻译折叠/抽屉顺序/顶部边界/插件入口隐藏均通过。**1.0.23 收口。**

### 19）1.0.24：长消息选字滚动 + 思考展开保持（2026-11-13，代码完成，待出包）

- **长消息选字**：`_SelectTextSheet` 原来 `SelectionArea` 在 `SingleChildScrollView` 里面，选区只认当前视口；改为 SelectionArea 包住 ScrollView，拖到页边会继续滚动。
- **思考展开**：`ThinkingPill` 新增 `_userExpanded`；用户亲手展开后，继续思考/流式结束不再自动收起；点正文或再点头部仍收起。
- **验证**：`dart analyze` 0/0/23；`thinking_collapse + message_menu + message_actions` 26 个非金色通过；4 张 menu golden 为手机字体漂移，电脑侧复核。
- **待电脑**：合并 phone → test/chat → 构建 1.0.24（versionCode > `11121734`）→ 装机验长消息选字和思考展开。

### 20）1.0.25：聊天页分层宠物阶段 1（2026-11-13，代码完成，待出包）

- **开关**：`PetPrefs.layeredChat`，默认 false；设置 → 宠物 → 「聊天页宠物（分层）」。
- **渲染**：`LayeredPet` 呼吸/摇晃/点击回弹/随机歪头踮脚；`busy` 时幅度放大；随机眨眼用同一构图的真实闭眼帧 `closed.png` 交叉淡入（用户提供），不再用程序化眼睑。整张立绘去底，未分层。
- **素材**：`app/assets/pets/bluefox/front.png`（900×900，去白底）；源图在 `tooling/pet-assets/bluefox/source`（正面/背面/侧面/脸部/举手）。
- **集成**：`ChatScreen` 的 `CustomMultiChildLayout` 外包 `Stack`，右下角 `LayeredPet`；默认关不影响现有测试。
- **验证**：`dart analyze` 0/0/23；`chat_screen` 31/31。1.0.24 的 26 非金色也通过。
- **阶段 2**：闭眼帧已完成；下一步表情/口型/真正的眼部图层。
- **待电脑**：合并 phone → test/chat → 构建 1.0.25（versionCode > `11121734`；若 1.0.24 未出直接跳）→ 装机开开关验。

---

## 八、Git 与双仓库同步

### 8.1 已配置

```bash
cd /root/dsh-Go
git remote -v
# github  https://github.com/chuyang931914/dsh-Go.git
# gitee   https://gitee.com/chuyang931914/dsh-go-mogai.git
git config user.name  # chuyang
git config user.email # 200414988+chuyang931914@users.noreply.github.com
```

- 凭据：`/root/.git-credentials`（`chmod 600`），`credential.helper=store`
- **文档里不写 token 明文**；换设备/换账号时重新生成 PAT 并执行一次：
  ```bash
  git config --global credential.helper store
  git pull   # 首次输入用户名 + PAT，之后自动记住
  ```

### 8.2 同步命令（2026-11-11 更新：Gitee 为唯一事实源，GitHub 全自动镜像）

```bash
cd /root/dsh-Go
git add -A
git commit -m "feat(mod): ..."

# 只推 Gitee；GitHub 由 Gitee 仓库的 Push 镜像自动同步（同名分支）
git push origin main
git push origin phone   # 手机工作分支
```

**关键差异（务必记住）**：
- Gitee 仓库 `dsh-go-mogai` 是**唯一事实源**，`main` 直接推。
- GitHub 仓库 `chuyang931914/dsh-Go` 已配置 Gitee **Push 镜像**（2026-11-11）：Gitee 每次 push 后约 5 分钟内按**同名分支**自动同步到 GitHub（`main→main`、`phone→phone`），**不再手动推 GitHub**。
- 镜像带来的变化（2026-11-11，用户已确认不再依赖上游更新）：① GitHub 原 `main`（上游历史镜像）已被镜像覆盖为魔改历史；② GitHub 默认分支已切换为 `main`（自动镜像分支）；③ `mogai` 分支**已删除**（2026-11-11，GitHub 上不再保留历史分支）；④ GitHub Actions 已禁用（避免镜像推送反复触发失败邮件）。
- `.git` 约 356MB（含 runtime 等二进制），首次推送慢是正常的；Gitee 一般直连。
- Gitee 仓库名是 `dsh-go-mogai`，**不是** `dsh-Go`，别写错。
- **镜像失效时的兜底**：手动 `git push github HEAD:main`（其他分支同名推），然后回到正常节奏。

### 8.3 手机端分支约定（2026-11-11）

- 手机端工作分支 **`phone`**（2026-11-11 16:47 已快进到 `main` `c07ad5c`，不再基于旧 `0344644`），提交只推 Gitee `phone`（GitHub `phone` 由镜像自动同步），**不碰 `main`**（手机端新改动走 phone，经合并才进 main）。
- 电脑侧接手机端成果：`git fetch origin phone && git merge origin/phone`（phone 基于 main，一般可快进）或 cherry-pick 需要的提交；合并后按 8.2 推 Gitee。
- `/root/dev/dsh-push.sh`：只推 Gitee（`main`→`main`、其他分支同名），GitHub 交给镜像。

### 8.4 双端协作约定（手机端 + 电脑 WSL，2026-11-11）

- **分工**：电脑侧 = WSL 构建 / 全量测试 / APK 构建分发 / `D:\HANDOFF.md` 与飞书同步；手机端 = `dart analyze` / 非金色图测试 / 交叉复跑 / 文档维护 / 装机校验（见 3.4、Rule 30）。
- **动手前先拉最新**：任何一方改代码/文档前先 `git fetch origin && git pull`，禁止在旧提交上开工。
- **分支纪律**：手机端新改动一律走 `phone`（8.3）；电脑侧产出合并进 `main` 后，由**合并者**负责推完 Gitee `main`，别留半截；GitHub 交给镜像。
- **HANDOFF.md 是双方信使（通话渠道）**：谁改谁**先 commit + 推 Gitee**，推完才算更新完成，再干别的活（Rule 33）；禁止带着未推送的文档改动继续工作。合并时规则编号、清单勾选以最新事实为准，发现文档与代码不一致先修文档。
- **GitHub 无需手动推**：由 Gitee Push 镜像自动同步；镜像失效时才手动兜底（Rule 32）。
- **进度同步**：电脑侧每批完成即推 Gitee；手机侧复跑结论写回 3.4 / 9.2 的基线行。两边都不在对方未推送的工作上开工。

---

## 九、已知坑 / Rules（踩过的雷，别再踩）

1. **GitHub 直连不通** → 一律给 URL 加 `https://gh-proxy.com/` 前缀下载（zip、release 均适用）。
2. **runtime 不要重建、不要删**：`runtime/out/arm64-v8a`（r15-dsh0.2.2-rc.1，约 153MB）重建要重新解析 deb 锁并下载大量包，GitHub 不通时极易失败。
3. **`runtime/locks/ubuntu-noble-arm64.json` 已重新解析**（`UPDATE_DEB_LOCK=1`），改动前先备份。
4. **proot 必须固定 5.1.107.102**，高版本在 Android 上有兼容问题（脚本已固化）。
5. **签名不一致 → 覆盖安装失败**。keystore 必须始终是 `D:\Android\keystore\dsh-go-release.jks`，且多处备份。
6. **不要在 C 盘旧副本上构建**：`C:\...\temp_20261110_04\dsh-Go` 已过时。
7. **构建前必须 `source tooling/env.sh`**，否则会用到系统 JDK/找不到 SDK。
8. **`flutter analyze` 会报一堆 `deprecated_member_use`（exists）info**，这是上游自带的，不用管；只看 `error`。
9. **WSL 下以 root 跑 flutter 会提示 "trying to run flutter as root"**，仅提示，不影响构建。
10. **PowerShell 调 WSL 时多层引号容易炸**：多行/带引号的命令建议写成脚本文件再执行。
11. **设置搜索索引**：删页面入口时，`spots.dart` 里的页面 meta 也要一起删，否则搜索仍能搜到已"隐藏"的页面。
12. **改动 UI 后可能出现 unused import / unused_element 警告**，属正常，`flutter analyze` 只要没有 `error` 即可构建。
13. **APK 分发走飞书云空间**：把 APK 上传到飞书云盘（`lark-cli drive +upload --file <apk>`），用飞书文件链接分发；**不要把 GitHub Release / Gitee 链接发到飞书**，飞书内直接点云空间链接下载最稳。
14. **改源码必须同步更新交接文档**：每次修改 `\\wsl.localhost\Ubuntu24\root\dsh-Go\` 下的源码（新增魔改、改配置、改脚本等），必须同步更新本 `D:\HANDOFF.md`（改动明细、Rules、产物路径等），保证文档与代码状态一致；仓库内 `HANDOFF.md` 随 commit 一起推送。
15. **`SettingsPageId` 枚举值必须与 `_pages` 的页面集合完全一致**（`spots_test` 断言 `SettingsIndex.pages.keys == SettingsPageId.values`）：`spots.dart` 里 `SettingsIndex.page(id)` 和 `entry(id)` 用 `pages[id]!` 空断言，缺 meta 会崩溃；反过来只有枚举没有 meta 会让测试变红。剔除页面时**同时删枚举值、`settings_pages.dart` 的 `case`/import、`_rows` 条目、测试与金色**，不要留下"仅映射可达"的死枚举（`privacy`/`about`/`sharedLinks` 三次踩坑，2026-11-11 已清）。
16. **WSLg 弹窗「无法加载远程桌面服务 ActiveX 控件」**：根因是 WSL 3.0 的 `msrdc.exe`（WSLg 组件）启动时加载 `C:\Program Files\WSL\rdclientax.dll`，该 DLL 依赖新版 `mstscax.dll` 的导出函数，但 Win10 19045 的 `mstscax.dll`（10.0.19041.4522）太旧 → `LoadLibrary` 失败（错误码 127）→ 每次用 WSL 都弹错。**修复**：在 `C:\Users\Administrator\.wslconfig` 写入 `[wsl2]\nguiApplications=false` 禁用 WSLg，然后 `wsl --shutdown`。本项目只用 WSL 命令行构建，不需要 GUI，禁用无影响。若以后要用 WSL GUI，需升级 Windows 或降级 WSL 到 2.x。
17. **关闭页面入口要"三件套"一起改**：① 设置 hub 里的 `SettingsTile`；② `spots.dart` 的 `SettingsPageMeta` + `_rows` 索引项；③ 该页专属的分组标题 l10n、测试断言、`settings_hub_full` 金色图。只删 ① → 搜索仍能搜到（见 Rule 11）；只删 ② → 页面仍从 hub 可达；改了分组标题不重生成金色 → 测试红。已按此完成两次：`privacy`（7-3）、`about`（7-10）。
18. **测试缺 CJK 字体会故意报错，这不是 App 缺陷**：`test/support/test_fonts.dart` 在字体缺失时主动 `throw StateError('Test font missing: ...')`，目的是防止金色图静默使用测试引擎的方块字体。WSL 需 `apt install fonts-noto-cjk`（默认 `/usr/share/fonts/noto-cjk`，需 `NotoSansCJK-{Light,Regular,Bold}.ttc`）。**真机中文由 Android 系统字体兜底，APK 不受影响**。装好后 `fc-match` 命中的是 Light 字重，与基准图可能有细微差（本次遇到 11% 像素差），统一用 `flutter test --update-goldens <file>` 重新生成，不要手改 PNG。l10n 改动要先跑 `python3 tool/l10n_merge.py` 再 `flutter gen-l10n`，否则生成物不更新。
19. **【重要】所有改动在交付/提交前必须先跑测试**：至少 `cd app && dart analyze` + 受影响目录的 `flutter test`（改设置类跑 `test/settings`，改聊天类跑 `test/chat`，改更新类跑 `test/update`）。测试未通过不得提交、不得说"完成"。全量 `flutter test` 较慢，按改动面选目录，但不能只凭"看起来没问题"。
20. **【重要】用户以「重要：」开头的指令，必须同步写入文档**：既写本文件（HANDOFF，随 commit 推送并覆盖上传飞书），也写长期记忆 `project_memory.md`；不能只停留在对话里。
21. **指南里的设置路径必须能在索引里找到**：`guide_nav_test` 会把 `<!-- nav: commonSettings,... -->` 路径与 `SettingsIndex.trail` 对照；页面内的行若没有对应 Spot（如「手机操控 › Android Shell」），指南不要写成三级路径，改成二级页路径 + 正文点名该行。改完 `docs/guide/**` 必须跑 `python3 app/tool/guide_sync.py`（会校验死链并重新生成 `app/assets/skills/dsh-go-guide/`），否则技能资源与文档不一致。
22. **删除页面的连带清单**：页面文件、`SettingsPageId` 枚举、`settings_pages.dart` 的 `case`/import、`_pages` meta、`_rows` 里的 Spot、相关 l10n 键（`parts/*.arb` 改完跑 `l10n_merge.py` + `gen-l10n`）、测试文件/用例、金色图、指南路径。漏任何一项都会在 `test/settings` 或 `guide_sync.py` 里报出来。
23. **【最高优先级】停滞三分钟必须主动同步**：任何命令/构建/测试超过 **3 分钟没有新的有效输出**，立刻向用户同步三件事：当前在等什么、已等多久、判断是在推进还是卡住（附证据，如 CPU 时间、进程数、日志尾行）。禁止连续长时间静默等待，也不允许只说"还在跑"。判定标准：`ps` 里 CPU 时间不再增长、没有子进程、日志无新增行 → 视为停滞，立即切换排查思路（用户 Rule 4/5）。
24. **`flutter test` 挂死优先查编译错误，不要盲等**：症状是主进程 CPU 时间几乎不涨、没有 `flutter_tester` 子进程、`frontend_server` 反复重启。直接跑单个测试文件 `timeout 240 flutter test <file>`，`loading ...` 失败会打印真实编译错误。全量测试必须重定向日志（`> /tmp/full_test.log 2>&1`）再轮询 `tail`，否则 `| tail -n` 会缓冲到进程结束，看起来像"没有任何输出"。
25. **未使用 l10n 键扫描的排除范围**：只能排除 `lib/l10n/gen/` 与 `lib/l10n/parts/`，**不能排除整个 `lib/l10n`**——手写的 `lib/l10n/l10n.dart` 里有 `commonMonthDay` 这类调用（`monthDay()` 扩展）。2026-11-11 因排除整个目录误删 `commonMonthDay`，全量测试编译失败并挂死 55 分钟。删除后必须用 `dart analyze --format machine | grep '^ERROR'` 计数为 0 来确认，**不能用 `tail -3` 看结尾**（错误会排在 24 条 info 之前被截掉）。
26. **WSL 上 node 必须用原生 Linux 版**：`check_mjs_parity_test.dart` 有 30 个用例依赖 PATH 上的 `node`。不要 `ln -sf /mnt/d/node.exe /usr/local/bin/node`——Windows 版 node 通过 WSL interop 把 `/tmp/...` 映射成 UNC 路径 `\\wsl.localhost\Ubuntu24\tmp\...` 写回 JSON，测试期望 POSIX 路径格式就会失败。正确做法：`curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && apt-get install -y nodejs`，然后 `ln -sf /usr/bin/node /usr/local/bin/node` 确保 PATH 优先。**不要混装**：如果之前装过 `npm i -g xxx`，Linux 原生版和 Windows 版互相覆盖。
27. **图标删改后必须同步跑 `python3 tool/make_icon_font.py`**：魔改从 `app_icons.dart` 删了 `checkUpdate`/`autoUpdate` 两个角色，`make_icon_font.py` 才是真正产出 `dsh_glyphs.dart` + `DshIcons.ttf` + `codepoints.json` 的入口。只改 Dart 文件不跑生成器 → 字体文件和 glyph 数据仍引用已删图标，`app_icons_test.dart` 会红。pip 装依赖（`fonttools` + `skia-pathops`）需加 `--break-system-packages`（PEP 668，见 Rule 29）。
28. **`ensureVisible` 的 `alignment` 参数决定目标位置**：`Scrollable.ensureVisible(element, alignment: 0.5)` 居中目标元素，默认 `alignment: 0.0`（顶部对齐）可能把目标上方的不透明组件（如 AppBar）盖住，导致 `tester.drag()` 落空。`phone_floating_bar_test.dart` 里 Slider 被顶栏 89px 盖住就是这个坑，改成 `alignment: 0.5` 后 pass。
29. **WSL 里 pip 装包遇到 "externally-managed-environment"**：Ubuntu 24 的 PEP 668 限制，用 `pip install --break-system-packages <pkg>` 绕过（别用虚拟环境，测试工具链跑在 WSL root 用户下）。

30. **手机端（proot aarch64）不能构建 APK，也不要尝试**：① 引擎不发布 linux-arm64 的 Android 宿主构建工具（gen_snapshot 等只有 linux-x64/darwin/windows，release 构建必失败）；② Google 官方无 linux-arm64 版 NDK（项目 `ndkVersion = flutter.ndkVersion` 需要 NDK）；③ `runtime/out` 不随 git 仓库分发，手机克隆里没有（重建风险高，见 Rule 2）；④ keystore 只在电脑 `D:\Android\keystore`。APK 构建与分发继续走电脑 WSL + 飞书；手机端最多做装机后的校验（sha256 / apksigner 指纹 / aapt 权限检查）。
31. **手机端金色图与本机基线必然漂移，禁止在手机端 `--update-goldens` 并提交 PNG**：字体渲染跨机器有差异（同 Rule 18 的问题），手机端验收只看非金色图测试结果 + `dart analyze` 口径；金色图重建只允许在电脑侧批次 4 做。
32. **GitHub 网络与镜像（2026-11-11 起）**：Gitee 为唯一事实源，GitHub 由 Gitee Push 镜像自动同步同名分支（`main`/`phone`），镜像最短间隔约 5 分钟；GitHub 默认分支已切到 `main`，`mogai` 已删除，Actions 已禁用。**手机端/电脑端只需推 Gitee**。镜像万一失效：手动兜底 `git push github HEAD:main`（GitHub 直连不稳时备用代理 `https://gitclone.com/github.com/...`、`https://gh-proxy.com/https://github.com/...` 实测可达）。

33. **【重要】交接文档改完必须先推**（2026-11-11 用户指令）：HANDOFF.md 是双端的「通话渠道」。任何一次更新完成后，先 `commit + 推 Gitee`，**推完才算更新完成**，然后再干别的活；禁止带着未推送的文档改动继续工作，否则另一端读到的还是旧文档。
34. **PowerShell 里调 WSL 不要用双引号 + `$(...)` / 内嵌双引号**：`wsl.exe -d Ubuntu24 -- bash -lc "echo BRANCH=$(git rev-parse ...)"` 会被 **PowerShell 先展开** `$(...)`（报 `not a git repository`），内嵌 `grep -E "..."` 的双引号也会被吞（报 `SHA256:: command not found`）。正确做法：外层用单引号且内部全用单引号，或**写成 `.sh` 文件**放 `C:\Users\Administrator\AppData\Local\Temp\`，再 `wsl.exe -d Ubuntu24 -- bash /mnt/c/.../x.sh`。PowerShell 直接调 `lark-cli` 时，`@./file` 也必须写成 `'@./file'`，否则 `@` 会被 PowerShell 当作语法符号并报 `UnrecognizedToken`（2026-11-12 已踩坑）。
35. **`apksigner` / `keytool` 直接调会 `java: not found`**：WSL 里 JDK 在 `/root/dev/jdk-17`，未 `source tooling/env.sh` 时不在 PATH。验签写成 `source /root/dsh-Go/tooling/env.sh && apksigner ...`，或用绝对路径 `/root/dev/jdk-17/bin/keytool`。

36. **聊天回复正文的长按已是选字**（2026-11-11）：助手回复 `selectable: !streaming`，长按正文 = 选择（系统工具栏复制/全选），消息菜单走 ⋯；不要再把 `selectable` 改回 false 或把选择塞回弹层。用户消息（`UserBubble`）暂仍走菜单里的「选择文字」弹层。

37. **飞书重新授权后不要复用旧私聊 `chat_id`**（2026-11-12）：旧「城南」会话 `oc_5f1bf17fa051caa90b02dcb06d597b7a` 在重新授权后返回 `230001 / invalid receive_id`。先用 `lark-cli im +chat-list --as user --types p2p` 查当前账号可见的单聊，确认名称与 `p2p_target_id`，再用 `+messages-send --user-id <p2p_target_id>` 发送；不要连续拿旧 ID 重试，也不要擅自切换 bot。

---

## 十、版本策略

- **versionName 自 `1.0.16` 起按发布递增**，不再固定跟随上游 `1.0.15`：每次对外发布把 `app/pubspec.yaml` 的 `version: X.Y.Z+1` patch +1（大功能才 bump minor）；`build-apk.sh` 默认读取它，不必再传 `--build-name`。
- build number 仍由 `build-apk.sh` 按 `MMDDHHmm` 生成（例：`11111711` = 11-11 17:11）；versionCode 递增与 versionName 无关。
- 由于已剔除自动更新，**发版不再需要考虑官方版本号**；只要 build number 递增即可正常覆盖安装。
- APK 命名：`dsh-go-<versionName>-<buildNumber>-mogai-arm64.apk`（例：`dsh-go-1.0.16-11121830-mogai-arm64.apk`）；飞书覆盖同一文件 token 时把标题同步改成新文件名，链接不变。
- 每次发布在下方映射表补一行，并同步 HANDOFF / D 盘 / 飞书，避免“同名 APK 分不清”。

| versionName | buildNumber | 说明 |
| --- | --- | --- |
| 1.0.15 | 11111558 | 正文长按选字 + 40px 修复 |
| 1.0.15 | 11111711 | 首次覆盖安装验证（代码同 11111558） |
| 1.0.16 | 11111751 | 版本号冒烟包（功能同 11111711，未装机） |
| 1.0.17 | 11111915 | 选区菜单裁剪 + 问AI + 聊天页宠物关闭 + 边缘手势（真机 3/5 通过，翻译/朗读由 1.0.18 修） |
| 1.0.18 | 11112142 | 修翻译目标（vivo 翻译本体）+ 朗读 0.8×；真机复验通过 |
| 1.0.19 | 11120055 | 时间戳 + 边缘手势 8–40dp；时间戳真机通过 |
| 1.0.20 | 11120812 | 边缘手势 0–80dp；真机通过 |
| 1.0.21 | 11121309 | 自己消息「选择文字」改用自定义选区工具栏；真机通过 |
| 1.0.22 | 11121454 | 自己消息长按直选；双方选字加引用；翻译收进⋯；抽屉顺序 |
| 1.0.23 | 11121734 | 顶部 17px 修复 + 1.0.22 功能；真机通过 |
| 1.0.24 | 待构建 | 长消息跨页选字；手动展开思考不折叠（可并入 1.0.25） |
| 1.0.25 | 待构建 | 聊天页分层宠物阶段1（默认关） |

---

## 十一、装机后验收清单

- [ ] 首次启动首屏**没有**"匿名使用统计"告知条
- [ ] 设置 → 通用：**没有**「隐私与分享」
- [ ] 「全部功能」页中**没有**「分享配置」入口
- [ ] 设置 → 帮助：分组标题为「帮助」，只有「帮助」「诊断」，**没有**「关于 DSH Go」
- [ ] 设置页搜索「关于」「版本」「开源许可」：**无结果、不灰屏**
- [ ] 设置 → 模型 → 新对话默认：显示"… · 低"，改选高/中后保存仍回到"低"
- [ ] 设置页搜索：输入任意关键词**不灰屏**，能正常显示结果（搜"隐私"无结果属正常）
- [ ] 聊天界面顶栏右上角**没有**模型胶囊；点击输入框打字时，输入框底部出现模型胶囊且显示"… · 低"
- [ ] 开启飞行模式静置 10 分钟，抓包/看日志无统计上报请求
- [ ] `apksigner verify` 通过，指纹 `fb462eb1…` 一致
- [ ] `aapt dump badging` 输出里**没有** `REQUEST_INSTALL_PACKAGES`
- [ ] 覆盖安装旧魔改包成功（签名一致）

---

## 十二、下一步可推进方向

1. ~~备份 keystore 到网盘 + U 盘各一份（最高优先级，丢失不可逆）~~ **部分完成（2026-11-11）**：本地两份（`D:\Android\keystore\backup\`、`D:\备份\keystore-20261111\`）+ 飞书云空间一份（token `HPwebhSADomeoax2hQpcdc9YnXg`）；keystore 已验证：别名 `dsh-go`、证书 SHA-256 `fb462eb1…`、有效期至 2054-03-28、文件 SHA-256 `e089f9c4…`。**剩余：U 盘/其他物理介质一份**（当前未检测到可移动盘）。
2. 若要继续魔改，优先"禁用 + 去入口"，尽量不删文件，减少上游 rebase 冲突。
3. 上游升级时：以新版本为基线重新打 4 处补丁（补丁点见第七节），保留本仓库 commit 作为参考。
4. 重打 APK（本轮 `11110113` 已包含删除关于/隐私/sharedLinks 残留与指南修正）→ 上传飞书云空间覆盖同名文件 → 按第十一节逐条验收。后续 `7cdf795` 只删未使用 l10n 键，无 UI 可见变化，**不需要**为此重打 APK。
5. ~~全量 99 红清账~~ **✅ 已完成（2026-11-11）**：按第 9.3 节五批顺序全部清零，commit 序列 `a2889e5` → `886e699`（批次1-5）。全量 `flutter test` = 10845 passed / ~288 skipped / 0 failed；回归面 = 473 passed / 0 skipped / 0 failed。新基线已写回 9.2。
6. **1.0.20 已出包并分发（2026-11-12）**：边缘手势 8–40dp → 0–80dp，APK `11120812` 已覆盖飞书原链接；装后验 0–80dp 起手是否稳定拉抽屉/快捷面板、中间是否仍不响应。1.0.19 的时间戳仍待确认。其他问题继续追加到 [`BACKLOG.md`](BACKLOG.md)。

---

## 十三、隐私面审计结论（2026-11-11，只记录，暂不处理）

对诊断页、本机引擎日志、手机操控与全量外发通道做过一次只读审计，结论：**未发现静默采集或后台上报通道**。用户决定暂不改动，此处留档，后续若要收敛再按本节执行。

### 13.1 诊断页「采集本次日志」

- 实现：原生 `SystemImeEvidence` 跑固定 logcat，只放行 `ImeTracker` / `InputMethodManager`，其余 `*:S`；只取最近 120 秒、最多 64 条，PID 必须等于本应用；锚定正则解析，不匹配即丢弃。
- 字段仅 5 个：时间戳、`requestShow`/`requestHide`、`fromUser`、reason、origin。**不含输入内容、不含包名、不含设备标识**。
- 三道闸门：当次确认（`SystemImePrompt.kt:89`）、已有特权通道 `mode!="off"`（`BackgroundControl.kt:853-858`，注释明确 "never starts a transport or gate"）、无手机操控任务占用。
- **系统权限未开时返回 `unavailable`，采不到任何数据，也不会为诊断去申请权限或建链路。**

### 13.2 导出 ZIP / 让 AI 看诊断

| 出口 | 行为 | 风险 |
| --- | --- | --- |
| 导出 ZIP | `SharePlus` 系统分享或存 `Download/DSH-Go/`，代码中**无任何上传调用** | 中：`engine.log` 尾部最多 2000 行，是引擎 stdout，**可能含对话/命令片段**，只做密钥类脱敏 |
| 让 AI 看诊断 | 写 `$DSH_HOME/dsh-app/diagnostics.md`（≤16KB，含引擎日志尾部 80 行）供引擎 agent 读取 | 需注意：**云端模型会话会把该文件带进上下文**，等于发给模型方 |
| 自动发布 | `root_gate.dart` 每轮引擎启动后自动 `publish()` 一次，`includeSystemIme=false` | 低：纯本地写文件，无网络 |

ZIP 内容：`summary.json`（版本/设备/Android/runtime manifest/引擎状态/连接类型）、`settings.json`（API Key 只记"是否已配置"布尔值）、`crash.json`、`engine.log`、`failure.log`；IME 证据仅手动导出时附带。

### 13.3 手机操控与权限

- 依赖 `AccessibilityService`（读屏+点按）+ 可选 Shizuku/自 ADB 特权通道。
- 无障碍未开 → `PhoneStatus.a11y.enabled=false`，界面显示"手机操控尚未开启"，整体禁用；特权通道未配置 → `background_not_ready`。
- **没有** MediaProjection/录屏、**没有**通知监听、**没有**剪贴板读取服务；Manifest 未声明这些能力。

### 13.4 全量排查

| 项 | 结论 |
| --- | --- |
| Sentry / Crashlytics / Firebase / Bugly / 友盟 / GA | 均无 |
| 应用内错误日志 | 仅内存 40 条，重启即清，无持久化 |
| 明文 HTTP | 仅允许 `127.0.0.1` / `localhost`（`network_security_config.xml`） |
| 证书校验绕过 | 未发现 `badCertificateCallback` / `trustAll` |
| 云备份 | `allowBackup="false"`（rootfs 含明文凭据，已显式排除） |
| 危险权限 | `READ_PHONE_STATE` / `BLUETOOTH` / `MODIFY_AUDIO_SETTINGS` 已 `tools:node="remove"` |
| 其他外发 | 分享码（GitHub Gist，用户主动）、社区配置（raw.githubusercontent / jsdelivr）、论坛、插件市场、云余额、托管链接、语音模型下载；均为功能触发，未见后台轮询埋点 |
| 已禁用 | 匿名统计 `UsageBuild.active=false`；自动更新 `autoCheckIfDue()` 恒 `false` |

### 13.5 若以后要收敛（可选，当时未执行）

- 方案 A（推荐）：删「让 AI 看诊断」入口 + `root_gate` 自动发布调用，保留本地只读诊断与导出。零主流程风险。
- 方案 B：再删导出卡与 `diagnostics_publish.dart` / `diagnostics_export.dart`，失去导出能力。
- 注意：`engine.log`、版本、设备等是 snapshot 字段，底层 `localRuntimeLogsProvider` 被引擎日志页/安装引导/安全模式共用，**不能删 provider**，只能关出口。

---

## 十四、双端长期协作约定（手机端 + 电脑 WSL，2026-11-11 起生效）

> 目标：两边并行开工不撞车、结论可互相复核、任何一端断线时另一端能接手。日常操作纪律见 8.4，本节管长期角色与机制。

### 14.1 角色分工（长期）

| 端 | 负责 | 不做 |
| --- | --- | --- |
| 电脑（WSL） | APK 构建/签名/分发、飞书与 D 盘同步、全量 `flutter test`、金色图重建、上游升级重打补丁、JDK/NDK/SDK 等工具链 | 不把没过测试的代码推 `main` |
| 手机（proot） | `dart analyze`、非金色图测试与交叉复跑、代码/文档审阅、分支合并、装机后校验、文档维护 | 不构建 APK（Rule 30）、不重生成/提交金色图（Rule 31） |

### 14.2 事实源与节奏

- 仓库是唯一事实源；HANDOFF.md 随代码提交，是双方共同语言（Rule 14）。
- 一个原子任务一次 commit + push；禁止在未推送的工作上继续开工。
- 手机端产出走 `phone`（8.3）；电脑侧开工前先 `git fetch origin && git pull`，需要时 `git merge origin/phone`。
- 谁把改动合并进 `main`，谁负责推 Gitee `main`（完成标志）；GitHub 由 Gitee 仓库镜像自动同步，无需手动推（见 8.2）。

### 14.3 冲突与分歧裁决

- 同一文件双写：后动手者先 pull 再改；真撞车，以先推送方为基线，后手在其上重做，禁止 force push。
- 测试结论不一致：电脑侧全量结果为权威（字体与基线一致）；手机端只报差异清单，不下「真回归」定论（Rule 31）。
- 手机端推 GitHub 连续 3 次超时（Rule 32）：转电脑侧推，不阻塞主线。

### 14.4 版本与升级

- 上游升级：电脑侧以新版本为基线重打 4 处补丁（第七节）；手机端做补丁后 analyze + 非金色图复跑与差异审阅；两边结论一致才进 `main`。
- 新魔改：优先「禁用 + 去入口」，尽量不删文件（第十二节第 2 条）；动工前先在 HANDOFF 写设计，改完同步文档。

### 14.5 沟通与上报

- 每批次完成：推仓库并在 HANDOFF 对应小节写结论。
- 真实回归、签名/keystore 问题、网络长时间中断：立即停下同步用户，不绕过红线自行处理。
- 用户「重要：」开头的指令：按 Rule 20 落文档 + 长期记忆。

