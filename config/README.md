# 本机界面配置

`ui.json` 是 dsh-go 当前使用的原生界面配置（这里只放了会改界面的键）。

部署到本机：

```sh
bash tooling/install-ui-config.sh
```

不要做软链：App 读的是 rootfs 里的真实文件，指向仓库的绝对软链在它的文件视图里可能解析不到。

App 只读这个文件，改完保存会在一两秒内生效；不要放密钥。
