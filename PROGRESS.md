# dsh-Go 进度日志

> 追加式流水账：每次构建、装机、真机反馈、重要决策后加一条（最新在上）。
> 这里记“发生了什么”；当前状态看 [`PROJECT_STATE.md`](PROJECT_STATE.md)，完整实现看 [`HANDOFF.md`](HANDOFF.md)。

## 2026-11-14 23:39 · 1.0.30 回退包已装（11142303），数据保留

- 实机：`1.0.30+11142303`（诊断 23:38:31 确认；versionCode `11142303` > 旧 `11142142`，覆盖安装成功）。版本名已回到 1.0.30。
- 数据：`~/.dsh/sessions` 25 MB 在、`ui.json` 121 B、插件 `local-ai-cost` 目录在；引擎 `running · normal`。
- APK：包已不在手机（`/sdcard/Download` 只剩 1.0.27 与 1.0.30-11142005），无法本地复核 sha256；以电脑端报告 `b84c012c…ac8d3dc` / 206,213,692 字节为准。
- 代价已知：`11142303` 大于 1.0.31 的 `11142142`，现在**不能直接降回 1.0.31**，要回就重打一版 buildNumber 更大的 1.0.31。
- 选字边缘滚动：用户 23:44 确认「没有问题」，1.0.30 核心修复通过。

## 2026-11-14 23:11 · 1.0.30 回退验证包已出（11142303，待装机）

