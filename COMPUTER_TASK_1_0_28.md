# 电脑端任务书 · 1.0.28 出包

用法：把下面整个代码块复制到电脑端（Windows + WSL）新对话，整段发送；看到 `<PHONE_SHA>` 先换成手机端 `phone` 最新提交号再发。
每一步都写了「成功长什么样」，输出对不上就停在原地，把整段输出贴回对话，不要跳步、不要自己改命令。

```
# 电脑端任务书 · 1.0.28 出包

## 任务
你是电脑端（Windows + WSL，构建源 `/root/dsh-Go`）的 AI 助手。把 dsh-Go 1.0.28 出包做完：快进 main → 测试 → 构建签名 APK → 同步七处 → 按格式回报。主人不是工程师，你按步骤执行，不跳步，不顺手改别的。

## 一、背景（先读完）
- 手机端已把 origin/main 合进 phone，带回两个提交：`854b47d`（密钥保险箱 ActivityResult 回调修复）、`05865ff`（build-apk.sh 新增 --push-main）。phone 最新提交 = `<PHONE_SHA>`。
- 版本 `app/pubspec.yaml` = `1.0.28+1`；versionCode 由构建分钟生成，必须大于 `11131822`（1.0.27 已装机）。
- 1.0.28 内容：① 选字拖到边缘自动滚动改全局指针路由（1.0.27 失效）；② 密钥保险箱 `app/android/app/src/main/kotlin/io/github/ccch1mneyyy/dsh_app/vault/VaultPlugin.kt`（Keystore 绑锁屏、截屏保护、硬件密钥自检）；③ 隐藏思考过程；④ 红后模式降级成标题栏下沿 2px 状态灯带（生成绿/失败红，原 `hacker_tint.dart` 半屏字符雨已删）；⑤ 唤醒锁按需（启动不拿，生成中 setBusy）。
- 硬边界：不开 R8 / minify / 混淆 / 裁剪；不 reset、不 force push、不改写历史；构建前 main 必须等于 phone；有红测试不出包；出包后同版本不再改代码。
- 本轮只做出包和同步，不接新需求；有别的想法先记下，回来再说。

## 二、一步一条命令
说明：命令都在 WSL 里执行，`cd /root/dsh-Go` 就是构建源；命令里的 `<buildNumber>` 等构建完再替换。

### 步 1 进仓库，确认工作树干净
命令：`cd /root/dsh-Go && git status --porcelain; git branch --show-current`
成功长什么样：先没有任何文件行，再打印 `main`。
不对就停：有改动或分支不是 main，贴回 `git status`，不要 stash、不要 checkout 覆盖。

### 步 2 拉最新（main 和 phone 都要拉）
命令：`cd /root/dsh-Go && git fetch origin main phone`
成功长什么样：没有 `fatal` / `error`，正常回到提示符。
说明：本仓库 remote.origin.fetch 只映射 main，不显式拉 phone 会拿到旧提交。

### 步 3 核对 phone 指向
命令：`cd /root/dsh-Go && git rev-parse origin/phone && git merge-base --is-ancestor 854b47d origin/phone && git merge-base --is-ancestor 05865ff origin/phone && echo FIXES_IN`
成功长什么样：40 位 sha 等于 `<PHONE_SHA>`，最后打印 `FIXES_IN`。
不对就停：不一致，贴回这两条输出。

### 步 4 确认 main 是 phone 的祖先
命令：`cd /root/dsh-Go && git merge-base --is-ancestor main origin/phone; echo EXIT=$?`
成功长什么样：`EXIT=0`。
不对就停：`EXIT=1` 表示 main 有 phone 没有的提交，禁止 reset / force push；贴回 `git status` 和 `git log --oneline -5`。

### 步 5 main 快进到 phone
命令：`cd /root/dsh-Go && git switch main && git merge --ff-only origin/phone && git rev-parse HEAD`
成功长什么样：输出 `Fast-forward` 或 `Already up to date`，并且最后那行 sha 等于步 3 的 sha。
不对就停：出现 `Not possible to fast-forward` 或冲突，立刻停，贴 `git status` + `git log --oneline -5`；不要造 merge 提交，不要强推。

### 步 6 准备工具链
命令：`cd /root/dsh-Go && source tooling/env.sh && flutter --version | head -2 && java -version 2>&1 | head -1`
成功长什么样：Flutter 3.47.7；Java 17。
不对就停：找不到 flutter/java 或 `tooling/env.sh` 不存在，贴回输出，不要自己改 PATH。

### 步 7 静态检查
命令：`cd /root/dsh-Go/app && dart analyze`
成功长什么样：`No issues found!`，或 24 条左右且全是 info（0 error / 0 warning）。info 数变了没关系，报告实际数字。
不对就停：有 error / warning，贴完整输出（不要用 `| tail` 截断）。

### 步 8 跑聊天测试
命令：`cd /root/dsh-Go/app && flutter test test/chat > /tmp/test_chat_1028.log 2>&1; tail -25 /tmp/test_chat_1028.log`
成功长什么样：`All tests passed!`，0 failed；通过数报实际值（1.0.27 基线 1970，1.0.28 隐藏思考可能增删用例）。
不对就停：有失败先贴 `Some tests failed` + 失败文件名单。只有 golden（图片像素）失败时也不要自己 `--update-goldens`；先贴回，确认是「思考行删除 / 灯带」造成的预期差异后，才在电脑侧重建设受影响的 PNG，单独 commit 推 phone 再重来。产品代码不许为了转绿改回去。

### 步 9 构建 1.0.28（第一次可能 10 分钟以上）
命令：`cd /root/dsh-Go && DSH_BETA_TOKEN_FILE= bash tooling/build-apk.sh -f arm64 --push-main > /tmp/build_1028.log 2>&1; tail -30 /tmp/build_1028.log`
成功长什么样：日志里有 `dsh-go 1.0.28 (<buildNumber>, ...)`、APK 路径 `app/build/app/outputs/flutter-apk/app-arm64-release.apk`，最后一行 `verified: main = ... (remote matches)`。
说明：`DSH_BETA_TOKEN_FILE=` 置空 = 不注入 beta token；`--push-main` 构建后推 main，再用 ls-remote 读回校验，不一致自动重试一次，还不行非 0 退出。
盯进度：构建超过 5 分钟就放后台跑，别让命令被超时杀掉；超过 3 分钟没新输出，先 `tail -5 /tmp/build_1028.log` 和看进程，先报状态再继续。

### 步 10 首次构建 Kotlin 报错（大概率，先接受）
- 预期出错点：`vault/VaultPlugin.kt`、`DshService` 的 `ACTION_BUSY`、`RuntimePlugin` 的 `setBusy`——这三处手机端从没编译过，这是第一次。
- 第一动作：把 `/tmp/build_1028.log` 里 `e: file:///...` 开头的 Kotlin 报错整段贴回，不许只贴最后一行；报错不是 Kotlin（Gradle / 资源 / Manifest）也一样，先贴完整日志。
- 改法：一次只改一处（一个文件、一个错误）；不顺手格式化、不重构、不动 gradle 的 minify/R8、不升级依赖、不删功能换编译通过。R8 / 混淆 / 裁剪本轮绝不开，等 1.0.28 装机通过后再单开一轮（记在 BACKLOG，别顺手开）。
- 改完必须推 phone 再重来，链路见步 11–15。同一错误改两次还不好，停下贴日志，不要盲改。

