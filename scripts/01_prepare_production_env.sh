#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   cp .env.example.production .env
#   edit .env with real values
#   ./scripts/01_prepare_production_env.sh .env

ENV_FILE="${1:-.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Env file not found: $ENV_FILE"
  exit 1
fi

echo "🔍 Checking required production env keys in $ENV_FILE ..."
required=(
  CRAFT_APP_ID
  CRAFT_ENVIRONMENT
  CRAFT_SECURITY_KEY
  CRAFT_DB_DRIVER
  CRAFT_DB_SERVER
  CRAFT_DB_PORT
  CRAFT_DB_DATABASE
  CRAFT_DB_USER
  CRAFT_DB_PASSWORD
  PRIMARY_SITE_URL
)

missing=0
for key in "${required[@]}"; do
  if ! grep -Eq "^${key}=.+" "$ENV_FILE"; then
    echo "  - Missing or empty: $key"
    missing=1
  fi
done

if grep -Eq '^CRAFT_DEV_MODE=true' "$ENV_FILE"; then
  echo "  - CRAFT_DEV_MODE is true (should be false in production)"
  missing=1
fi

if grep -Eq '^CRAFT_ALLOW_ADMIN_CHANGES=true' "$ENV_FILE"; then
  echo "  - CRAFT_ALLOW_ADMIN_CHANGES is true (should be false in production)"
  missing=1
fi

if grep -Eq '^CRAFT_DISALLOW_ROBOTS=true' "$ENV_FILE"; then
  echo "  - CRAFT_DISALLOW_ROBOTS is true (usually false in production)"
  missing=1
fi

if grep -Eq '^CRAFT_WEB_ROOT=' "$ENV_FILE"; then
  echo "  - CRAFT_WEB_ROOT is set. Remove it unless it exactly matches your host docroot."
fi

if [[ "$missing" -eq 1 ]]; then
  echo "\n❌ Env file failed production checks."
  exit 1
fi

echo "✅ Env file looks production-ready."
