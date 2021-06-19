# Github Action Network Tunnel
Use github action and argo tunnel to create temporary network tunnel. DO NOT ABUSE THIS PROJECT WITH ILLEGAL PROPSOE OR ANYTHING DISOBEYING TOS OF GITHUB OR CLOUDFLARE.

由于 Github Action 需要在 Github 上调试，你看到此页面时我可能还在 debug，不要哭爸哭母为什么不能用。

我是技术爱好者不是技术教学爱好者，看不懂自己想办法不要问我。

## 前置准备
以任意 Linux 环境运行以下指令
### 1. 下载 Argo Tunnel 客户端
```sh
wget https://github.com/cloudflare/cloudflared/releases/download/2021.5.10/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared
```
### 2. 生成密钥
```sh
cloudflared tunnel login
```
用浏览器打开给出的网址，登入你的 Cloudflare 帐户，授权一个区域使用 Argo Tunnel。成功后会在你的 Linux 环境生成一个`~/.cloudflared`目录。保存 `~/.cloudflared/cert.pem` 和 `~/.cloudflared/[tunnel-id].json` 的内容，后面会用到。
### 3. 获取回源证书
因为我们要透过 Cloudflare 访问源站，申请 Cloudflare 的回源证书就够了（就是传说中的 15 年证书），推荐 key type 选 ECC。保存 PEM 类型的证书和私钥，后面会用到

## 使用方法
### 4. Fork 本项目并添加以下的 Secret
| Name | Value | Source |
|-|-|-|
| CF_API_KEY | Cloudflare API Key | Cloudflare |
| CF_API_EMAIL | Cloudflare Email | Cloudflare |
| ARGO_TUNNEL_DOMAIN | 隧道主域名 (example.com) | 2. 生成密钥 |
| ARGO_TUNNEL_TOKEN | 隧道密钥 | 2. 生成密钥 |
| ARGO_TUNNEL_HOSTNAME | 隧道域名 (*.example.com) | 2. 生成密钥 |
| XRAY_TLS_CERT | xray 证书公钥 | 3. 获取回源证书 |
| XRAY_TLS_KEY | xray 证书私钥 | 3. 获取回源证书 |
| XRAY_VLESS_UUID | xray 的 service name | 自定义 |
| XRAY_GRPC_SERVICENAME | grpc 的 service name | 自定义 |

设置路径：Repo 页面 → Settings → Secret → New Repository secrets <br>

### 5. 连接到 Github Action 容器
使用支持 grpc 的 VLESS 客户端，以如下配置进行连接
> 入口地址: 你设定的 Argo 隧道域名 <br>
> 端口: 2083 <br>
> 协议: VLESS <br>
> UUID: 你设定的值 <br>
> 传输方式: ws <br>
> path: 你设定的值<br>

## 注
本项目仅供学习 Cloudflare Argo Tunnel 与 Github Action 的操作，所生成的隧道最长运行 1 小时且仅在 push 时触发，若有持续使用的需求请自行修改触发条件。请评估风险后合理使用本项目，任何因滥用本项目造成的后果均与本项目无关。
