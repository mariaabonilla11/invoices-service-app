#!/bin/bash
set -e

# echo "⏳ Esperando a que Oracle esté listo..."
# until sqlplus -S fmc_admin/fmc_password@//oracle-xe:1521/factumarket_clients <<< "SELECT 1 FROM dual;" > /dev/null 2>&1; do
#   sleep 5
#   echo "🔄 Oracle aún no responde..."
# done

echo "✅ Oracle disponible, ejecutando migraciones..."
bundle exec rails db:migrate

echo "🚀 Iniciando servidor Rails..."
bundle exec rails server -b 0.0.0.0
