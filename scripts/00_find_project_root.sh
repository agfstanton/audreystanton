#!/usr/bin/env bash
set -euo pipefail

# Find nearest Craft project root from current directory upward.
# A Craft root should contain: composer.json + craft + config/ + public_html/

start_dir="${1:-$PWD}"
current="$start_dir"

echo "Starting search from: $current"

while [[ "$current" != "/" ]]; do
  if [[ -f "$current/composer.json" && -f "$current/craft" && -d "$current/config" && -d "$current/public_html" ]]; then
    echo "✅ Craft project root found: $current"

    if [[ -f "$current/public_html/index.php" ]]; then
      echo "✅ Web entrypoint found: $current/public_html/index.php"
    fi

    echo "\nUseful next commands:"
    echo "  cd \"$current\""
    echo "  bash scripts/01_prepare_production_env.sh .env"
    echo "  bash scripts/02_deploy_craft.sh"
    echo "  bash scripts/03_post_deploy_checks.sh https://www.audreystanton.com / /profile"
    exit 0
  fi
  current="$(dirname "$current")"
done

echo "❌ Could not find a Craft root above: $start_dir"
echo "Try running from inside your account home directory in cPanel Terminal."
exit 1
