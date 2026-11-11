# project_memory — 长期记忆（与 HANDOFF.md 配套）

> 用途：跨会话的长期用户指令与关键决策。HANDOFF.md 记「怎么做」，这里记「为什么/长期有效」。任何以「重要：」开头的指令或重大决策，追加到这里并推 Gitee（HANDOFF Rule 20 / Rule 33）。

## 用户长期指令（2026-11-11）

1. APK 构建与分发只在电脑侧（WSL + 飞书）；手机端不构建、不分发 APK（HANDOFF Rule 30）。
2. 手机端只做「简单任务」：`dart analyze` / `flutter test`（非金色图）/ 文档维护 / 分支合并 / 装机校验。
3. HANDOFF.md 是双端（手机 + 电脑）的「通话渠道」：每次更新完**先 commit + 推 Gitee**，推完才算更新完成，再干别的活（Rule 33）。
4. Gitee 是唯一事实源；GitHub 由 Gitee Push 镜像按同名分支自动同步，**不再手动推 GitHub**（8.2 / Rule 32）。
5. 不再依赖上游更新：GitHub 原 `main`（上游历史镜像）已覆盖弃用，`mogai` 分支已删除，GitHub 默认分支切到 `main`，Actions 已禁用。
6. 双端长期协作约定见 HANDOFF 第十四节；日常纪律见 8.4。
7. 新对话记忆：工作区 `AGENTS.md` 指向仓库里的 `PROJECT_STATE.md`；每次发版/装机反馈/重要决策后更新它，并与 HANDOFF 同一次提交推送。

## 关键决策记录

- 2026-11-11：全量 99 红清账完成（五批 `a2889e5`→`886e699`）；全量 `flutter test` = 10845 通过 / ~288 跳过 / 0 失败；回归面 = 473 / 0 / 0；`dart analyze` = 0 error / 0 warning / 23 info。
- 2026-11-11：Gitee 配置「仓库镜像」（Push 方向，GitHub 仓库）；镜像闭环实测通过（只推 Gitee，GitHub 约 5 分钟内自动同步）。
- 2026-11-11：手机端 proot 环境建成（Flutter 3.47.7 linux-arm64、CJK 字体、pub 依赖缓存），详见 HANDOFF 3.4；本机不能构建 APK 的四个硬阻断见 Rule 30。
