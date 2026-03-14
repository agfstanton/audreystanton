#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash scripts/03_post_deploy_checks.sh https://www.audreystanton.com

SITE_URL="${1:-}"
if [[ -z "$SITE_URL" ]]; then
  echo "❌ Provide site URL, e.g. https://www.audreystanton.com"
  exit 1
fi

echo "🔎 Running basic health checks for $SITE_URL"

check() {
  local path="$1"
  local label="$2"
  echo "\n- $label ($path)"
  curl -sS -o /dev/null -w "  status=%{http_code} time=%{time_total}s size=%{size_download}\n" "$SITE_URL$path"
}

check "/" "Homepage"
check "/profile" "Profile"
check "/projects" "Projects"

echo "\n📌 If any route is 5xx or consistently >2s, inspect:"
echo "  - storage/logs/web-*.log"
echo "  - php error log"
echo "  - image transform requests under /actions/assets/generate-transform"

echo "✅ Post-deploy checks finished."
