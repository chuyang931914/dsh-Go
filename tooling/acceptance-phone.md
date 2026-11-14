# 手机端装机验收剧本

> 2026-11-14 定稿。1.0.30 装机时实测走通，固化成流程。
> 执行人：手机侧 Agent（有 `mcp__phone__*` 无障碍工具时）；没有工具就退化成「指挥用户点」。
> 每条命令后面是「成功长什么样」。任一步不对就停下记录，不硬推。

## 0 · 前置

```bash
cd /root/workspace/dsh-Go && bash tooling/repo-check.sh
```
- 期望 `RESULT OK`；分支 `phone`，`main` = `phone`，工作区干净。

```bash
bash tooling/check-device.sh | grep installed
```
- 记下当前 versionCode 作为**装机基线**，后面对比。

## 1 · 核包

```bash
f=/sdcard/Download/Lark/dsh-go-<版本>-<buildNumber>-mogai-arm64.apk
sha256sum "$f"; du -b "$f"
```
- 与 `UPGRADE_TABLE.md` 里的 sha256 前缀、字节数逐位对上。对不上就不装。

## 2 · 装机

- 系统限制：手机侧无法自己发起安装（`android_shell` 未开、`file://` 打不开、文件管理落进安全页）。
- **交用户点一次**：让用户点开 APK，安装界面弹出后停手。
- 安装器页面可读可点，后续确认由 Agent 接管（必要时 `tap` 安装按钮）。

## 3 · 装后核验

```bash
bash tooling/check-device.sh | grep installed
```
- versionCode 必须等于新 buildNumber，且大于旧值（否则是覆盖失败，退回上一步）。

## 4 · 功能清单

按本版改动逐条验。记录格式：项 / 结果 / 证据（截图或用户一句话）。

- 交互类（选字、手势、菜单）：**Agent 不代点**，让用户试 10 秒，回一句结果。理由：手感是主观的，Agent 点不出「有没有变迟钝」。
- 状态类（版本、设置项、权限开关）：Agent 自己读屏核。

## 5 · 耗电

```
intent(settings, page=battery) → 读「当前电量X%」+ 时间
```
- 息屏 30 分钟后复读一次，差值即待机功耗。
- **注意**：电池健康低于 80% 时，数字偏大是硬件，不是软件回归。1.0.30 时该机健康 70%。

## 6 · 回退

- 出问题回退到 `UPGRADE_TABLE.md` 里标「回退基线」的那版（当前 1.0.29 / `11140932`）。
- 回退要在 `PROGRESS.md` 记一行原因。

## 7 · 落记录（三处都要）

1. `UPGRADE_TABLE.md`：该版「装机」列改 `✅ 已装 HH:MM`，备注写验证结论。
2. `PROGRESS.md`：顶部加一条，写装机时间、包大小 sha256、验了什么、剩什么。
3. `PROJECT_STATE.md` 第 2 节：实机版本改成新版本。
4. 然后 `bash tooling/repo-check.sh`，`pre-push` 通过再推。

## 已知限制

- 电池实际数值、后台唤醒状态读不到（proot 无 `dumpsys`、`/sys/class/power_supply` 不可读），只能靠系统设置页读电量。
- 金色图在手机端永远红（字体漂移），手机侧只跑非金色图：`bash tooling/test-phone.sh`。
