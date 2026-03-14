# Next Steps Checklist (Stability → Vercel)

## Phase 1 — Stabilize current Craft host

### A) Production env fix
- [ ] In host env, set:
  - `CRAFT_ENVIRONMENT=production`
  - `CRAFT_DEV_MODE=false`
  - `CRAFT_ALLOW_ADMIN_CHANGES=false`
  - `CRAFT_DISALLOW_ROBOTS=false`
- [ ] Remove `CRAFT_WEB_ROOT` unless it exactly matches your real document root.
- [ ] Rotate DB password and update host env value.

### B) Deploy hygiene
- [ ] Pull latest repo from GitHub.
- [ ] Run:
  - `bash scripts/01_prepare_production_env.sh .env`
  - `bash scripts/02_deploy_craft.sh`
- [ ] Configure cron for queue worker:
  - `* * * * * /usr/bin/php /path/to/project/craft queue/run`

### C) Verify + observe
- [ ] Run health checks:
  - `bash scripts/03_post_deploy_checks.sh https://www.audreystanton.com`
- [ ] Confirm no new 5xx in Craft and PHP logs for 24–72 hours.

## Phase 2 — Fix image transform failures (performance + 500s)
- [ ] In Craft CP, validate image transform settings (`full`, `thumbnail`, etc.).
- [ ] Regenerate/clear transform index.
- [ ] Confirm GD or Imagick is enabled on host.
- [ ] Confirm transform output directories are writable.

## Phase 3 — Vercel migration path

### Recommended architecture
- Keep Craft backend on PHP host.
- Build a frontend app (Next.js) and deploy that to Vercel.
- Pull content from Craft GraphQL/API.

### Cutover checklist
- [ ] Build homepage/projects/profile parity in frontend.
- [ ] Add Vercel env vars for API URL/token.
- [ ] Test preview deployment with real content.
- [ ] Switch DNS to Vercel once parity + performance are confirmed.

## Current diagnosis from your logs
- Historical outages included missing `vendor` dependencies (fatal bootstrap errors).
- Production currently had dev flags enabled, increasing overhead.
- 500s were observed in image transform generation (`actions/assets/generate-transform`).
