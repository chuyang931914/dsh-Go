# 本机界面配置

`ui.json` 是 dsh-go 当前使用的原生界面配置（这里只放了会改界面的键）。

部署到本机：

```sh
ln -sf "$(pwd)/ui.json" "$DSH_HOME/dsh-go/ui.json"
```

App 只读这个文件，改完保存会在一两秒内生效；不要放密钥。
