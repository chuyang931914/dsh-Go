# dsh-Go 魔改版 · 项目交接文档

> 用途：跨设备 / 跨账号 / 跨对话恢复本项目。任何人（或未来的我）拿到这份文档 + 两个仓库地址，就能从零把环境、签名、APK 全部重建出来。
> 最后更新：2026-11-10
> 权威副本：本文件同时放在仓库根目录 `HANDOFF.md`（随 Git 推送，跨设备可用）。

---

## 一、项目是什么

| 项 | 内容 |
| --- | --- |
| 上游项目 | dsh-Go（DeepSeek Harness 的 Android 客户端，Flutter 编写） |
| 上游版本 | 1.0.15（基线提交 `40c73ab`，未改动） |
| 本项目性质 | **个人魔改版**（去统计 / 锁默认模型档位 / 去隐私分享 / 去自动更新 / 关闭关于页入口），自签名，不跟随官方更新 |
| 主仓库（GitHub） | https://github.com/chuyang931914/dsh-Go.git （**默认分支已设为 `mogai`**；原 `main` 保留上游历史镜像） |
| 镜像仓库（Gitee） | https://gitee.com/chuyang931914/dsh-go-mogai.git （`main` = 魔改版，含本交接文档） |
| Git 身份 | `chuyang` / `200414988+chuyang931914@users.noreply.github.com` |
| 分支 | Gitee `main`；GitHub 默认分支 `mogai` |
| 包名 / 版本 | `io.github.ccch1mneyyy.dsh_app`，versionName `1.0.15`，versionCode 由构建脚本按 `MMDDHHmm` 生成（如 11101923） |

**重要：魔改版用自建签名，与官方签名不同 → 官方 APK 覆盖安装会失败，官方"应用内更新"天然装不上（双保险，即使忘了关更新也装不进去）。**

---

## 二、产物在哪

| 产物 | 路径 |
| --- | --- |
| 魔改版 APK（本地） | `D:\Android\apk\dsh-go-1.0.15-mogai-arm64.apk` |
| **APK 下载（飞书云空间，优先）** | https://my.feishu.cn/file/RzcFbpFCyokpPqxVIq5cUI1QnuR （`dsh-go-1.0.15-mogai-arm64.apk`，当前 11102334；点开 → 右上角「...」→ 下载；飞书内直接下载，不走 GitHub/Gitee） |
| **源码包（飞书云空间）** | https://my.feishu.cn/file/IEqgbC77zoOqWmxo277cr8Wdnue （`dsh-go-1.0.15-mogai-src.zip`，500MB；已排除 `.git`、`app/build`、`.dart_tool`、`runtime/.work`、`runtime/.cache`，保留 `runtime/out` 可直接重建 APK） |
| APK 备份（GitHub Release） | https://github.com/chuyang931914/dsh-Go/releases/download/v1.0.15-mogai/dsh-go-1.0.15-mogai-arm64.apk |
| 构建脚本原始输出 | WSL 内 `/root/dsh-Go/app/build/app/outputs/flutter-apk/app-arm64-release.apk` |
| 签名文件 | `D:\Android\keystore\dsh-go-release.jks` |
| 签名备份 | `D:\Android\keystore\backup\`（**务必再备份到网盘/U盘，丢了就无法覆盖升级，只能卸载重装**） |
| 构建源（唯一有效副本） | WSL `Ubuntu24` 内 `/root/dsh-Go` |
| Windows 访问构建源的 UNC 路径 | `\\wsl.localhost\Ubuntu24\root\dsh-Go\`（可直接用编辑器读写） |
| 交接文档（飞书云空间） | https://my.feishu.cn/file/OJSGbqo2IofCYQxm8uycjTGAn7d （`HANDOFF-dsh-Go.md`，每次更新后覆盖上传） |

**最近一次分发（2026-11-10 23:48）**：APK `11102334` + 源码包 + 本交接文档已上传飞书云空间，并已发到「城南」私聊（message_id `om_x100b60078233aca4c1ee6af25da7b07`）。

**当前 APK 与代码的差异（2026-11-11）**：`11102334` 构建于 commit `ee2ff5b`，**不包含**之后提交的「关闭关于 DSH Go 入口」（commit `c0f5f39`）。装上现包仍能在设置里看到「关于 DSH Go」；要看到关闭效果，需按第五节重打 APK 再分发。

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

### 9）上游既有问题（非本项目改动引入，不修）

全仓 `dart analyze`（在 `/root/dsh-Go` 根目录跑）会报 1 万多条，绝大部分来自**上游随仓库带来、但不在任何构建路径上**的独立包脚本，与本项目构建/发版无关：

| 位置 | 问题 | 说明 |
| --- | --- | --- |
| `packages/dsh_client/benchmark/transcript_5000.dart` | `uri_does_not_exist` / `undefined_class` 等（约 10 条） | 上游基准脚本，未把 `dsh_client` 声明为自己的依赖，独立分析必然报错；不属于 `app/` 构建图 |
| `packages/dsh_client/bin/probe.dart` | 同上（约 9 条） | 上游调试脚本，同样缺依赖声明 |
| `app/` 目录内 23 条 `deprecated_member_use`（info 级） | Riverpod `Ref.exists` → 改用 `provider.exist` | 上游写法，仅 info，不影响编译与运行；发版前不做批量改写，避免引入风险 |

因此验收口径固定为 **`cd app && dart analyze`**（结果：23 info、0 error、0 warning），不要用仓库根目录的数字判断是否"有编译错误"。

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

保留：`AboutPage` 仍在 `settings_pages.dart` 的 `_pages` 中（满足 Rules 15，避免空断言崩溃），但已无任何入口；`Spots.version/star/licenses` 定义保留（`AboutPage` 内部仍引用）。

效果：设置页与设置搜索都不再出现「关于 DSH Go」；版本号不再在设置页展示。


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

### 8.2 同步命令（每次改完都推两边）

```bash
cd /root/dsh-Go
git add -A
git commit -m "feat(mod): 去匿名统计/锁新对话默认低/去隐私分享/去自动更新"

