# Runbook: 502 Errors, Performance, and Vercel Migration

## 1) Immediate production hardening (today)
On the live host, set environment values for production:

- `CRAFT_DEV_MODE=false`
- `CRAFT_ALLOW_ADMIN_CHANGES=false`
- `CRAFT_DISALLOW_ROBOTS=false`
- Ensure `CRAFT_ENVIRONMENT=production`
- Remove `CRAFT_WEB_ROOT` unless it exactly matches your real docroot (`public_html` on current host)

Then clear caches from Craft control panel.

## 2) Fix common 502 causes
From logs in this backup, historical fatal outages occurred when `vendor/` dependencies were missing.

On each deployment, run:

```bash
composer install --no-dev --optimize-autoloader
php craft migrate/all
php craft project-config/apply
```

If your host supports cron, run queue via cron (not only web requests):

```bash
* * * * * /usr/bin/php /path/to/project/craft queue/run
```

## 3) Investigate image transform 500s
The logs show errors while generating transforms (`Image transform cannot be created`, `InvalidConfigException`).

Actions:
1. In Craft CP, verify all image transforms are valid.
2. Regenerate transforms / clear transform index.
3. Check writable permissions for transform target paths.
4. Confirm image processing libraries (GD/Imagick) are installed/enabled.

## 4) Improve page speed quickly
- Keep `CRAFT_DEV_MODE=false` in production (reduces overhead and verbose logging).
- Ensure page and asset caching are enabled at host/CDN layer.
- Review oversized images and reduce transform quality where acceptable.
- Block abusive bot traffic at CDN/WAF level if logs show heavy scraper activity.

## 5) Vercel target architecture
For this project, recommended pattern:
- Run Craft backend on PHP host.
- Deploy frontend on Vercel (Next.js/Nuxt/etc.) using Craft GraphQL/API.

Alternative:
- Fully static export to Vercel if no server-side dynamic features are needed.

## 6) Suggested execution order
1. Stabilize current host (steps 1-4).
2. Confirm error-free week (no 5xx spikes).
3. Build frontend app for Vercel and connect to Craft API.
4. Cut over DNS once frontend parity is complete.
