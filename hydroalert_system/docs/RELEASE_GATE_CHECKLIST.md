# Release gate checklist (P0)

**Related:** Institutional ops/compliance context and rollback narrative — **[operations_compliance_p1/README.md](operations_compliance_p1/README.md)**.

Use this when moving a change **toward staging** or **from staging to production**. Adapt names to your branching model.

---

## A. Before merge to `main` (or shared integration branch)

- [ ] **CI green** — PR checks pass: `Backend API (dart analyze)`, `shared_models (test)`, `Admin app (flutter analyze)`, `Firebase options policy (no prod project in repo)`.
- [ ] **Branch protection** — `main` requires the above checks (see **`docs/GITHUB_BRANCH_PROTECTION.md`**).
- [ ] **No secrets** — no service account JSON, `.env` with real values, or private keys in the diff.
- [ ] **Firestore** — if schema/rules/indexes changed: plan deploy to **staging** (and later prod) with correct `firebase use`.
- [ ] **Docs** — env vars or setup steps updated if behavior changed.

---

## B. After deploy to **staging**

- [ ] **API health** — `GET /health` on staging base URL returns OK.
- [ ] **V1 smoke (optional)** — from `backend/api`: `SMOKE_API_BASE=<staging API>` `dart run tool/v1_admin_route_smoke.dart` (tier 1); add `SMOKE_FIREBASE_ID_TOKEN` for tier 2 — see **[docs/admin_api_v1_smoke.md](admin_api_v1_smoke.md)**.
- [ ] **CORS** — `CORS_ALLOW_ORIGIN` matches **staging** admin origin; manual-override smoke test from staging admin (if used).
- [ ] **Firebase project** — staging admin build uses **staging** `firebase_options` / project; API `FIREBASE_PROJECT_ID` is **staging**.
- [ ] **FCM** — use `FCM_DRY_RUN=true` on staging first if you want validation-only.

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
