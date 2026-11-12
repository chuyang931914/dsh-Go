# dsh-Go 进度日志

> 追加式流水账：每次构建、装机、真机反馈、重要决策后加一条（最新在上）。
> 这里记“发生了什么”；当前状态看 [`PROJECT_STATE.md`](PROJECT_STATE.md)，完整实现看 [`HANDOFF.md`](HANDOFF.md)。

## 2026-11-12 13:20 · 1.0.21 出包

- `main` ← `phone` 快进到 `c3bf654`（选字修复 `197368c` + 插件文档）。
- APK `1.0.21+11121309`，206,211,961 字节，sha256 `e67678f3…401d`，证书 `fb462eb1…3c2f`。
- 电脑侧 `dart analyze` 0/0/24；`test/chat` 1967 通过 / 0 失败；4 张 menu golden 全通过（手机端红为字体漂移，未重建）。
- 待真机覆盖安装后，长按自己消息 → 选择文字复验。

## 2026-11-12 14:40 · 抽屉分组顺序修复

- 发现 `drawer_list.dart` 写死置顶在前，`drawer.groups` 解析但未使用；新增 `uiDrawerGroupsProvider` 按配置排序。
- analyze 0/0/23；drawer_calendar + drawer_list_lazy 16/16。
- 配置 `folders→pinned→today…`；需 1.0.22 APK 才能生效，重启引擎不够。

## 2026-11-12 14:33 · 抽屉文件夹/置顶换序

- `config/ui.json` 的 `drawer.groups` 改为 folders 在 pinned 前；本机 `ui.json` 软链到仓库配置。
- 无需重启/构建；待电脑合并文档。

## 2026-11-12 14:03 · 1.0.22 直选与引用

- 自己消息改为长按直选；右下⋯菜单四项：复制/选择文字/引用/编辑后重发。
- 双方选字工具栏：复制/全选/引用/⋯；翻译移进⋯。
- `dart analyze` 0/0/23；message_actions 12/12；message_menu 6 非金色通过，4 张 golden 待电脑复核。
- 待出 1.0.22（versionCode > 11121309）。

## 2026-11-12 13:55 · 插件/界面配置入库

- 仓库新增长期源：`plugins/local-ai-cost/`（不含 secrets/node_modules）与 `config/ui.json`。
- 规则写进 PROJECT_STATE：仓库是唯一源头，手机/电脑改动都要入库；仅密钥和依赖目录例外。
- 待电脑合并 phone、同步 D/飞书；插件本机运行目录保持不变。

## 2026-11-12 13:50 · 1.0.21 与费用插件收口

- 实机 `1.0.21+11121309`：自己消息「选择文字」只剩复制/全选/翻译/⋯，无「引用」；编辑后重发保留。
- `local-ai-cost` 已安装运行：DeepSeek 余额、火山本月账单；密钥 600，预算未调整。
- main 此前 303730c；本次仅收口文档，待电脑合并/同步 D 盘飞书。

## 2026-11-12 13:45 · 1.0.21 安装与记忆对齐

- 实机已装 `1.0.21+11121309`，安装前标记/会话保留。
- main/phone 对齐 `3501fdf`；修正 PROJECT_STATE 里仍写 1.0.20/c3bf654 的过期状态。
- 下一步：长按自己消息→选择文字复验；电脑新对话先 `git pull` 再读 PROJECT_STATE。

## 2026-11-12 13:00 · 隐藏插件入口

- `ui.json`：`hide: ["pluginCapsule"]`，隐藏聊天页「插件」入口；费用条/面板保留。
- 仍待电脑合并 phone、构建 1.0.21、同步 HANDOFF 到 D/飞书。

## 2026-11-12 12:45 · AI 费用插件完成

- 插件 `local-ai-cost`：输入框上方摘要 + 「AI 费用」面板。
- DeepSeek `/user/balance` 与火山 `billing.ListBillOverviewByProd` 均用真实凭据跑通；检查器通过。
- 凭据写入插件 `secrets.json` 600，临时文件已删；待重启引擎加载界面。
- 1.0.21 仍待电脑出包；phone 197368c，main f5306f9。

## 2026-11-12 10:55 · 1.0.21 自己消息选字修复

