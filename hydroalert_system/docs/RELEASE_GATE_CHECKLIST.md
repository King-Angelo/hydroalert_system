# Release gate checklist (P0)

**Related:** Institutional ops/compliance context and rollback narrative — **[operations_compliance_p1/README.md](operations_compliance_p1/README.md)**. **Phase 3** (admin + API gates): **[admin_firestore_api_alignment.md](admin_firestore_api_alignment.md)**.

Use this when moving a change **toward staging** or **from staging to production**. Adapt names to your branching model.

**Where work happens:** Items below mix **repo** (code, docs, local terminal), **GitHub**, **Render**, **Firebase**, and **browser**. Section **A** is mostly repo + GitHub. Section **B** is mostly Render + Firebase + terminal/browser.

---

## A. Before merge to `main` (or shared integration branch)

- [ ] **CI green** — PR checks pass: `Backend API (analyze + test)`, `shared_models (test)`, `Admin app (analyze + test)`, `Firebase options policy (no prod project in repo)`.
- [ ] **Branch protection** — `main` requires the above checks (see **`docs/GITHUB_BRANCH_PROTECTION.md`**).
- [ ] **No secrets** — no service account JSON, `.env` with real values, or private keys in the diff.
- [ ] **Firestore** — if schema/rules/indexes changed: plan deploy to **staging** (and later prod) with correct `firebase use`.
- [ ] **Docs** — env vars or setup steps updated if behavior changed.

---

## B. After deploy to **staging** (Phase 3)

- [ ] **API health** — `GET /health` on staging base URL returns OK.
- [ ] **Tier 1 smoke** — from repo: `hydroalert_system/backend/api` → set `SMOKE_API_BASE` to staging API (no trailing slash), then `dart run tool/v1_admin_route_smoke.dart`. **Or** in GitHub: **Actions** → **API smoke (tier 1)** → **Run workflow** → paste API URL — see **[admin_api_v1_smoke.md](admin_api_v1_smoke.md)**.
- [ ] **Tier 2 smoke (optional)** — same script with `SMOKE_FIREBASE_ID_TOKEN` (active admin) — same doc.
- [ ] **CORS** — in **Render**, `CORS_ALLOW_ORIGIN` matches **staging** admin origin; test from real admin URL in browser.
- [ ] **Firebase project** — staging admin build uses **staging** `firebase_options` / project; API `FIREBASE_PROJECT_ID` is **staging**.
- [ ] **FCM** — on staging use `FCM_DRY_RUN=true` first if you want validation-only pushes.

---

## C. Production promotion (staging → production)

- [ ] **Stakeholder sign-off** on staging QA (reports, alerts, auth as applicable).
- [ ] **Production deploy** — Render (or host) env vars set for **production** project only.
- [ ] **Admin web** — production build uses **production** Firebase options + **production** `HYDROADMIN_API_BASE_URL`.
- [ ] **CORS** — `CORS_ALLOW_ORIGIN` = **production** admin URL only.
- [ ] **FCM_DRY_RUN** — **false** in production when ready for real pushes.
- [ ] **Firestore** — rules + indexes deployed to **production** project after merge.
- [ ] **Rollback plan** — previous Render deploy / hosting revision known.

---

## D. Post-production

- [ ] Smoke test critical paths (sign-in, one privileged action, optional alert dry-run in prod if policy allows).
- [ ] Monitor **System_Logs** / Render logs for errors in the first hour.
