# No-cPanel Deployment Playbook (Local + Git + Vercel)

If you do **not** want to run any PHP host, the fastest route is:

1. Export a static snapshot of your current live site
2. Commit static output to this repo
3. Deploy static folder on Vercel

## Why this path
Craft CMS itself needs PHP + MySQL. Vercel is ideal for static/Node frontends. A static export avoids PHP runtime issues (502s from missing vendor, host timeouts, etc.) and typically improves speed.

## Step 1 — Export static site locally
From repo root:

```bash
python3 scripts/10_export_static_site.py \
  --base-url https://www.audreystanton.com \
  --out-dir vercel-static \
  --max-pages 400
```

This creates a folder `vercel-static/` with HTML + downloaded assets.

## Step 2 — Preview locally
```bash
cd vercel-static
python3 -m http.server 8080
```
Open `http://localhost:8080` and verify homepage/profile/projects links and images.

## Step 3 — Commit and push
```bash
git add vercel-static
git commit -m "Add static export for Vercel"
git push
```

## Step 4 — Deploy on Vercel
- In Vercel, create a new project from this GitHub repo
- Root Directory: `site-source`
- Framework Preset: `Other`
- Build Command: leave empty
- Output Directory: `vercel-static`
- Deploy

## Step 5 — DNS cutover
- In your domain DNS, point to Vercel
- Keep old host up during DNS propagation
- Validate routes and media after cutover

## Important limitations
- This path is a static snapshot. Craft CMS admin/content editing will no longer update the public site automatically.
- To refresh content, rerun static export and redeploy.

## If you want editable CMS + Vercel frontend later
Use Craft on a non-cPanel PHP host (or Craft Cloud) as content backend, and Vercel for frontend (Next.js).
