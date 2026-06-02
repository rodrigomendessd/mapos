#!/bin/bash
set -e

# Gera .env a partir das variaveis de ambiente do container (Easypanel)
if [ ! -f /var/www/html/application/.env ]; then
    cat > /var/www/html/application/.env <<EOF
base_url="${BASE_URL:-http://localhost/}"
db_hostname="${DB_HOST:-mysql}"
db_username="${DB_USER:-mapos}"
db_password="${DB_PASS:-mapos}"
db_database="${DB_NAME:-mapos}"
encryption_key="${ENCRYPTION_KEY:-changeme32charskey123456789012}"
EOF
    chown www-data:www-data /var/www/html/application/.env
fi

# Remove pasta install se ja instalado (seguranca)
if [ -d /var/www/html/install ]; then
    rm -rf /var/www/html/install
fi

# Inicia cron em background
cron

# Inicia Apache em foreground
exec apache2-foreground
