# 回退剧本

> 回退基线：`1.0.29` / buildNumber `11140932`，D 盘与飞书都有。
> **状态：未演练。** 本文是根据 Android 安装规则推演的第一版，真机验证前不算数。

## 关键限制：Android 不允许降级安装

`versionCode` 比已装版本低时，系统默认拒绝（`INSTALL_FAILED_VERSION_DOWNGRADE`）。1.0.29 的 `11140932` 低于 1.0.30 的 `11142005`，所以**直接点开旧 APK 安装会失败**。

三条可行路径：

| 路径 | 数据 | 需要 |
|---|---|---|
| `adb install -r -d <apk>` | 保留 | adb 或 Shizuku |
| 卸载后装旧的 | **全丢**（会话、设置、引擎） | 无 |
| 不动版本，修 bug 出下个 patch | 保留 | 一次出包 |

## 演练步骤（约 20 分钟）

1. 确认 1.0.29 APK 在手：`/sdcard/Download/Lark/` 或 D 盘，核对 208,016,832~839 字节区间与 sha256 前缀 `c34fb33c`。
2. 记录当前会话数与设置项（至少 `ui.json` 内容），用于比对是否丢数据。
3. 走路径一：`adb install -r -d`（或 Shizuku 的 shell）。
   - 成功：版本回落 `11140932`，数据在 → 回退可用，记入本文。
   - 失败：记下错误码，改走路径二，并在演练记录里写明「回退会丢数据」。
4. 装回最新版（正向覆盖，不受限制）。
5. 把结论写进 `PROGRESS.md` 与本文顶部状态。

## 已知结论

- 正向升级（versionCode 变大）一直正常，1.0.27→1.0.28→1.0.29→1.0.30 都是覆盖安装，数据保留。
- 降级未验证。没验证之前，「1.0.29 是回退基线」只是意图，不是能力。

## 演练记录

（第一次演练后在此写：日期 / 走的哪条路 / 数据是否保留 / 耗时）

## 2026-11-14 22:57 · 交接：实机从 1.0.31 回 1.0.30

给电脑端 Agent 的一段话：**目标是让手机回到 1.0.30 行为，尽量不丢数据。按下面的路径 A 出包**。别直接让用户点 1.0.30 的旧 APK——`versionCode 11142005 < 11142142`，系统会拒绝。

### 当前事实

- 实机：`1.0.31+11142142`；仓库 `main`=`phone`=注意以 `git log -1` 为准（写本文时 `5427be1`，工作区干净）。
- 1.0.30 源码树：提交 `52ad553`，`app/pubspec.yaml` = `1.0.30+1`。1.0.31 只在其上加了 v1.0.16 资源自愈（Kotlin + 单测），出包提交 `c9a1547`。
- 1.0.30 的 APK：`D:\Android\apk\dsh-go-1.0.30-11142005-mogai-arm64.apk`，206,213,645 字节，sha256 `cc712b78…f15eed`。
- 手机本地**只有** `dsh-go-1.0.27-11131822` 的包；1.0.29/1.0.30/1.0.31 的 APK 都不在手机上，1.0.31 的飞书 token 从本机请求是 404。

### 推荐路径 A：用 1.0.30 源码重出包（不丢数据，绕开降级限制）

1. WSL：`cd /root/dsh-Go && git fetch origin`，从 `52ad553` 建分支（`git switch -c rel/1.0.30 52ad553`）。
2. 确认 `app/pubspec.yaml` 是 `1.0.30+1`；**不用改版本号**，`versionCode` 由 `build_number.py` 按 `MMDDHHmm` 生成，新值必然大于 `11142142`，属于正向覆盖安装。
3. `DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64`，产物形如 `dsh-go-1.0.30-<新buildNumber>-mogai-arm64.apk`。
4. 传手机 `/sdcard/Download/Lark/`，核对字节数；手机端 `bash tooling/check-device.sh` 应显示新的 `1114xxxx`，版本仍是 1.0.30。
5. 数据（会话、工作区、`ui.json`、插件链接）应全部保留。

### 路径 B：卸载重装旧包（丢数据，不推荐）

卸载会删会话、工作区、界面配置、插件安装链接和技能副本；需要用户明确同意。只在 A 不可行时用。

### 路径 C：保留数据的降级安装

手机开「手机操控 → Android Shell」（Shizuku/自连 ADB），`pm install -r -d /sdcard/Download/Lark/<1.0.30.apk>`。需要用户先授权 shell；失败时记错误码，不重试。

### 装完要验

- `bash tooling/check-device.sh` → `installed` 的 versionCode 正确、版本 1.0.30。
- 选字拖边缘滚动（1.0.30 的核心修复）。
- 会话/工作区/`ui.json` 是否还在（A/C 应保留）。
- 结果写 `PROGRESS.md` + `UPGRADE_TABLE.md`（新增一行该 buildNumber）+ `PROJECT_STATE.md` 第 2 节。

### 附带说明

- 技能文本审查的改动已全部 revert（`5427be1`），技能回到审计前原文，不用再动。
- `python3 app/tool/guide_sync.py --check` 现在是红的（`docs/guide/README.md` 写 1.0.30，而当前 `pubspec` 是 1.0.31）。**切到 `52ad553` 后两边都是 1.0.30，这条会自己变绿。**
- `1.0.32` 排期（工具输出折叠 + 1b 精简版）在 `BACKLOG.md`，与这次回退互不阻塞；回退完成后按需再开。
