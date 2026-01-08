# Verwende offizielles NGINX Alpine Image (klein und sicher)
FROM nginx:alpine

# Maintainer Info
LABEL maintainer="DevOps Challenge"
LABEL description="NGINX Webserver for CGI Automation Challenge"

# Kopiere custom NGINX Konfiguration
# Diese wird später für HTTP und HTTPS verwendet
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Erstelle SSL Verzeichnis
RUN mkdir -p /etc/nginx/ssl

# WICHTIG: HTML Content wird via Volume gemountet!
# Das ermöglicht Updates ohne Container Rebuild
# COPY wird hier NICHT verwendet für /usr/share/nginx/html

# Exponiere Ports
EXPOSE 80 443

# Health Check - stellt sicher dass NGINX läuft
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Standard NGINX Command
CMD ["nginx", "-g", "daemon off;"]