### 步 11 切到 phone 修一处
命令：`cd /root/dsh-Go && git switch phone && git merge --ff-only main`
成功长什么样：`Already up to date` 或 `Fast-forward`，HEAD 与 main 同 sha。
说明：本地没有 phone 分支时，先跑 `git switch -c phone --track origin/phone`；phone 是唯一往上推的分支，main 只做快进。

### 步 12 只提交这一处
命令：`cd /root/dsh-Go && git add <改的那一个文件> && git commit -m "fix(vault): 一句话说明"`
成功长什么样：`1 file changed`。
注意：只 add 改的那个文件，不用 `git add .` / `git add -A`。

### 步 13 推 phone
命令：`cd /root/dsh-Go && git push origin phone`
成功长什么样：`phone -> phone`，没有 `rejected`。

### 步 14 核对远端 phone（push 会假成功）
命令：`cd /root/dsh-Go && test "$(git ls-remote origin phone | cut -f1)" = "$(git rev-parse HEAD)" && echo PHONE_PUSH_OK`
成功长什么样：`PHONE_PUSH_OK`。
不对就停：没有 PHONE_PUSH_OK，贴回两条 sha，不要 force push。

### 步 15 main 再快进，回步 9 重新构建
命令：`cd /root/dsh-Go && git switch main && git fetch origin phone && git merge --ff-only origin/phone`
成功长什么样：`Fast-forward` 或 `Already up to date`，HEAD 等于步 14 的 sha。
然后回到步 9。一次只改一处，不要攒一堆改再构建。

