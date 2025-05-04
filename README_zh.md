# 从家中安全共享文件：Cloudflare Tunnel × FileBrowser（自定义域名，无需 Cloudflare DNS）

---

## 🌐 多语言支持

- [English](README.md)
- [日本語版](README_ja.md)
- [中文版本](README_zh.md)

## ✅ 目标

从您的个人电脑或服务器安全地与朋友和同事共享大文件。  
目标是满足以下需求：

- 文件列表可通过浏览器查看（Web UI）
- 支持认证下载
- 无需端口转发或 DDNS
- 支持非 Cloudflare DNS 的域名
- 完全自主管理

---

## 🛠 技术栈

| 组件        | 技术                                                |
| ----------- | --------------------------------------------------- |
| 文件服务器  | FileBrowser（Docker）                               |
| 外部访问    | Cloudflare Tunnel（cloudflared）                    |
| 认证 Web UI | FileBrowser                                         |
| 示例域名    | `files.example.invalid`（自定义域名，DNS 独立管理） |
| 隧道运行    | 通过 Docker 持久运行 cloudflared                    |

---

## 📦 步骤

### ① 使用 Docker 启动 FileBrowser

```bash
docker run -d ^
  --name filebrowser ^
  -v C:\your\files:/srv ^
  -v filebrowser_db:/database ^
  -v filebrowser_config:/config ^
  -p 8080:80 ^
  filebrowser/filebrowser
```

- 将 `C:\your\files` 替换为您想共享的文件夹
- 访问 `http://localhost:8080` 查看 Web UI

---

### ② 安装 Cloudflared

在 Windows 上，从以下链接下载可执行文件：  
[https://developers.cloudflare.com/cloudflared/install/](https://developers.cloudflare.com/cloudflared/install/)

安装后，通过 PowerShell 进行认证：

```bash
cloudflared login
```

→ 浏览器将打开，登录您的 Cloudflare 账户。

---

### ③ 创建隧道

```bash
cloudflared tunnel create my-tunnel
```

→ 将生成一个 `tunnel-id` 和一个 `.json` 认证文件。

---

### ④ 创建配置文件

创建 `C:\Users\<您的用户名>\.cloudflared\config.yml`：

```yaml
tunnel: 5f1abc12-def3-4567-89ab-cdef01234567
credentials-file: C:\Users\yourname\.cloudflared\5f1abc12-def3-4567-89ab-cdef01234567.json

ingress:
  - hostname: files.example.invalid
    service: http://localhost:8080
  - service: http_status:404
```

---

### ⑤ 在自定义域名的 DNS 中设置 CNAME

在您的 DNS 管理面板中，配置以下内容：

| 类型  | 主机名 | 值                                                      |
| ----- | ------ | ------------------------------------------------------- |
| CNAME | files  | `5f1abc12-def3-4567-89ab-cdef01234567.cfargotunnel.com` |

※ 将 `files.example.invalid` 替换为您的隧道 ID。

---

### ⑥ 使用 Docker 启动 Cloudflared（持久化）

```bash
docker run -d ^
  --name cloudflared ^
  -v C:\Users\yourname\.cloudflared:/etc/cloudflared ^
  cloudflare/cloudflared:latest tunnel run my-tunnel
```

- 启动后，隧道将自动运行
- FileBrowser 也将可通过外部访问

---

## ✅ 访问验证

在浏览器中访问：

```
https://files.example.invalid
```

FileBrowser 登录界面应出现，您可以查看文件。

---

## 🔐 安全注意事项

- Cloudflare Access（Zero Trust）不可用（由于不支持的 DNS 域名）
- 替代方案是在 FileBrowser 中配置以下内容：
  - 创建用户
  - 强制密码认证
  - 限制非管理员用户的权限

---

## 📌 注意事项

- DNS 传播可能需要几个小时
- 备份 `.cloudflared` 文件夹，因为它包含认证文件和设置
- 定期检查 FileBrowser 和 cloudflared 的更新

---
