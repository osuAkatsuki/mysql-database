#!/usr/bin/env bash
set -euo pipefail

if [[ "${PULL_SECRETS_FROM_VAULT:-0}" -eq 1 ]]; then
  echo "Fetching secrets from Vault"
  VAULT_RESPONSE=$(curl -sf \
    -H "X-Vault-Token: ${VAULT_TOKEN}" \
    "${VAULT_ADDR}/v1/secrets/data/${APP_ENV}/mysql-database")

  eval "$(echo "$VAULT_RESPONSE" | jq -r '.data.data | to_entries[] | "\(.key | ascii_upcase)=\(.value)"')"
  echo "Sourced secrets from Vault"
fi

MIGRATIONS_SCHEMA_TABLE=akatsuki_schema_migrations

echo "Creating ${DB_NAME} database, if it does not exist"
mysql \
    --host="${DB_HOST}" \
    --port="${DB_PORT}" \
    --user="${DB_USER}" \
    --password="${DB_PASS}" \
    --execute="CREATE DATABASE IF NOT EXISTS ${DB_NAME};"

echo "Running up migrations for ${DB_NAME} database"
DB_DSN="mysql://${DB_USER}:${DB_PASS}@tcp(${DB_HOST}:${DB_PORT})/${DB_NAME}?parseTime=true&x-migrations-table=${MIGRATIONS_SCHEMA_TABLE}"
go-migrate -path migrations -database "$DB_DSN" up
echo "Migrations ran successfully"
