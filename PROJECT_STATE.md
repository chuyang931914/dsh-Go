# dsh-Go 项目记忆（新对话先读这一页）

> 最后更新：2026-11-14 22:35（Asia/Shanghai）
>
> 新对话的开机记忆：项目、状态、分工、规则、待办。实现细节看 [`HANDOFF.md`](HANDOFF.md)。
> 本文件是 `/root/workspace/AGENTS.md` 的软链目标，会自动加载。

## 1. 项目是什么

- DeepSeek Harness 的 Android 客户端魔改版：Flutter 原生界面 + 纯 Dart 客户端 + PRoot 里跑 `dsh web` 的引擎。
- 自用、不发布、不跟随官方；自签名（证书 `fb462eb1…3c2f`，keystore `D:\Android\keystore\dsh-go-release.jks`）。
- Gitee 是唯一事实源 `gitee.com/chuyang931914/dsh-go-mogai`；手机端仓库 `/root/workspace/dsh-Go`，电脑构建源 WSL `/root/dsh-Go`。

## 2. 当前状态（以仓库当前提交为准）

- **实机**：`1.0.31+11142142`（22:07 前装，22:35 验完）；开关/桥接能自恢复，无障碍不自动重连（22:33 定暂不补）。
- **仓库**：`main`=`phone`=`8dd9e2c`，源码 `1.0.31+1`，buildNumber `11142142`。
- **1.0.31 包**：APK 206,213,828B sha256 `d2cc740b…f3d8e9`；analyze 0 err/24 info，test/chat 1969 全绿。
- **内容**：上游 v1.0.16 资源自愈（+5 单测）：后台屏断连自恢复、无 displayId 孤儿记录可结案。
- **验收**：1a 自愈路径未触发（无后台屏在跑）；息屏耗电免测。
- **1.0.32**：工具输出折叠（`c08f1cff`+`728f1689`）+ 1b 精简版（只摘「升级后不复用旧服务」）。
- **未摘上游**：tawcroot（不能摘）。回退基线 1.0.29（`c34fb33c…1ee485`）；旧功能存档 `archive/1.0.28-full`。

## 3. 双端分工

| 端 | 做什么 | 不做什么 |
| --- | --- | --- |
| 电脑（WSL） | 构建/签名/分发、飞书与 D 盘、全量测试、金色图 | 不推没测过的代码到 `main` |
| 手机（proot aarch64） | `dart analyze`、非金色图测试、文档、装机校验 | **不构建/不分发 APK** |

手机端环境：Flutter 3.47.7 linux-arm64 `/root/dev/flutter`；`source /root/dev/dsh-env.sh`；字体 `DSH_TEST_FONT_DIR=/usr/share/fonts/opentype/noto`。

## 4. 每次新对话必须先做

1. 读完这页，别凭旧聊天猜状态。
2. 核对事实：`bash tooling/repo-check.sh`（分支、版本、文档一致性一把查）。
3. 实现细节读 `HANDOFF.md`；长期偏好读 `project_memory.md`。
4. 改动走 `phone`，不动 `main`；时间先跑 `date '+%F %T %Z'`，写精确值。

## 5. 不可违反的规则

- 编辑/删除任何文件前先完整读取核验；大改先给方案。
- 提交前必须 `cd app && dart analyze` + 受影响目录的非金色图测试；测试没过不说“完成”。
- 文档/代码改动先 commit + 推 Gitee `phone`/`main`，推完才算完成（HANDOFF Rule 33）。
- **不要把 Gitee 令牌、keystore 密码写进文档/仓库/聊天**；凭据在 `~/.git-credentials`（600）。
- **仓库是唯一源头**：手机/电脑的代码、插件源码、界面配置、文档改动都必须提交并推送；只有密钥（`secrets.json`）和 `node_modules/` 例外。
- versionName 按发布 patch +1（当前 1.0.31），versionCode 由构建脚本按 `MMDDHHmm` 生成；APK 名带 versionName + buildNumber。
- 手机端不构建 APK；出包/分发只在电脑侧，走飞书云空间链接。
- 用户偏好：中文、手机屏幕小要简洁；先结论后细节；给绝对路径；不擅自扩大改动范围。

## 6. 当前待办（按顺序）

1. **1.0.32**：工具输出折叠（`c08f1cff`+`728f1689`）+ 1b 精简版（只摘「升级后不复用旧服务」）；装机验升级后手机操控不掉线、超长输出折叠。
2. **AI 费用插件**：`local-ai-cost` 在用；凭据在插件 `secrets.json`（600），不入库。
3. **聊天页宠物**：停做，本地分支已删（代码仍在 `archive/1.0.28-full`）。
4. **密钥保险箱**：2026-11-14 决定**不做**，撤出。
5. 安全项（令牌/keystore 复用）暂缓，不主动提。

## 7. 最近关键决策

- 宠物关闭（悬浮窗/设置保留）；长按菜单留复制/全选/引用/翻译/分享/朗读/问AI，翻译走 `ACTION_PROCESS_TEXT`。
- 左边缘 0–80dp 起手翻页；保险箱/红后/隐藏思考/分层宠物已撤（存档 `archive/1.0.28-full`）；1.0.29 为回退基线。
- 2026-11-14 22:33：无障碍自动恢复暂不补；1.0.30/1.0.31 息屏耗电免测。

## 8. 关键路径与命令

```bash
# 手机端
cd /root/workspace/dsh-Go && source /root/dev/dsh-env.sh
cd app && dart analyze && flutter test <受影响目录>

# 电脑端（WSL）
cd /root/dsh-Go && source tooling/env.sh
DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64
```

- 交接 `HANDOFF.md`｜待办 `BACKLOG.md`｜日志 `PROGRESS.md`｜版本表 `UPGRADE_TABLE.md`｜装机 `tooling/acceptance-phone.md`｜回退 `docs/rollback.md`
- 飞书 APK：`https://my.feishu.cn/file/RzcFbpFCyokpPqxVIq5cUI1QnuR`

## 9. 维护这一页

- 上限 6KB。发版、装机、重要决策后更新第 2、6 节，与 `HANDOFF.md` 同一次提交推送。
- 电脑端：`DSH_WORKSPACE=/root/workspace bash /root/dsh-Go/tooling/install-workspace-memory.sh` 重建软链。

## 11. 每轮固定动作（防漂移）

1. 手机改：`dart analyze` + 受影响非金色测试 → commit → push `phone`；插件源码、`config/ui.json`、文档同一轮入库。
2. 电脑：`git fetch` → `git merge --ff-only origin/phone` → 测试通过才构建；构建后更新 HANDOFF 并同步 D 盘/飞书。
3. 手机装：先记 baseline → 覆盖安装 → `bash tooling/check-device.sh` → 按本轮清单验 → 结果写 PROGRESS/PROJECT_STATE。
4. 新对话先 `git pull` + `bash tooling/check-device.sh`，读第 2、6 节；不从旧聊天猜版本/配置。
5. 一轮只收一个主题；版本号只在构建时 +1；未验证不写“收口”。
6. **有红测试不出包**：要么修到全绿，要么在 HANDOFF 明确写 waiver 和风险；默认不允许带红构建。
7. **出包后同一版本不再改代码**：任何修复进下一个 patch，避免 1.0.22→1.0.23 这种返工。
