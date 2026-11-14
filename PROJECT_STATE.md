# dsh-Go 项目记忆（新对话先读这一页）

> 最后更新：2026-11-14 19:20（Asia/Shanghai）
>
> 新对话的开机记忆：项目、状态、分工、规则、待办。实现细节看 [`HANDOFF.md`](HANDOFF.md)。
> 本文件是 `/root/workspace/AGENTS.md` 的软链目标，会自动加载。

## 1. 项目是什么

- DeepSeek Harness 的 Android 客户端魔改版：Flutter 原生界面 + 纯 Dart 客户端 + PRoot 里跑 `dsh web` 的引擎。
- 自用、不发布、不跟随官方；自签名（证书 `fb462eb1…3c2f`，keystore `D:\Android\keystore\dsh-go-release.jks`）。
- Gitee 是唯一事实源 `gitee.com/chuyang931914/dsh-go-mogai`；手机端仓库 `/root/workspace/dsh-Go`，电脑构建源 WSL `/root/dsh-Go`。

## 2. 当前状态（以仓库当前提交为准）

- **实机**：`1.0.29+11140932`（2026-11-14 09:47 装）。长按选字拖边缘自动滚已真机验证通过。
- **仓库**：`main` = `phone` = `2fd8d74`，源码版本 `1.0.30+1`，**未出包**（1.0.30 = 唤醒锁 20 分钟兜底超时）。
- **1.0.29 是回退基线**：APK 206,214,152 字节，sha256 `c34fb33c…1ee485`，D 盘与飞书都有。出问题回退到它。
- **1.0.30 待验**：装机后息屏 30 分钟看耗电降幅。
- 已撤出的功能（保险箱、红后灯带、隐藏思考、分层宠物）完整版存档在分支 `archive/1.0.28-full`。

## 3. 双端分工

| 端 | 做什么 | 不做什么 |
| --- | --- | --- |
| 电脑（Windows + WSL `Ubuntu24`） | APK 构建/签名/分发、飞书与 D 盘同步、全量 `flutter test`、金色图重建、上游升级 | 不把没跑过测试的代码推 `main` |
| 手机（Android proot Ubuntu，aarch64） | `dart analyze`、非金色图测试、交叉复跑、文档维护、装机校验、分支整理 | **不构建/不分发 APK**；不重生成金色图 |

手机端环境：Flutter 3.47.7 linux-arm64 `/root/dev/flutter`；`source /root/dev/dsh-env.sh`；字体 `DSH_TEST_FONT_DIR=/usr/share/fonts/opentype/noto`。

## 4. 每次新对话必须先做

1. 读完这一页，再回答项目问题；**不要凭旧对话里的版本/状态直接下结论**。
2. 在仓库里确认当前事实：
   ```bash
   cd /root/workspace/dsh-Go
   git fetch origin
   git log -1 --format='%h %s'
   grep '^version:' app/pubspec.yaml
   ```
3. 需要实现细节、Rules、构建命令时读 `HANDOFF.md`；长期偏好/决策读 `project_memory.md`。
4. 改动前先看工作树/分支/上游，按 HANDOFF 8.3/第十四节走 `phone`；不要动 `main`。
5. **时间必须精确**：回答涉及时间/计时前先运行 `date '+%F %T %Z'`，写精确值；禁止“约/左右/四舍五入”。聊天页时间戳只是 UI，不作为时钟。

## 5. 不可违反的规则

- 编辑/删除任何文件前先完整读取核验；大改先给方案。
- 提交前必须 `cd app && dart analyze` + 受影响目录的非金色图测试；测试没过不说“完成”。
- 文档/代码改动先 commit + 推 Gitee `phone`/`main`，推完才算完成（HANDOFF Rule 33）。
- **不要把 Gitee 令牌、keystore 密码写进文档/仓库/聊天**；凭据在 `~/.git-credentials`（600）。
- **仓库是唯一源头**：手机/电脑的代码、插件源码、界面配置、文档改动都必须提交并推送；只有密钥（`secrets.json`）和 `node_modules/` 例外。
- versionName 按发布 patch +1（当前 1.0.30），versionCode 由构建脚本按 `MMDDHHmm` 生成；APK 名带 versionName + buildNumber。
- 手机端不构建 APK；出包/分发只在电脑侧，走飞书云空间链接。
- 用户偏好：中文、手机屏幕小要简洁；先结论后细节；给绝对路径；不擅自扩大改动范围。

## 6. 当前待办（按顺序）

1. **1.0.30 待出包**：唤醒锁 20 分钟兜底超时 + 选字判定加长按门槛。装后测息屏 30 分钟耗电。
2. **保险箱**：延后，Kotlin 五个坑已记在 `BACKLOG.md`。
3. **AI 费用插件**：`local-ai-cost` 在用；凭据在插件 `secrets.json`（600），不入库。
4. **聊天页宠物**：停做，WIP 在 `pets/layered-v2`。
5. 安全项（令牌/keystore 复用）暂缓，不主动提。

## 7. 最近关键决策

- 聊天页宠物关闭；悬浮窗与设置里的宠物保留。
- 长按菜单只留复制/全选/引用/翻译/分享/朗读/问AI；翻译走 `ACTION_PROCESS_TEXT`，优先 vivo 本体。
- 左边缘 0–80dp 起手翻页，中间禁用。
- 1.0.25–1.0.28 的保险箱/红后/隐藏思考/分层宠物已撤，存档 `archive/1.0.28-full`。
- 1.0.29 定为回退基线。

## 8. 关键路径与命令

```bash
# 手机端
cd /root/workspace/dsh-Go && source /root/dev/dsh-env.sh
cd app && dart analyze && flutter test <受影响目录>

# 电脑端（WSL）
cd /root/dsh-Go && source tooling/env.sh
DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64
```

- 交接 `HANDOFF.md`｜待办 `BACKLOG.md`｜日志 `PROGRESS.md`｜版本表 `UPGRADE_TABLE.md`
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
8. **构建前 `main` 必须等于 `phone`**；手机装完必须跑 `bash tooling/check-device.sh`。
