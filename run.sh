#!/bin/bash
set -e

# Cloudflare Tunnel の設定ファイル確認
if [ ! -f ./cloudflared/credentials.json ]; then
  echo "cloudflared/credentials.json が存在しません。公式手順に従って生成してください。"
  exit 1
fi

# FileBrowser の初期化
if [ ! -f ./filebrowser/filebrowser.db ]; then
  echo "FileBrowser の初回セットアップを行います。"
  filebrowser -d ./filebrowser/filebrowser.db config init
  filebrowser -d ./filebrowser/filebrowser.db users add admin password --perm.admin
fi

# Cloudflare Tunnel 起動
cloudflared tunnel --config ./cloudflared/config.yml run