- 用户反馈：长按自己消息→选择文字仍是旧 OEM 菜单。
- `showSelectTextSheet`/`_SelectTextSheet` 改用 `SelectionToolbar`，`UserBubble` 传入 ChatList 的选区动作。
- `dart analyze` 0/0/23；message_actions + message_time + message_menu 22 非金色通过；4 张旧菜单 golden 待电脑确认/重建。
- 待出 1.0.21（versionCode > 11120812），装机复验。

## 2026-11-12 08:40 · 1.0.20 真机通过

- 实机安装 `1.0.20+11120812`，数据保留。
- 边缘 0–80dp 起手可稳定拉抽屉/快捷面板，中间不响应。
- 1.0.19 时间戳显示、点任意时间全聊天切换均确认正常。
- 1.0.19/1.0.20 收口；四线待文档同步。

## 2026-11-12 08:05 · 1.0.20 边缘手势 0–80dp

- 1.0.19 安装后实测 8–40dp 仍不灵敏；改为 0–80dp，中间不响应。
- 快捷面板测试 39/39；`dart analyze` 0/0/23。
- 待电脑出 1.0.20（versionCode > 11120055），装后验手势；时间戳在 1.0.19 已装待确认。

## 2026-11-12 08:19 · 1.0.20 出包并分发