## 三、出包后核对产物

### 步 16 读大小和 sha256
命令：`cd /root/dsh-Go && stat -c '%s bytes' app/build/app/outputs/flutter-apk/app-arm64-release.apk && sha256sum app/build/app/outputs/flutter-apk/app-arm64-release.apk`
成功长什么样：大小约 2.08 亿字节（1.0.27 是 208,016,839），sha256 是 64 位十六进制。都记下来。

### 步 17 核对版本号
命令：`cd /root/dsh-Go && /root/dev/android-sdk/build-tools/36.0.0/aapt2 dump badging app/build/app/outputs/flutter-apk/app-arm64-release.apk | head -1`
成功长什么样：`versionCode='<buildNumber>' versionName='1.0.28'`，且 buildNumber > 11131822。
说明：build-apk.sh 内部也会校验，这一步是复核给人看。

### 步 18 验签
命令：`cd /root/dsh-Go && source tooling/env.sh && /root/dev/android-sdk/build-tools/36.0.0/apksigner verify --print-certs app/build/app/outputs/flutter-apk/app-arm64-release.apk | grep SHA-256`
成功长什么样：`fb462eb107bea90a9a092ea4e280dbd003625df03a07dbf168cf26425aa03c2f`。
不对就停：指纹不是 `fb462eb1…`，说明用错 keystore，停下，别发。

### 步 19 复制 APK 到 D 盘
命令：`cd /root/dsh-Go && cp app/build/app/outputs/flutter-apk/app-arm64-release.apk "/mnt/d/Android/apk/dsh-go-1.0.28-<buildNumber>-mogai-arm64.apk"`
成功长什么样：`ls -l /mnt/d/Android/apk/dsh-go-1.0.28-*.apk` 显示同字节数。

## 四、同步七处
七处 = HANDOFF.md、UPGRADE_TABLE.md、PROJECT_STATE.md、PROGRESS.md、D 盘、飞书 HANDOFF、飞书 APK 标题。前四处是仓库文档，一起提交；D 盘是 APK + HANDOFF.md 两份。

### 步 20 改仓库四处文档（手工编辑）
1) HANDOFF.md：「二、产物在哪」加一条构建记录（日期时间、1.0.28、buildNumber、大小、sha256、证书、analyze/测试数字、main ← phone）；再加一条分发记录（飞书覆盖，标题 `dsh-go-1.0.28-<buildNumber>-mogai-arm64.apk`，链接不变）；「十、版本策略」映射表补 1.0.28 行。
2) UPGRADE_TABLE.md：1.0.28 行「待构建」改成实际 buildNumber、日期，装机列写 `⏳ 待装`，备注补 sha256 前 8 后 5 和字节数；下面「APK 记录」表也加一行（大小 / sha256 前 8 后 5 / 飞书 token）。
3) PROJECT_STATE.md：第 2 节写「实机仍 1.0.27，1.0.28+<buildNumber> 已构建待装」+ APK 信息；第 6 节第 1 条改「待装机」。
4) PROGRESS.md：最上面加一条 `## 日期 时间 · 1.0.28 出包`，写 buildNumber、大小、sha、测试数、待装。
核对命令：`cd /root/dsh-Go && grep -n "1.0.28" HANDOFF.md UPGRADE_TABLE.md PROJECT_STATE.md PROGRESS.md | head -20`
成功长什么样：四处都能看到 1.0.28 和 buildNumber。

