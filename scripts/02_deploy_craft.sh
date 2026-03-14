#!/usr/bin/env bash
set -euo pipefail

# Run this on your PHP host in the project root.
# Example:
#   bash scripts/02_deploy_craft.sh

echo "🚀 Installing PHP dependencies..."
composer install --no-dev --optimize-autoloader

echo "🧱 Applying DB migrations..."
php craft migrate/all

echo "⚙️ Applying project config..."
php craft project-config/apply

echo "🧹 Clearing caches..."
php craft clear-caches/all

echo "✅ Deploy tasks complete."
