---
name: lovable-vercel-workflow
description: Use when working on a website built with Lovable (TanStack Start + Supabase/Lovable Cloud) synced to GitHub and deployed on Vercel. Covers which tool to use for code vs data vs images, publishing and verifying the deploy, Google admin login, and known pitfalls.
license: MIT
---

# Website with Lovable + GitHub + Vercel

General workflow for sites built this way. Per-project data (project IDs, domains, open tasks) does not belong
here: look it up in the project notes or ask the user.

## How it fits together
- Lovable (TanStack Start + Lovable Cloud/Supabase) ↔ private GitHub repo (two-way sync) → Vercel deploys `main`.
- The public site lives on Vercel; the admin panel on the Lovable domain (Lovable's managed Google OAuth only accepts Lovable domains).
- Both domains share the same backend: admin changes show up on both (SSR cache of ~1 min).

## Which tool for what
- **Code or design** → `send_message` to the Lovable agent. **It spends credits:** tell the user what you will ask
  and wait for a yes. Prompt: what to change, how to tell it worked, and a "don't touch" list (data, catalog, login,
  previous optimizations). Ask at the end for "tell me in 3 lines what you changed". Review the result with `get_diff`.
  If it takes more than 5 min, the MCP call times out but Lovable keeps working: check with `list_messages` / `get_message`.
- **Data** (products, prices, settings, roles) → `query_database` (SQL as postgres, no credits).
  Large inserts: one CTE with compact `values`. Before an `update` or `delete`, show the query and how many rows it touches.
- **Catalog images** → in the repo's `public/` (e.g. `public/catalog/`). Lovable generates WebP 400/800 variants.
  Don't open the Storage bucket or create `anon` policies: if a security classifier blocks that, it is right to.
- **Publish** → only if your rules or the user allow it.
  - Vercel deploys automatically on Lovable's commits.
  - A commit whose author is not a member of the Vercel team leaves the deploy **BLOCKED**. Then run
    `create_deployment` (the deploy is created even if the call times out) and confirm with `list_deployments`.
  - Afterwards, `deploy_project` in Lovable so the admin panel matches the public site.

## Known pitfalls
- Images uploaded in the Lovable chat live under `/__l5e/...`, which only exists on Lovable hosting. On Vercel you
  need a rewrite to `id-preview--<id>.lovable.app`, or better, move the image into `public/`.
- Server functions that read `process.env.SUPABASE_*` fail on Vercel: fall back to `import.meta.env.VITE_SUPABASE_*`.
- Canonical domain (canonical, og, sitemap): one `SITE` constant (e.g. in `src/lib/site.ts`) plus the line in `public/robots.txt`.
- Admins: nobody is admin by default. `insert into user_roles (user_id, role) select id, 'admin' from auth.users where email in (...)`.
  It is a permissions change: confirm with the user first.

## Always verify (with curl, not by eye)
- HTTP 200 for the page, an image and `/sitemap.xml`, and that the HTML contains the changed data.
- Server errors: `get_runtime_errors` for the Vercel project.
- Design: if available, apply the `no-ai-look-ui` skill (copy included) before calling it done.
