# Audrey Stanton Site (Craft CMS)

This repository contains the cleaned Craft CMS source from your cPanel backup.

## Stack
- Craft CMS 5
- PHP 8.2
- MySQL
- Web root: `public_html/`

## Repository Layout
- `config/` Craft app and project config
- `templates/` Twig templates
- `public_html/` public web assets and `index.php`
- `craft` Craft CLI entry
- `bootstrap.php` bootstrap loader

## Deploying Craft
Craft should run on a PHP host (not directly as a full runtime on Vercel).

1. Provision PHP 8.2 + MySQL host
2. Set document root to `public_html`
3. Add environment variables (never commit `.env`)
4. Install dependencies and apply config/migrations:

```bash
composer install --no-dev --optimize-autoloader
php craft migrate/all
php craft project-config/apply
```

## Using Vercel
Recommended pattern:
- Keep Craft as CMS/backend on a PHP host
- Build frontend separately (Next.js/Nuxt/etc.)
- Deploy frontend to Vercel and fetch content via Craft GraphQL/API

## Security
This backup originally contained live credentials. Rotate secrets and keep sensitive values in host/Vercel environment variables.

## More Detail
See `MIGRATION_GIT_VERCEL.md` for the full migration checklist and architecture options.