### 步 21 提交并推文档
命令：`cd /root/dsh-Go && git add HANDOFF.md UPGRADE_TABLE.md PROJECT_STATE.md PROGRESS.md && git commit -m "docs: 1.0.28 出包记录" && git push origin main`
成功长什么样：`main -> main`。

### 步 22 核对远端 main
命令：`cd /root/dsh-Go && test "$(git ls-remote origin main | cut -f1)" = "$(git rev-parse HEAD)" && echo MAIN_PUSH_OK`
成功长什么样：`MAIN_PUSH_OK`。
不对就停：不要 force push，贴回两条 sha。

### 步 23 D 盘 HANDOFF
命令：`cp /root/dsh-Go/HANDOFF.md /mnt/d/HANDOFF.md && grep -c "1.0.28" /mnt/d/HANDOFF.md`
成功长什么样：输出 ≥1（不是 0）。

### 步 24 飞书 HANDOFF
命令：`lark-cli drive +upload --help`
成功长什么样：先打印出上传参数的用法；覆盖原文件 token `OJSGbqo2IofCYQxm8uycjTGAn7d`（文件 `HANDOFF-dsh-Go.md`）后，链接仍是 `https://my.feishu.cn/file/OJSGbqo2IofCYQxm8uycjTGAn7d`，打开是新版本。
禁止：新建文件、换链接、换 bot。
不对就停：报授权过期 / `230001`，停下让主人重新授权，不要复用旧 chat_id、不要换 bot。

### 步 25 飞书 APK 标题
做：把新 APK 覆盖原 file token `RzcFbpFCyokpPqxVIq5cUI1QnuR`，标题改成 `dsh-go-1.0.28-<buildNumber>-mogai-arm64.apk`。
成功长什么样：飞书文件页标题是新文件名，大小等于步 16 的字节数，链接仍是 `https://my.feishu.cn/file/RzcFbpFCyokpPqxVIq5cUI1QnuR`。
不对就停：lark-cli 覆盖不了，就打开原文件 → 右上角「...」→ 上传新版本；还不行停下报告，别新建链接。
注意：PowerShell 里传 `@./file` 外层要用单引号，否则 `@` 会被吞。

## 五、回报（少一项都不算完成）
- 最终 commit：main = `<sha>`（与 origin/main 一致）
- buildNumber：`<buildNumber>`（> 11131822）
- APK：路径 + 字节数 + sha256 全串
- test/chat：通过数 / 0 失败
- 构建日志：warning 几条、error 几条（贴关键原文；没有就写 0）
- 七处同步：HANDOFF ✅ / UPGRADE_TABLE ✅ / PROJECT_STATE ✅ / PROGRESS ✅ / D 盘 ✅ / 飞书 HANDOFF ✅ / 飞书 APK 标题 ✅（失败写 ❌ + 原因）
- 未完成或风险：真实写，没验证就写没验证；禁止「应该没问题」。

## 六、装机验收（电脑不用做，主人装机时对照）
- 选字：长按能选、拖到边缘自动滚、复制/全选/翻译/引用。
- 密钥保险箱：设置→密钥保险箱 录入 → 解锁 → 临时文件 → 清除；截屏被挡。
- 思考过程不显示，正文正常。
- 红后模式：生成中标题栏下沿 2px 绿带，失败变红，正文不被遮。
- 息屏 30 分钟电量与 1.0.27 对比（验按需唤醒锁）。
- 同版本不再改代码；装上后有问题进 1.0.29。
```
