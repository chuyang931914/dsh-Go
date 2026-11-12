# local-ai-cost

输入框上方一行 AI 费用摘要；点开面板看 DeepSeek 余额与火山本月账单。

源码入库位置：`plugins/local-ai-cost/`。`secrets.json`、`node_modules/` 不入库。

## 安装

```sh
cd plugins/local-ai-cost
npm install
dsh plugin --profile web add "$(pwd)"
```

首次配置：

```sh
cp secrets.example.json secrets.json
chmod 600 secrets.json
```

- DeepSeek：`apiKey`，用于 `GET https://api.deepseek.com/user/balance`
- 火山：子账号 `accessKeyId` / `secretAccessKey`，只给账单只读权限；插件用官方 `@volcengine/openapi` 查 `ListBillOverviewByProd`

`secrets.json` 已在 `.gitignore` 里，不要把 Key 发给别人或提交到仓库；插件只把 Key 用于官方接口。
