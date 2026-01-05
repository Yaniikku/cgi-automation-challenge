#!/bin/bash
set -euo pipefail

# Prevent Git Bash / MSYS from converting /C=... into a Windows path
export MSYS2_ARG_CONV_EXCL="*"

echo "🔐 Generating SSL Certificates (with SAN)..."

SSL_DIR="nginx/ssl"
mkdir -p "$SSL_DIR"

make_cert () {
  local NAME="$1"
  local CN="$2"
  local CRT="$SSL_DIR/${NAME}.crt"
  local KEY="$SSL_DIR/${NAME}.key"
  local CONF="$SSL_DIR/${NAME}.openssl.cnf"

  echo "📝 Creating certificate for ${CN}..."

  cat > "$CONF" <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
x509_extensions    = v3_req
distinguished_name = dn

[ dn ]
C  = DE
ST = Berlin
L  = Berlin
O  = CGI Challenge
OU = DevOps
CN = ${CN}

[ v3_req ]
subjectAltName = @alt_names
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ alt_names ]
DNS.1 = ${CN}
EOF

  # If CN is localhost, also add IP SAN + localhost DNS
  if [[ "$CN" == "localhost" ]]; then
    cat >> "$CONF" <<EOF
DNS.2 = localhost
IP.1  = 127.0.0.1
EOF
  fi

  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY" \
    -out "$CRT" \
    -config "$CONF"

  chmod 600 "$KEY"
  chmod 644 "$CRT"
}

make_cert "localhost" "localhost"
make_cert "automation-challenge" "automation-challenge.cgi.com"

echo ""
echo "✅ SSL Certificates created successfully!"
ls -lh "$SSL_DIR"

echo ""
echo "ℹ️ For Bonus I (local domain), add to Windows hosts:"
echo "   127.0.0.1  automationchallenge.cgi.com"
echo "   File: C:\\Windows\\System32\\drivers\\etc\\hosts"
