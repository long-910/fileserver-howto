# Secure File Sharing from Home: Cloudflare Tunnel × FileBrowser (Custom Domain, No Cloudflare DNS)

---

## 🌐 Multi-Language Support

- [English](README.md)
- [日本語版](README_ja.md)
- [中文版本](README_zh.md)

## ✅ Purpose

Securely share large files from your home PC or server with friends and associates.  
The goal is to meet the following requirements:

- File listing accessible via a browser (Web UI)
- Downloadable with authentication
- No port forwarding or DDNS required
- Works with domains not supported by Cloudflare DNS
- Fully self-managed

---

## 🛠 Technology Stack

| Component        | Technology                                                      |
| ---------------- | --------------------------------------------------------------- |
| File Server      | FileBrowser (Docker)                                            |
| External Access  | Cloudflare Tunnel (cloudflared)                                 |
| Authenticated UI | FileBrowser                                                     |
| Example Domain   | `files.example.invalid` (Custom domain, DNS managed separately) |
| Tunnel Execution | Persistent execution of cloudflared via Docker                  |

---

## 📦 Steps

### ① Start FileBrowser with Docker

```bash
docker run -d ^
  --name filebrowser ^
  -v C:\your\files:/srv ^
  -v filebrowser_db:/database ^
  -v filebrowser_config:/config ^
  -p 8080:80 ^
  filebrowser/filebrowser
```

- `C:\your\files` is the folder you want to share
- Access the Web UI at `http://localhost:8080`

---

### ② Install Cloudflared

For Windows, download the executable from:  
[https://developers.cloudflare.com/cloudflared/install/](https://developers.cloudflare.com/cloudflared/install/)

After installation, authenticate via PowerShell:

```bash
cloudflared login
```

→ A browser window will open to log in to your Cloudflare account

---

### ③ Create a Tunnel

```bash
cloudflared tunnel create my-tunnel
```

→ A `tunnel-id` and a `.json` credentials file will be created

---

### ④ Create Configuration File

Create `C:\Users\<your-username>\.cloudflared\config.yml`:

```yaml
tunnel: 5f1abc12-def3-4567-89ab-cdef01234567
credentials-file: C:\Users\yourname\.cloudflared\5f1abc12-def3-4567-89ab-cdef01234567.json

ingress:
  - hostname: files.example.invalid
    service: http://localhost:8080
  - service: http_status:404
```

---

### ⑤ Set CNAME in Custom Domain DNS

In your DNS management panel, set the following:

| Type  | Hostname | Value                                                   |
| ----- | -------- | ------------------------------------------------------- |
| CNAME | files    | `5f1abc12-def3-4567-89ab-cdef01234567.cfargotunnel.com` |

※ Change `files.example.invalid` to match your tunnel ID

---

### ⑥ Start cloudflared with Docker (Persistent)

```bash
docker run -d ^
  --name cloudflared ^
  -v C:\Users\yourname\.cloudflared:/etc/cloudflared ^
  cloudflare/cloudflared:latest tunnel run my-tunnel
```

- The tunnel will run automatically after starting
- FileBrowser will also be accessible externally

---

## ✅ Access Verification

In your browser, go to:

```
https://files.example.invalid
```

The FileBrowser login screen should appear, and you can view the files.

---

## 🔐 Security Notes

- Cloudflare Access (Zero Trust) is not available (due to unsupported DNS domain)
- Instead, configure the following in FileBrowser:
  - Create users
  - Enforce password authentication
  - Control permissions for non-admin users

---

## 📌 Notes

- DNS propagation may take up to several hours
- Back up the `.cloudflared` folder as it contains credentials and settings
- Periodically check for updates to FileBrowser and cloudflared

---
