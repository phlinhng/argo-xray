# Github Action Network Tunnel
Use github action and argo tunnel to create temporary network tunnel.

由于 Github Action 需要在 Github 上调试，你看到此页面时我可能还在 debug，不要哭爸哭母为什么不能用。

我是技术爱好者不是技术教学爱好者，看不懂自己想办法不要问我。

## Prerequisites
+ 能连上 Cloudflare 的电脑或 VPS（用于申请 Argo Tunnel 密钥）
+ 绑定到 Cloudflare 的域名
+ 域名的 SSL 模式设置为 `Full 完全`

## Usage
### 1. 生成 Argo Tunnel 密钥
以任意 Linux 环境运行以下指令，首先下载 `cloudflared`
```sh
wget https://github.com/cloudflare/cloudflared/releases/download/2021.5.10/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared
```
接着生成密钥
```sh
cloudflared tunnel login
```
用浏览器打开给出的网址，登入你的 Cloudflare 帐户，授权一个区域使用 Argo Tunnel。成功后会在你的 Linux 环境生成一个`~/.cloudflared`目录。保存 `~/.cloudflared/cert.pem` 的内容，后面会用到。
### 2. 取得 CF Global API Key
~~建立一个 CF 的 API Token，权限设置为 **DNS: Edit; Zone: Read**。~~
由于需要删除 DNS 纪录的权限，目前只能用 Global API Key。

### 3. Fork 本项目并添加以下的 Secret
| Name | Value | Source | Example |
|-|-|-| - |
| CF_API_KEY | CF API Key | 2 取得 CF API Key | 8f32f6daf2964cf6aa2d6077a3dd1308 |
| CF_API_EMAIL | CF Email | 2. 取得 CF API Key | abc@example.com |
| ARGO_TUNNEL_DOMAIN | 隧道主域名 | 1. 生成密钥 | example.com |
| ARGO_TUNNEL_TOKEN | 隧道密钥 | 1. 生成密钥 | content of `~/.cloudflared/cert.pem` |
| ARGO_TUNNEL_HOSTNAME | 隧道域名 | 1. 生成密钥 | tunnel.example.com |
| XRAY_VLESS_UUID | xray 的 uuid | 自定义 | 8f32f6da-f296-4cf6-aa2d-6077a3dd1308 |
| XRAY_VLESS_WSPATH | xray 的 path | 自定义 | /myargo |

设置路径：`Repo 页面 → Settings → Secret → New Repository secrets` <br>

### 4. 连接到 Github Action 容器
使用支持 ws 的 VLESS 客户端，以如下配置进行连接
> 入口地址: 你设定的 Argo 隧道域名 <br>
> 端口: 2083 <br>
> 协议: VLESS <br>
> UUID: 你设定的值 <br>
> 传输方式: ws <br>
> path: 你设定的值<br>

## Future works
+ [ ] Authenticate argo tunnel and generate `cert.pem` on the air
+ [ ] Support grpc
+ [x] Gugugu

## Note
FAIR USE ONLY. DO NOT ABUSE THIS PROJECT WITH ILLEGAL PROPSOE OR ANYTHING DISOBEYING TOS OF GITHUB OR CLOUDFLARE. THE AUTHOR OF THIS REPOSITORY GIVE NO WARRANTY FOR ANY RESULT CAUSING BY ABUSE.

本项目仅供学习 Cloudflare Argo Tunnel 与 Github Action 的操作，所生成的隧道最长运行 1 小时且仅在 push 时触发，若有持续使用的需求请自行修改触发条件。请评估风险后合理使用本项目，任何因滥用本项目造成的后果均与本项目无关。