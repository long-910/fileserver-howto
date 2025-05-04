# 自宅から安全にファイル共有：Cloudflare Tunnel × FileBrowser（独自ドメイン・Cloudflare DNS 不使用）

---

## 🌐 Multi-Language Support

- [English](README.md)
- [日本語版](README_ja.md)
- [中文版本](README_zh.md)

## ✅ 目的

自宅の PC やサーバーから大容量ファイルを友人・関係者に安全に共有する。  
以下の条件を満たす構成を目指す：

- ファイル一覧がブラウザで見られる（Web UI）
- ダウンロード可能で、認証付き
- ポート開放や DDNS なし
- Cloudflare DNS に非対応のドメインでも動作
- 自分で管理できる

---

## 🛠 使用技術・構成

| 要素             | 技術                                                  |
| ---------------- | ----------------------------------------------------- |
| ファイルサーバー | FileBrowser（Docker）                                 |
| 外部公開         | Cloudflare Tunnel（cloudflared）                      |
| 認証付き Web UI  | FileBrowser                                           |
| 使用ドメイン例   | `files.example.invalid`（独自ドメイン、DNS は別管理） |
| トンネル実行     | Docker で cloudflared 実行（永続）                    |

---

## 📦 手順一覧

### ① FileBrowser を Docker で起動

```bash
docker run -d ^
  --name filebrowser ^
  -v C:\your\files:/srv ^
  -v filebrowser_db:/database ^
  -v filebrowser_config:/config ^
  -p 8080:80 ^
  filebrowser/filebrowser
```

- `C:\your\files` は共有したいフォルダ
- `http://localhost:8080` にアクセスして Web UI を確認

---

### ② Cloudflared インストール

Windows の場合、以下から実行ファイルを入手：  
[https://developers.cloudflare.com/cloudflared/install/](https://developers.cloudflare.com/cloudflared/install/)

インストール後、PowerShell で認証：

```bash
cloudflared login
```

→ ブラウザが開いて Cloudflare アカウントにログイン

---

### ③ トンネル作成

```bash
cloudflared tunnel create my-tunnel
```

→ `tunnel-id` と `.json` 認証ファイルが作成される

---

### ④ 構成ファイル作成

`C:\Users\<あなたのユーザー名>\.cloudflared\config.yml` を作成：

```yaml
tunnel: 5f1abc12-def3-4567-89ab-cdef01234567
credentials-file: C:\Users\yourname\.cloudflared\5f1abc12-def3-4567-89ab-cdef01234567.json

ingress:
  - hostname: files.example.invalid
    service: http://localhost:8080
  - service: http_status:404
```

---

### ⑤ 独自ドメインの DNS に CNAME を設定

自分の DNS 管理パネルで以下のように設定：

| タイプ | ホスト名 | 値                                                      |
| ------ | -------- | ------------------------------------------------------- |
| CNAME  | files    | `5f1abc12-def3-4567-89ab-cdef01234567.cfargotunnel.com` |

※ `files.example.invalid` → トンネル ID に合わせて変更

---

### ⑥ Docker で cloudflared を起動（永続）

```bash
docker run -d ^
  --name cloudflared ^
  -v C:\Users\yourname\.cloudflared:/etc/cloudflared ^
  cloudflare/cloudflared:latest tunnel run my-tunnel
```

- 起動後、トンネルは常に自動実行
- FileBrowser も自動で外部公開

---

## ✅ アクセス確認

ブラウザで：

```
https://files.example.invalid
```

FileBrowser のログイン画面が表示され、ファイルが見られる。

---

## 🔐 セキュリティ補足

- Cloudflare Access（Zero Trust）は使用不可（DNS 非対応ドメインのため）
- 代わりに FileBrowser 側で以下の設定を行う：
  - ユーザー作成
  - パスワード認証の強制
  - 管理者以外の権限制御

---

## 📌 注意点

- DNS の反映に最大で数時間かかる場合あり
- `.cloudflared` フォルダは認証ファイルや設定を含むのでバックアップ推奨
- FileBrowser や cloudflared のバージョンアップも時々確認

---
