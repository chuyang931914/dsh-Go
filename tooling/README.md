# tooling 索引

> 十一个脚本各干什么。新对话不用逐个读，查这张表。

## 每天会用

| 脚本 | 干什么 | 什么时候跑 |
|---|---|---|
| `repo-check.sh` | 一次查十项：工作区、分支、本地/远端 main=phone、HEAD、版本号与版本表、状态页 6KB、软链、ui.json、插件残留、实机 build 在表里 | 开工前、提交后 |
| `check-device.sh` | 读装机状态、ui.json、插件、secrets 权限、安装基线 | 装包前后 |
| `test-phone.sh` | analyze + 非金色图测试（按内容排除含 `matchesGoldenFile` 的文件） | 手机端改完代码 |
| `acceptance-phone.md` | 装机验收剧本（不是脚本，是流程） | 每次装机 |

## 出包相关（电脑端）

| 脚本 | 干什么 |
|---|---|
| `build-apk.sh` | arm64 构建、签名、算 versionCode（`MMDDHHmm`） |
| `build_number.py` | 生成/校验 buildNumber |
| `env.sh` | 电脑端环境变量（JDK、Android SDK、国内镜像） |
| `setup-toolchain.sh` | 新电脑一次性装工具链 |
| `release_assets.py` | 整理发布产物（APK/源码包/校验和） |

## 其他

| 脚本 | 干什么 |
|---|---|
| `install-hooks.sh` + `hooks/pre-push` | 推前自检：工作区干净、版本在表里、状态页不超 6KB |
| `install-workspace-memory.sh` | 重建 `/root/workspace/AGENTS.md` 指向 `PROJECT_STATE.md` 的软链 |
| `install-ui-config.sh` | 把 `config/ui.json` 装到设备 |
| `dev-run.sh` / `emu.sh` | 开发期运行与模拟器 |
| `apk_delta.py` | 比对两个 APK 的差异 |

## 测试

`test_build_number.py`、`test_phone_eval.py`、`test_release_assets.py`——各自脚本的单测，改脚本时跑。
