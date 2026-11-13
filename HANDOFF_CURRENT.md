# 本轮交接 · 2026-11-13 23:20

## 一句话

1.0.28 代码全做完（选字滚动修复 + 密钥保险箱 + 隐藏思考 + 红后模式 + 唤醒锁按需），**一次构建都没做过**；实机还停在 1.0.27，所有新功能等电脑出包后真机验。

## 仓库

| 项 | 值 |
|---|---|
| `phone` | `d574949` |
| 源码版本 | `1.0.28+1` |
| 实机 | `1.0.27+11131822`（19:11 装） |
| 1.0.28 APK | 未构建 |

## 1.0.28 改了什么

- `选择文字`：1.0.27 拖到边缘不滚 → 改全局指针路由（`pointerRouter.addGlobalRoute`），拖选区手柄也能收到位置。
- 密钥保险箱：`vault/VaultPlugin.kt`，Android Keystore 绑锁屏，指纹/密码确认后 30 秒窗口；截屏保护、硬件密钥自检、`setUnlockedDeviceRequired`；设置→密钥保险箱可录入/解锁/清除；解锁写临时私钥，`decrypt-vault.sh` 用，5 分钟失效。
- 思考过程不再显示（`chat_rows.dart` 不再生成思考行）。
- 红后模式：只剩标题栏下沿一条 2px 状态灯带（生成绿、失败红），静态不重绘；`hacker_tint.dart` 字符雨整份删除。
- 唤醒锁按需：启动不拿，Dart 生成中 `setBusy(true)`、结束 `false`。

## 没解决的

1. Kotlin 三处新增**手机端没编译过**（保险箱 / ACTION_BUSY / setBusy），构建可能报错。
2. 1.0.28 功能 0 真机验证。
3. 待机耗电无基线；按需拿锁是否生效待测。
4. R8/混淆未开（逆向成本低），单独一轮。
5. 电脑没连过直连信箱（`192.168.1.185:7788`），仍靠人转述。
6. `main` 落后 `phone`，构建前快进。

## 电脑步骤

```bash
git fetch origin && git merge --ff-only origin/phone   # d574949
cd app && dart analyze && flutter test test/chat
git checkout main && git merge --ff-only phone
tooling/build-apk.sh -f arm64
```

构建后同步：HANDOFF、UPGRADE_TABLE（1.0.28 行加 buildNumber/sha）、PROJECT_STATE、PROGRESS、D 盘、飞书 HANDOFF、飞书 APK 标题。

## 手机验收（装 1.0.28 后）

1. 选字：长按能选、拖边缘自动滚、复制/全选/翻译/引用。
2. 保险箱：录入 → 解锁 → 临时文件 → 清除；截屏被挡。
3. 思考不显示；正文正常。
4. 红后模式：生成中标题栏下沿有绿线，断网变红线；正文不被遮。
5. 息屏 30 分钟电量对比（验证按需唤醒锁）。