# Gitee：直接推 main
git push gitee main

# GitHub：推到 mogai 分支（不要强推 main，会覆盖上游历史）
git push github HEAD:mogai
```

**关键差异（务必记住）**：
- GitHub 仓库 `chuyang931914/dsh-Go` 的 `main` 是**上游项目历史**（镜像/fork），本地仓库与它**历史无关**；直接 `git push github main` 会因 non-fast-forward 被拒，强推会毁掉上游历史。所以魔改只能推 `mogai` 分支。
- Gitee 仓库 `dsh-go-mogai` 是纯魔改仓库，`main` 可以直接推。

- `.git` 约 356MB（含 runtime 等二进制），**首次推送慢是正常的**
- GitHub 直连不稳时可改用镜像域名或开启代理；Gitee 一般直连
- Gitee 仓库名是 `dsh-go-mogai`，**不是** `dsh-Go`，别写错

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
15. **`SettingsPageId` 枚举值必须在 `_pages` 中有对应条目**：`spots.dart` 里 `SettingsIndex.page(id)` 和 `entry(id)` 用 `pages[id]!` 空断言；若某页面 ID（如 `privacy`/`sharedLinks`）只在枚举里但不在 `_pages` 中，任何遍历到它的代码（设置搜索、`SettingsTile(spot: SettingsIndex.entry(...))`）都会崩溃 → 灰屏。魔改剔除页面时，要么把它从 `_rows` 和所有 `SettingsIndex.entry/page()` 调用处移走，要么在 `_pages` 中补一条 `row: false` 的占位。
16. **WSLg 弹窗「无法加载远程桌面服务 ActiveX 控件」**：根因是 WSL 3.0 的 `msrdc.exe`（WSLg 组件）启动时加载 `C:\Program Files\WSL\rdclientax.dll`，该 DLL 依赖新版 `mstscax.dll` 的导出函数，但 Win10 19045 的 `mstscax.dll`（10.0.19041.4522）太旧 → `LoadLibrary` 失败（错误码 127）→ 每次用 WSL 都弹错。**修复**：在 `C:\Users\Administrator\.wslconfig` 写入 `[wsl2]\nguiApplications=false` 禁用 WSLg，然后 `wsl --shutdown`。本项目只用 WSL 命令行构建，不需要 GUI，禁用无影响。若以后要用 WSL GUI，需升级 Windows 或降级 WSL 到 2.x。
17. **关闭页面入口要"三件套"一起改**：① 设置 hub 里的 `SettingsTile`；② `spots.dart` 的 `SettingsPageMeta` + `_rows` 索引项；③ 该页专属的分组标题 l10n、测试断言、`settings_hub_full` 金色图。只删 ① → 搜索仍能搜到（见 Rule 11）；只删 ② → 页面仍从 hub 可达；改了分组标题不重生成金色 → 测试红。已按此完成两次：`privacy`（7-3）、`about`（7-10）。
18. **测试缺 CJK 字体会故意报错，这不是 App 缺陷**：`test/support/test_fonts.dart` 在字体缺失时主动 `throw StateError('Test font missing: ...')`，目的是防止金色图静默使用测试引擎的方块字体。WSL 需 `apt install fonts-noto-cjk`（默认 `/usr/share/fonts/noto-cjk`，需 `NotoSansCJK-{Light,Regular,Bold}.ttc`）。**真机中文由 Android 系统字体兜底，APK 不受影响**。装好后 `fc-match` 命中的是 Light 字重，与基准图可能有细微差（本次遇到 11% 像素差），统一用 `flutter test --update-goldens <file>` 重新生成，不要手改 PNG。l10n 改动要先跑 `python3 tool/l10n_merge.py` 再 `flutter gen-l10n`，否则生成物不更新。
19. **【重要】所有改动在交付/提交前必须先跑测试**：至少 `cd app && dart analyze` + 受影响目录的 `flutter test`（改设置类跑 `test/settings`，改聊天类跑 `test/chat`，改更新类跑 `test/update`）。测试未通过不得提交、不得说"完成"。全量 `flutter test` 较慢，按改动面选目录，但不能只凭"看起来没问题"。
20. **【重要】用户以「重要：」开头的指令，必须同步写入文档**：既写本文件（HANDOFF，随 commit 推送并覆盖上传飞书），也写长期记忆 `project_memory.md`；不能只停留在对话里。

---

## 十、版本策略

- 版本名跟随上游（当前 `1.0.15`），build number 由 `build-apk.sh` 按 `MMDDHHmm` 生成（例：`11101923` = 11-10 19:23，构建日志首行会打印 `dsh-go 1.0.15 (11101923, ...)`）。
- 由于已剔除自动更新，**发版不再需要考虑官方版本号**；只要 build number 递增即可正常覆盖安装。
- 命名建议：`dsh-go-<版本号>-mogai-arm64.apk`。

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

1. 备份 keystore 到网盘 + U 盘各一份（最高优先级，丢失不可逆）。
2. 若要继续魔改，优先"禁用 + 去入口"，尽量不删文件，减少上游 rebase 冲突。
3. 上游升级时：以新版本为基线重新打 4 处补丁（补丁点见第七节），保留本仓库 commit 作为参考。
4. 重打 APK（含 commit `c0f5f39` 的「关于页关闭」）→ 上传飞书云空间覆盖同名文件 → 按第十一节逐条验收。

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