- `main` 快进至 `phone b29a4e5`：边缘触发带 8–40dp → **0–80dp**，中间仍不响应；`pubspec 1.0.20+1`。
- 电脑侧 `dart analyze` 0 error / 0 warning / 24 info；`test/shell` **217 全通过**；未重建金色图。
- APK `dsh-go-1.0.20-11120812-mogai-arm64.apk`，206,211,199 字节，versionCode `11120812` > `11120055`，证书 `fb462eb1…3c2f`，sha256 `817a3008…7d99`；已存 `D:\Android\apk\`。
- 已覆盖飞书原 file token `RzcFbpFCyokpPqxVIq5cUI1QnuR`（云端版本 `7707072743111445690`），并发送至「城南」单聊（message_id `om_x100b6064131680a0de3549dac57d65b`）。装后只验 0–80dp 边缘起手与中间不响应。

## 2026-11-12 07:46 · 1.0.19 私聊通知完成

- 以 user 身份发至「城南」当前单聊 `oc_ef1b285c3aa75900a8d4221654d58b20`，message_id `om_x100b607baa11c4a4c0ebfee8b0c0f2a`；附原 APK 链接与时间戳/全局切换、8–40dp 边缘手势复验清单。
- 旧 chat_id `oc_5f1bf17fa051caa90b02dcb06d597b7a` 返回 `invalid receive_id`；通过 `im +chat-list --as user --types p2p` 重新定位。PowerShell `@file` 与旧会话 ID 两个坑已写入 HANDOFF Rules 34/37。

## 2026-11-12 07:33 · 1.0.19 飞书分发恢复

- 飞书授权恢复；APK 已覆盖原 file token `RzcFbpFCyokpPqxVIq5cUI1QnuR`，版本 `7707061086150757632`，链接不变。
- HANDOFF 同步覆盖飞书；实机待装 `1.0.19+11120055` 验时间戳/全局切换与 8–40dp 边缘手感。

## 2026-11-12 01:15 · 1.0.19 电脑侧出包

- `main` 快进合并 `phone 3bf2914`；重建 44 张 chat/shell 金色图，修正两处测试适配，提交 `81bcd98`，未改产品代码。
- `dart analyze` 0 error / 0 warning / 24 info；`test/chat + test/shell` 2184 全通过。
- APK `1.0.19+11120055`，206,211,210 字节，证书 `fb462eb1…3c2f`，sha256 `0db5bb9a…ba4c`；已存 `D:\Android\apk\dsh-go-1.0.19-11120055-mogai-arm64.apk`。
- 飞书用户令牌过期，宿主授权超时，APK/文档暂未覆盖飞书；待授权恢复。实机待装 1.0.19 验时间戳与 8–40dp 边缘手感。

## 2026-11-12 00:20 · 1.0.19 代码完成

- 消息时间戳：每条用户/助手消息一行；默认精简，点任意时间全聊天切换完整（周几+秒）；日期每天第一条。
- 边缘手势：24dp → 8–40dp，避开系统返回手势；中间仍禁用。
- `message_time_test` 5/5；`message_actions + message_time + turn_settle + quick_panel` 62/62；`message_flow` 4 张 golden 待电脑重建。
- 未构建；待电脑出 1.0.19（versionCode > 11112142）并真机验收。

## 2026-11-11 23:52 · 1.0.19 时间戳方案确认

- 每条消息显示时间，不做 5 分钟抑制。
- 默认精简：今天 `23:42`、昨天 `昨天 23:42`、更早 `11月9日 23:42`；日期只在每天第一条。
- 点任意时间：当前聊天统一切换完整格式（周几 + 秒）；再点收回。
- 流式结束后显示；气泡外侧小号灰字；不影响选字/消息菜单。

## 2026-11-11 23:40 · 1.0.19 需求登记

- 用户暂记 1.0.19：这几天先收集问题，不急着开工。
- 第一条需求：聊天界面加时间戳（每条消息/每轮/日期分隔、格式待定）。
- 新增 `BACKLOG.md`；当前基线 `1.0.18+11112142`。

## 2026-11-11 23:25 · 四线收口

- `main` = `phone` = `46e6c0d`；1.0.18 真机验收记录进主分支。
- HANDOFF 75,016 字节，sha256 `3d9028fc…dc1a`；D 盘/飞书同版。
- APK `11112142`；实机 `1.0.18+11112142`；文档表已标 ✅。
- 手机端追加一条开机记忆状态提交，电脑快进 `main` 即完全同 HEAD。

## 2026-11-11 23:20 · 1.0.18 真机验收通过

- 实机覆盖安装 `11111915 → 11112142`（1.0.18），安装前 19:26 的标记仍在，sessions/仓库保留。
- 翻译：直接进 **vivo 翻译**，不再跳浏览器；朗读：0.8× 正常音高。
- 菜单裁剪、问AI填入、聊天页宠物关闭、边缘 24dp 手势维持通过。
- 结论：1.0.18 收口；代码构建提交 `92f683a`，APK sha256 `52f0cdc0…b770`。
- 遗留：电脑把 `phone`（含 1.0.18 修复与开机记忆）合并进 `main`，覆盖 D 盘/飞书。

## 2026-11-11 23:05 · 新对话开机记忆

- 新增 `PROJECT_STATE.md`；`/root/workspace/AGENTS.md` 软链到它，新对话自动加载（已验证）。
- 仓库 `AGENTS.md` 加指针；新增 `tooling/install-workspace-memory.sh`，换机/重装后重建软链。
- 提交 `fc61f66` / `31b0ccd`；电脑合并后新对话即可直接接手。

## 2026-11-11 21:42 · 1.0.18 构建

- `main` ← phone `92f683a`；APK `dsh-go-1.0.18-11112142-mogai-arm64.apk`。
- versionCode `11112142`（> `11111915`），证书 `fb462eb1…`，sha256 `52f0cdc0fe9f99635b2c4608dde663a0809892845bc8735bb81f1314b997b770`。
- `classes.dex` 已含 `com.vivo.translator` 与 `dsh/selection`；`test/chat + test/companion` 2295 通过。
- 电脑侧记录：`5ec9b88`。

## 2026-11-11 19:36 · 1.0.17 安装与真机反馈

- 实机覆盖安装 `11111558 → 11111915`（1.0.17），数据保留；版本名首次按 1.0.17 递增。
- 五项验收：菜单裁剪、问AI、宠物关闭三项通过；**翻译跳到 vivo 浏览器**、**朗读语速太快**两项失败。
- 修复提交 `92f683a`：`SelectionPlugin.kt` 优先 `com.vivo.translator`、排除浏览器；朗读 `rate 0.8 / pitch 1.0`。

## 2026-11-11 18:xx · 1.0.17 功能与构建

- 功能提交 `40d08e3`：自定义选区菜单（复制/全选/翻译 + ⋯ 分享/朗读/问AI）、问AI填入输入框、聊天页宠物关闭、边缘 24dp 手势；文档 `92a0283`。
- 构建 `11111915`（1.0.17），电脑侧 Kotlin `SelectionPlugin.kt` 编译通过，`test/chat` 2152 通过；快捷面板金色图测试起点改为右边缘（`bdee58a`）。
- 手机端 `dart analyze` 0 error / 0 warning / 23 info；选区菜单 10/10、快捷面板 39/39。
