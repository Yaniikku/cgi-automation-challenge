# CGI Automation Challenge - DevOps Engineer 
by Yannick Schulz

## Übersicht
Dieses Projekt erfüllt alle Aufgaben der CGI Automation Challenge.

## Aufgaben
✅ Aufgabe 1: NGINX Webserver mit Docker Compose
✅ Aufgabe 2: HTTPS & TLS mit Self-Signed Certificates
✅ Aufgabe 3: Volume Mounting für editierbaren Content
✅ Bonus I: Custom Domain automation-challenge.cgi.com
✅ Bonus II: CI/CD Pipeline mit GitHub Actions

## Schnellstart
```bash
# SSL Zertifikate erstellen
bash scripts/generate-ssl.sh

# Container starten
docker-compose up -d

# Testen
curl http://localhost:8080
curl -k https://localhost:8443
```

## Bonus I Setup
Füge zu `C:\Windows\System32\drivers\etc\hosts` hinzu:
```
127.0.0.1  automation-challenge.cgi.com
```

Dann: https://automation-challenge.cgi.com:8443

## Architektur
```
automation-challenge/
├── .github/
│   └── workflows/
│       └── ci.yml                    # GitHub Actions Pipeline (Bonus II)
│
├── html/
│   └── index.html                    # "Hello CGI" Seite (via Volume gemountet)
│
├── nginx/
│   ├── nginx.conf                    # NGINX HTTP/HTTPS Konfiguration
│   └── ssl/
│       ├── localhost.crt             # TLS Cert für localhost
│       ├── localhost.key             # Private Key für localhost
│       ├── automation-challenge.crt  # TLS Cert für Custom Domain (Bonus I)
│       └── automation-challenge.key  # Private Key für Custom Domain
│
├── scripts/
│   └── generate-ssl.sh               # OpenSSL Script für Zertifikate
│
├── .gitignore                        # Ignoriert SSL Keys, Terraform State
├── docker-compose.yml                # Infrastructure as Code (Aufgabe 1)
├── Dockerfile                        # NGINX Container Definition
└── README.md                         # Diese Datei
```
