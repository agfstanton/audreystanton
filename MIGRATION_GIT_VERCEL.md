# Craft CMS Backup → Git + Vercel Migration Guide

## What this backup contains
- This is a **Craft CMS 5** app (`craftcms/cms: 5.6.10.2`) with PHP 8.2 + MySQL.
- App root is this folder (contains `composer.json`, `craft`, `config`, `templates`, `bootstrap.php`).
- Web root is `public_html/` (and `www/` appears to be a duplicate mirror).

## Important security step first
Your current `.env` contains production credentials.

1. **Do not commit `.env`** (already ignored).
2. Rotate database password and any other exposed secrets in your hosting control panel.
3. Store new values only in environment variables on your target platforms.

## Recommended architecture for Vercel
Vercel is excellent for static/Node frontends, but a full Craft PHP app (with persistent storage/runtime + DB + queue jobs) is not a natural fit.

Use one of these paths:

### Path A (recommended): Keep Craft on a PHP host, use Vercel for frontend only
- Host Craft on a PHP platform (Laravel Forge, Ploi, DigitalOcean App Platform, Render, Fly.io, or traditional VPS/shared hosting).
- Expose content to frontend via Craft GraphQL/API.
- Deploy frontend (Next.js/Nuxt/etc.) on Vercel.

### Path B: Fully static site on Vercel
- Keep Craft as a content source (authoring backend).
- Generate static pages (build/export step) and deploy static output to Vercel.
- Best if your site has minimal logged-in/dynamic behavior.

## Git setup from this folder
Run these commands from this directory:

```bash
git init
git add .gitignore composer.json composer.lock craft bootstrap.php config templates public_html
git commit -m "Initial Craft project import"
```

Then create a GitHub repo and push:

```bash
git branch -M main
git remote add origin https://github.com/<you>/<repo>.git
git push -u origin main
```

## If you deploy Craft (non-Vercel runtime)
- Set document root to `public_html`.
- Set env vars (`CRAFT_ENVIRONMENT`, `CRAFT_SECURITY_KEY`, DB vars, `PRIMARY_SITE_URL`).
- Run:

```bash
composer install --no-dev --optimize-autoloader
php craft migrate/all
php craft project-config/apply
```

## If you deploy frontend on Vercel
- Add frontend app in a separate folder/repo.
- In Vercel project settings, add API URL + tokens as environment variables.
- Keep Craft admin/content backend on its own host.

## Notes on this backup
- `www/` and `public_html/` appear to contain the same web files; use one canonical web root in Git (prefer `public_html/`).
- This backup includes mail/log/system folders that are not part of app source and should stay out of version control.
