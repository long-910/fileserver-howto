#!/bin/bash

set -e

echo "✅ Cloudflare Tunnel + FileBrowser 自動セットアップ"

# Cloudflared ログイン確認
echo "🔐 Cloudflare にログインしていますか？（ログイン済みなら Enter）"
read -p "未ログインの場合は cloudflared login を実行して Enter を押してください: "

# トンネル名の入力
read -p "🌐 作成するトンネル名を入力してください: " TUNNEL_NAME

# ドメイン選択
echo "🌍 使用するドメインを選択してください:"
select DOMAIN_TYPE in "独自ドメイン（CNAME使用）" "trycloudflare.com（CNAME不要）"; do
  case $REPLY in
    1)
      read -p "使用する独自ドメイン（例: sub.example.com）: " CUSTOM_DOMAIN
      USE_CUSTOM_DOMAIN=true
      break
      ;;
    2)
      USE_CUSTOM_DOMAIN=false
      break
      ;;
    *)
      echo "無効な選択です。"
      ;;
  esac
done

# credentials.json 出力先
read -p "📄 credentials.json の保存先パス（例: ./tunnel/credentials.json）: " CREDENTIALS_PATH

# CNAME登録の要否（独自ドメイン選択時）
if [ "$USE_CUSTOM_DOMAIN" = true ]; then
  read -p "📛 CNAME レコード登録をしますか？ (yes/no): " REGISTER_CNAME
fi

# ディレクトリ作成
mkdir -p tunnel config

# トンネル作成
cloudflared tunnel create "$TUNNEL_NAME"

# credentials.json を所定の場所へ移動
TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
cp ~/.cloudflared/"$TUNNEL_ID".json "$CREDENTIALS_PATH"

# tunnel.yml の生成
cat > tunnel/tunnel.yml <<EOF
tunnel: $TUNNEL_ID
credentials-file: $(realpath $CREDENTIALS_PATH)

ingress:
  - hostname: ${USE_CUSTOM_DOMAIN:+$CUSTOM_DOMAIN}
    service: http://localhost:8080
  - service: http_status:404
EOF

# CNAME 登録案内
if [ "$USE_CUSTOM_DOMAIN" = true ] && [ "$REGISTER_CNAME" = "yes" ]; then
  echo ""
  echo "📝 次のように CNAME レコードを DNS に追加してください:"
  echo "$CUSTOM_DOMAIN CNAME $TUNNEL_NAME.cfargotunnel.com"
fi

echo ""
echo "✅ Cloudflare Tunnel の準備が完了しました。"
echo "▶ FileBrowser を起動するには次のコマンドを実行:"
echo "   docker build -t filebrowser-tunnel ."
echo "   docker run -it --rm -p 8080:80 filebrowser-tunnel"