- 用途：**临时回退验证包**，把实机从 1.0.31 的实际行为拉回 1.0.30（不是正式发版），确认后再决定是否留档。
- 来源：电脑端（WSL）按 `docs/rollback.md` 路径 A：从 `52ad553`（1.0.30 出包提交）切 `rel/1.0.30`，`DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64`。
- 产物（电脑端报告）：`dsh-go-1.0.30-11142303-mogai-arm64.apk`，206,213,692 字节，sha256 `b84c012c…ac8d3dc`；Gradle 264.0s，0 error，warning 仅 flutter_webrtc KGP 弃用 1 条；与首发 1.0.30（`11142005` / `cc712b78…f15eed`）字节不同属正常。
- **versionCode 顺序**：`11142303` > 1.0.31 的 `11142142`，装上后不能直接降回 1.0.31，要回 1.0.31 必须重打一版。这是回退验证的预期代价。
- 包只在电脑 `D:\Android\apk\`，手机本地仍只有 1.0.27；需先传到手机 `/sdcard/Download/Lark/` 核字节数与 sha256，再覆盖安装。
- 装后验收：`bash tooling/check-device.sh`（versionCode 11142303、版本名 1.0.30）、选字边缘滚动、会话/工作区/ui.json 是否保留；结果写 UPGRADE_TABLE（新增一行）与 PROJECT_STATE 第 2 节。
- 电脑端提醒：`rel/1.0.30` 不要推远端；远端 `main`/`phone` 已到 `c7ccf49`（本轮文档剔除），先 `git fetch && git merge --ff-only`。

## 2026-11-14 22:35 · 1.0.31 装机验收（部分通过，① 只验到开关/桥接，② 免测）

- 前置（22:23 诊断）：实机 `1.0.31+11142142`；手机操控开关 true · 桥接监听 true · 无障碍 true 且服务已连接。logcat 22:22:52 `DshA11y: accessibility service connected`。
- **① 强制停止测试**：22:24:48 杀旧进程 28986 → 22:24:49 新进程 12760 启动（`BackgroundControl.setBackgroundMode` 启动即被调用，锁校验告警 1 条）。
  - 重启后诊断：开关 true · 桥接监听 true → **自动恢复**；无障碍开关 false · 服务已连接 false → **未恢复**；logcat 无 `DshA11y` / `DshA11yKeeper` 记录，读屏工具不可用，直到 22:27:08 手动重开手机操控才重连。
  - 判定：上游 1a（v1.0.16 资源自愈）本轮**未被触发**——诊断「最近接受的后台输入探针事实：未运行」，没有后台屏通道在跑，`journal` 残留无从观测；本轮只证到「开关/桥接持久化恢复、无障碍不自动恢复」。
  - 无障碍不自恢复的原因：`A11yKeeper` 依赖 `WRITE_SECURE_SETTINGS` 才能把服务写回系统列表，未授予就只能人工重开。
- **② 息屏 30 分钟耗电**：22:28 记起点 68%（电池健康 70%）后，用户 22:33 要求**免测**。1.0.30 也没有终点数（只有 20:27 起点 40%），两版无对比数据。
- **用户决定（22:33）**：无障碍自动恢复**暂时不补**（平时不开无障碍）；耗电不测。1.0.32 只做工具输出折叠 + 1b 精简版。
- 结论：1.0.31 装机可用、无回归；① 部分验证、② 免测，版本表/状态页按此记录。

## 2026-11-14 21:50 · 1.0.31 出包（arm64，buildNumber 11142142）

- 基线：`git fetch` 后 `main` = `origin/main` = `origin/phone` = `c9a1547`，`app/pubspec.yaml` = `1.0.31+1`，工作区干净。
- 电脑侧验证：`dart analyze` 0 error / 0 warning / 24 info（全 deprecated_member_use / unnecessary_import）；`flutter test test/chat` **1969 通过 / 0 失败**（2m08s）。
- 环境事故：首次跑 test 时 WSL 发行版整体卡死（`WSAETIMEDOUT`，遗留 6 个 wsl.exe 进程），`wsl --shutdown` 后恢复；之后 test/build 改成后台写 `/root/*.log` 再读，避免 Shell 超时丢输出。
- 构建：`DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64`，Gradle `assembleArm64Release` 268.4s；无 error；warning 仅 flutter_webrtc KGP 弃用 1 条。
- APK：`D:\Android\apk\dsh-go-1.0.31-11142142-mogai-arm64.apk`，206,213,828 字节，sha256 `d2cc740b895c03f7b76aab42c75f17cc70b5d8f53a2e9079233f55ba4ff3d8e9`，证书 `fb462eb1…3c2f`，versionCode `11142142` > `11142005`。
- 源码包：`dsh-go-1.0.31-11142142-mogai-src.zip`，628,380,110 字节，sha256 `167c26ce27395e23df1a10f0f002107b0c132aa0fc329e81d58bd457ded4714f`，6,980 文件；排除项（`.git`/`app/build`/.dart_tool）校验 0 命中，保留 `runtime/out`。
- push：`Everything up-to-date`，`ls-remote` = `c9a15479b5e9efad994aa74019472b24af78d9f6`。
- 本版内容：上游 v1.0.16 资源自愈（1a）。装机要验：后台屏断连后自动恢复、journal 无残留卡死记录，以及 1.0.30/1.0.31 息屏 30 分钟耗电。

## 2026-11-14 21:17 · 摘入上游 v1.0.16 资源自愈（1a，未出包）

- 背景：上一轮评估记在 `BACKLOG.md`「上游 v1.0.16 三条特性评估」；用户选 1A。
- 摘入：`133d2122`（OEM 拒绝命名空间时不再永久阻断旧后台资源恢复）+ `f8ee2a6a`（无 displayId 的孤儿探针记录同一开机内结案）。`5db07c91`+`df16eb2` 是上游自我回退，跳过。
- 改动：4 个 Kotlin 文件 +75/−23。`ResourceRecovery.verify` 把 uid 校验提到 displays 查询之前、`displayId` 为空时返回 `deadPeerEmpty`（原先抛 `recoveryUnknown` 永久卡住）；`BackgroundRecoveryProtocol.recovered` 去掉 deadPeerEmpty 的 pidNs 前置限制；两个单测新增 5 个用例。
- 移植坑：① `f8ee2a6a` 不能原样打（前置含上游已 revert 的 `sameNamespace` 重构，:69 冲突）→ `ResourceRecovery.kt` 手工移植，其余 3 文件按补丁打；② 上游 `unavailableNamespaceCanConsumeDeadPeerEmptyFromTheHostProof` 与自身实现矛盾（`previousBoot` 记录带 id、回执不带 id 却断言 true）→ 补「`previousBoot` 提前放行」2 行，理由：上一次开机的记录不可能留下活着的虚拟屏，不需要回执回声 id。
- 验证：`dart analyze` 0 error / 24 info（与 1.0.30 同）；`:app:testArm64DebugUnitTest` 整个 `phone.background` 包 **427 通过 / 0 失败**（首次跑 debug 变体要下载 embedding，6m26s；之后增量 4s）。
- 未出包：源码仍 `1.0.30+1`，出 1.0.31 时再 +1；真机要验「后台屏断开后能自动恢复」「残留记录能释放」。
- 未做：工具输出折叠（可摘）、1b 连接重写（需适配，含「升级后不复用旧服务」）、tawcroot（不能摘）。

## 2026-11-14 20:10 · 1.0.30 出包（arm64，buildNumber 11142005）

- `main` = `phone` = `52ad553`，工作区干净，reset --hard 后直接构建。
- 两处改动核验：`DshService.kt:209` `private const val WAKE_TIMEOUT_MS = 20 * 60 * 1000L`；`chat_list.dart` `_longPressFloor = Duration(milliseconds: 300)`。
- 电脑侧验证：`dart analyze` 0 error / 0 warning / 24 info（全 deprecated_member_use）；`flutter test test/chat` **1969 通过 / 0 失败**。
- 构建：`DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64`，285.4s，无 error；warning 仅 flutter_webrtc KGP 未来弃用 + 15 packages 可升级。release 未设 `isMinifyEnabled`，R8/minify 关闭。
- APK：`D:\Android\apk\dsh-go-1.0.30-11142005-mogai-arm64.apk`，206,213,645 字节，sha256 `cc712b7842a429af052614c839729b5684f033f77dcf0c67dd11ecd4e6f15eed`，证书 `fb462eb1…3c2f`，versionCode `11142005` > `11140932`。
- push：`Everything up-to-date`，`ls-remote` = HEAD = `52ad553301d61c4a5afd52c4b815f4416fb2113e`。
- 装机待验：息屏 30 分钟耗电、长按选字拖边缘。

## 2026-11-14 19:00 · 1.0.29 源码打包发飞书

- 源：`main` = `4bd6477`（1.0.29 代码 `b5bd8e7` + 出包文档提交）。
- 包：`dsh-go-1.0.29-11140932-mogai-src.zip`，626,822,487 字节（598MB），sha256 `1c71d560f8c3ded5982725af523539ffb52ac2fb2ca44d1ef3dcff0b55089029`，6965 个文件，`pubspec` = `1.0.29+1`。
- 排除：`.git`、`app/build`、`.dart_tool`、`runtime/.work`、`runtime/.cache`；保留 `runtime/out`（可直接重建 APK）。
- 飞书：新建文件上传成功，file token `K2kCbcXXDowHj4xewIpcTB1onRg`，云端版本 `7707983819785112840`；本地同份 `D:\Android\apk\`。
- **踩坑**：覆盖旧源码包 token `IEqgbC77zoOqWmxo277cr8Wdnue` 连试两次均报 `1061001 unknown error`（标 retryable，实际重试无效）；改为不带 `--file-token` 新建上传后一次成功。旧 1.0.15 源码包仍在原 token，未删除。
- **注意**：打包期间手机侧把 `origin/main` 推到 `0799c3e`（1.0.30 进行中），此包内容为 1.0.29 代码，不含 1.0.30 改动。

## 2026-11-14 09:38 · 1.0.29 出包（arm64，buildNumber 11140932）

- `main` = `phone` = `b5bd8e7`，工作区干净，reset --hard 后直接构建；本版改动仅 `chat_list.dart` +71 行、`pubspec.yaml` 版本号、两处文档，无 Kotlin 改动。
- 电脑侧验证：`dart analyze` 0 error / 0 warning / 24 info（全 deprecated_member_use）；`flutter test test/chat` **1969 通过 / 0 失败**（手机侧报红的 2 张 send_options golden 在电脑上全绿）。
- 构建：`DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64`，266.8s，无 error；warning 仅 flutter_webrtc 的 KGP 未来弃用提示 + 15 packages 可升级。release 未设 `isMinifyEnabled`，R8/minify 确认为关闭。
- APK：`app-arm64-release.apk` → `D:\Android\apk\dsh-go-1.0.29-11140932-mogai-arm64.apk`，206,214,152 字节，sha256 `c34fb33c…1ee485`，证书 `fb462eb1…3c2f`，versionCode `11140932` > `11140025`。
- 装机待验：长按选字拖到屏幕上下边缘是否自动滚（1.0.28 的「无效」复验点）。

## 2026-11-14 00:35 · 1.0.28 出包（arm64，buildNumber 11140025）

- `main` = `phone` = `82cbb8c`，reset --hard 后裸跑通过；本地旧 47 commits 与两个测试文件未暂存改动全丢弃。
- 电脑侧验证：`dart analyze` 0 error / 24 info；`flutter test test/chat` **1969 通过 / 0 失败**（含 message_menu 4 张 golden 全过；之前担心的字体 pixel 漂移未出现）。
- 构建：`DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64`，281.5s，无 warning/error（仅 flutter_webrtc KGP 未来弃用警告 + 15 packages 有新版本可升级的提示）。
- APK：`app-arm64-release.apk` → `D:\Android\apk\dsh-go-1.0.28-11140025-mogai-arm64.apk`，206,215,379 字节，sha256 `ed984049…55517f`，证书 `fb462eb1…3c2f`，versionCode `11140025` > `11131822`。
- 本版改动只两件：选字全局指针路由 + 唤醒锁按需（`DshService.kt` + `RuntimePlugin.kt` 的 setBusy ~26 行）。思考照常显示。
- 装机待验：选字滚、唤醒锁按需（后台与耗电）。

## 2026-11-14 21:20 · 1.0.31 待出包（1a 资源自愈）

- 电脑侧摘入上游 `133d2122` + `f8ee2a6a`，提交 `affc661`，4 个 Kotlin 文件 +75/−23，新增 5 个用例。
- 电脑测：analyze 0 error / 24 info；`:app:testArm64DebugUnitTest` 的 `phone.background` 427 通过 / 0 失败。
- 手机侧：`dart analyze` 0 error / 24 info（Kotlin 单测只能在电脑跑）。
- 移植判断：`f8ee2a6a` 依赖上游已 revert 的 sameNamespace 重构，`ResourceRecovery.kt` 手工移植；上游 `unavailableNamespaceCanConsumeDeadPeerEmptyFromTheHostProof` 自相矛盾，补了两行 previousBoot 提前放行。
- 本版**不解决**「升级后要手动重开手机操控」——那是 1b 的服务版本绑定，排 1.0.32。

## 2026-11-14 20:30 · 1.0.30 装机，选字验证通过

- 装 `1.0.30+11142005`（206,213,645 字节，sha256 `cc712b78…f15eed`），覆盖安装成功，数据保留。
- 选字：长按选段拖到边缘仍正常，300ms 长按门槛没有让起手变迟钝 → 用户 20:28 确认「没问题」。
- 待机耗电：20:27 基线电量 40%（电池健康 70%，已老化），30 分钟息屏后复读对比。
- 本次装机是手机侧自助：读屏核验版本、用无障碍打开设置读电量；安装那一步仍需用户点一次（系统限制）。

## 2026-11-14 19:10 · 1.0.30 唤醒锁兜底超时

- 审计 `DshService` 唤醒锁路径：`onDestroy`、`setBusy(false)`、`INSTALL_DONE` 三处都释放；漏洞在「页面已卸载但生成还在跑」时没人发 busy=false，锁会一直持有。
- 修法：`acquire(20min)` 兜底，超时自动释放。正常生成远短于 20 分钟。
- 未验：装机后息屏 30 分钟对比耗电。

## 2026-11-14 09:55 · 1.0.29 选字滚动真机通过

- 装 `1.0.29+11140932`，用户复测：长按选长文、拖到底边，内容自动滚、选区跟着变长 → 「滚了」。
- 这条从 1.0.27 开始失败两次（Listener 版、面板版），第三次改到聊天列表层才对。教训：先确认用户实际用哪条路径，再改代码。
- 仍待在 1.0.29 上验：唤醒锁按需、待机耗电基线。

## 2026-11-14 09:40 · 1.0.29：选字滚动改到聊天列表

- 1.0.28 装真机后用户反馈「没滚」。查明：1.0.28 改的是「选择文字」面板，这个版本没有该面板，用户是长按直接选字。
- 改法：`chat_list.dart` 加全局指针路由 + ticker。判定「在选择」靠一个事实：手指动了、列表没动（拖动被选区吃掉）。此时手指进入上下 64px 边缘带，列表按 12px/帧滚动。
- 修过一个坑：`_ChatListState` 原来是 `SingleTickerProviderStateMixin`，加第二个 ticker 直接崩，换成 `TickerProviderStateMixin`。
- 验证：`dart analyze` 0 error / 24 info；`chat_shell` + `scroll_settle` 11 通过，仅 2 张 send_options 金色图因手机字体漂移红（电脑重建）。

## 2026-11-14 02:00 · 撤掉隐藏思考

- 用户改口：思考过程不隐藏，照常显示。`chat_rows.dart` 与相关断言回到 1.0.24 原样，仅保留 1.0.26 的「手动展开不自动收回」修法。
- 1.0.28 定稿三件变两件：选字全局指针路由 + 唤醒锁按需。
- 手机侧验证：`final_answers_fold` + `rows_fold` + `turn_fold` + `stream_motion` + `thinking_collapse` + `thinking_label` 62 通过。

## 2026-11-14 01:20 · 1.0.28 收口为三件

- 撤回后按用户要求把三项拣回 1.0.24 基底：选字全局指针路由、隐藏思考（`chat_rows.dart`）、唤醒锁按需（`DshService`/`RuntimePlugin`/`chat_screen` 的 `setBusy`）。
- 手机会话验证：`dart analyze` 0 error / 25 info；`final_answers_fold` + `thinking_collapse` + `thinking_label` + `message_actions` 37 通过。
- 保险箱、红后灯带、分层宠物仍不在本版，存档在 `archive/1.0.28-full`。

## 2026-11-14 00:35 · 1.0.28 撤回至 1.0.24 基底

- 用户决定：1.0.25 之后的功能（保险箱、红后、唤醒锁、隐藏思考、宠物）全部撤出，只保留选字修复。
- `phone` 重建为 `9da1d7c`（1.0.24）+ `e252b28`（选字改全局指针路由），版本 `1.0.28+1`。
- 完整版存档：分支 `archive/1.0.28-full`（`c82570c`，含 Kotlin 编译修复与红后降级）。
- 待验三件已记录：选字滚动、唤醒锁/耗电基线、隐藏思考。

## 旧条目已归档

> 2026-11-11 ~ 2026-11-12 的条目移到 [`docs/archive/PROGRESS-2026-11a.md`](docs/archive/PROGRESS-2026-11a.md)。

