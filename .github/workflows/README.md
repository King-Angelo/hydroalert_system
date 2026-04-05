# GitHub Actions

Workflows in this folder apply to the **repository root** (parent of `hydroalert_system/`).

| Workflow | Purpose |
|----------|---------|
| **`ci.yml`** | PR / push: backend analyze+test, shared_models test, admin flutter analyze+test, Firebase options policy. |
| **`api-smoke-tier1.yml`** | Manual (**Actions** → **Run workflow**): Phase 3 tier-1 smoke against a deployed API URL — no token required. |
| **`build-admin-web-staging.yml`** | Manual: inject **`ADMIN_FIREBASE_OPTIONS_STAGING_DART`** → **`flutter build web`** (staging) → artifact. See **`hydroalert_system/docs/FLUTTERFIRE_BUILD_LANES.md`**. |

Required check names for branch protection: **`hydroalert_system/docs/GITHUB_BRANCH_PROTECTION.md`**.
