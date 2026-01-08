#!/bin/bash

# Strict mode:
# -e  : exit on error
# -u  : error on unset variables
# -o pipefail : fail if any command in a pipe fails
set -euo pipefail

# Prevent Git Bash / MSYS from converting "/C=DE/..." into a Windows path
# This is required so OpenSSL subject strings stay intact
export MSYS2_ARG_CONV_EXCL="*"

echo "🔐 Generating SSL Certificates (with SAN)..."

# Directory where certificates and keys will be stored
SSL_DIR="nginx/ssl"
mkdir -p "$SSL_DIR"

# Function to generate a self-signed TLS certificate
# Arguments:
# 1 = file name prefix
# 2 = Common Name (CN) / hostname
make_cert () {
  local NAME="$1"
  local CN="$2"

  # Output files
  local CRT="$SSL_DIR/${NAME}.crt"
  local KEY="$SSL_DIR/${NAME}.key"
  local CONF="$SSL_DIR/${NAME}.openssl.cnf"

  echo "📝 Creating certificate for ${CN}..."

  # Generate OpenSSL config with SAN support
  # SAN is mandatory for modern TLS validation
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

  # Special handling for localhost:
  # Add IP SAN so HTTPS also works with 127.0.0.1
  if [[ "$CN" == "localhost" ]]; then
    cat >> "$CONF" <<EOF
DNS.2 = localhost
IP.1  = 127.0.0.1
EOF
  fi

  # Create self-signed certificate and private key
  # -x509   : directly generate certificate (no CSR)
  # -nodes  : no passphrase (required for unattended NGINX startup)
  # -days   : certificate validity
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY" \
    -out "$CRT" \
    -config "$CONF"

  # Secure file permissions
  chmod 600 "$KEY"
  chmod 644 "$CRT"
}

# Certificate for local development
make_cert "localhost" "localhost"

# Certificate for Bonus I (FQDN)
make_cert "automation-challenge" "automation-challenge.cgi.com"

echo ""
echo "✅ SSL Certificates created successfully!"
ls -lh "$SSL_DIR"

echo ""
echo "ℹ️ For Bonus I (local domain), add to Windows hosts:"
echo "   127.0.0.1  automation-challenge.cgi.com"
echo "   File: C:\\Windows\\System32\\drivers\\etc\\hosts"
