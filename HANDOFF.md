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
| 本项目性质 | **个人魔改版**（去统计 / 锁默认模型档位 / 去隐私分享 / 去自动更新），自签名，不跟随官方更新 |
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
| **APK 下载（飞书云空间，优先）** | https://my.feishu.cn/file/RzcFbpFCyokpPqxVIq5cUI1QnuR （点开 → 右上角「...」→ 下载；飞书内直接下载，不走 GitHub/Gitee） |
| APK 备份（GitHub Release） | https://github.com/chuyang931914/dsh-Go/releases/download/v1.0.15-mogai/dsh-go-1.0.15-mogai-arm64.apk |
| 构建脚本原始输出 | WSL 内 `/root/dsh-Go/app/build/app/outputs/flutter-apk/app-arm64-release.apk` |
| 签名文件 | `D:\Android\keystore\dsh-go-release.jks` |
| 签名备份 | `D:\Android\keystore\backup\`（**务必再备份到网盘/U盘，丢了就无法覆盖升级，只能卸载重装**） |
| 构建源（唯一有效副本） | WSL `Ubuntu24` 内 `/root/dsh-Go` |
| Windows 访问构建源的 UNC 路径 | `\\wsl.localhost\Ubuntu24\root\dsh-Go\`（可直接用编辑器读写） |

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

改动全部在 `/root/dsh-Go/app` 下，共 12 个文件。

### 1）剔除「发送匿名使用统计」

| 文件 | 改动 |
| --- | --- |
| `lib/usage/usage_stats.dart` | `build()` 不再调用 `_watch()`（删掉该方法及 `_engineMode`）；`_load()` 直接置 `enabled:false, noticed:true`，不读开关、不读落盘账本；清理不再使用的 import |
| `lib/usage/usage_net.dart` | `UsageBuild.active` 恒为 `false`（原为 `kReleaseMode \|\| ...`），从源头拦截所有统计上报入口；移除不再使用的 `flutter/foundation.dart` import |
| `lib/ui/onboarding/welcome_page.dart` | 首屏移除 `UsageNoticeRow()` 及 import（不再出现统计告知条） |
| 隐私页整体移除后，`UsageStatsSection` 随之不可达 | 文件保留但无入口 |

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
| `lib/ui/settings/index/spots.dart` | 从 `_rows` 中移除 `Spots.shareConfig` / `Spots.usageStats` / `Spots.chatLogUpload`（这三个的 `page=privacy` 不在 `_pages` 中，若留在 `_rows` 会导致设置搜索遍历时 `pages[privacy]!` 空断言崩溃 → 灰屏）。`SettingsPageId.privacy` / `sharedLinks` 枚举值与 `Spots` 定义保留，供仍可达的 widget 使用 |
| `lib/ui/share_hosted/hosted_links_tile.dart` | `SettingsTile` 的 `spot:` 从 `SettingsIndex.entry(SettingsPageId.sharedLinks)` 改为直接传 `title:`（`sharedLinks` 不在 `_pages` 中，`entry()` 会崩溃） |

被一并"隐藏"的功能（页面文件仍在，但无入口）：
- 分享链接管理（`HostedLinksTile`）
- 分享配置（`showShareProfileSheet`）
- 匿名统计开关（`UsageStatsSection`）
- 本地 OCR 声明入口
- 聊天记录上传开关（`session-log-deepseek`）

> 保留 `privacy_page.dart` 与 `SettingsPageId` 枚举值，是为了不牵连其它引用；页面本身不可达。
> **注意**：`privacy` / `sharedLinks` 不在 `_pages` 中，任何调用 `SettingsIndex.page(privacy/sharedLinks)` 或 `SettingsIndex.entry()` 的代码都会崩溃。新增代码时务必避开。

### 4）剔除自动更新

| 文件 | 改动 |
| --- | --- |
| `lib/state/update_state.dart` | `autoCheck` 恒为 `false`（不再读 prefs）；`autoCheckIfDue()` 直接 `return false`，启动时不做任何检查 |
| `lib/ui/settings/about_page.dart` | 移除 `AppUpdateTiles()`（关于页不再有"检查更新/下载"入口） |
| `lib/ui/settings/settings_screen.dart` | 关于入口不再显示 `UpdateBadge`，只显示当前版本号 |
| `app/android/app/src/main/AndroidManifest.xml` | 删除 `REQUEST_INSTALL_PACKAGES` 权限（不再具备安装 APK 的能力） |

效果：不自动检查、不提示、不下载、不能安装更新；关于页只剩版本号。

### 5）聊天界面模型选择器归位（仅打字时在输入框底部显示）

| 文件 | 改动 |
| --- | --- |
| `lib/ui/chat/chat_screen.dart` | 窄屏下 `ChatHeader.trailing` 恒为 `null`（不再在顶栏右上角显示 `ModelChip`）；宽屏保持顶栏显示。模型切换由输入框底部的 `ComposerModelPill` 承接，且仅在打字（键盘弹出）时可见 |

效果：窄屏顶栏干净；模型胶囊回到输入框底部，点击输入框打字时出现，与官方 DeepSeek 位置一致；默认思考强度仍为「低」。

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
git -c http.version=HTTP/1.1 push github main:refs/heads/mogai
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

---

## 十、版本策略

- 版本名跟随上游（当前 `1.0.15`），build number 由 `build-apk.sh` 按 `MMDDHHmm` 生成（例：`11101923` = 11-10 19:23，构建日志首行会打印 `dsh-go 1.0.15 (11101923, ...)`）。
- 由于已剔除自动更新，**发版不再需要考虑官方版本号**；只要 build number 递增即可正常覆盖安装。
- 命名建议：`dsh-go-<版本号>-mogai-arm64.apk`。

---

## 十一、装机后验收清单

- [ ] 首次启动首屏**没有**"匿名使用统计"告知条
- [ ] 设置 → 通用：**没有**「隐私与分享」
- [ ] 设置 → 关于：**没有**"检查更新"；版本号可正常显示
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
