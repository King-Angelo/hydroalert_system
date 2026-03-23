# GitHub Actions

| Workflow | Purpose |
|----------|---------|
| **`ci.yml`** | PR / push: `dart analyze`, `dart test`, `flutter analyze`, Firebase options policy. **Enable branch protection** using the job names listed in `docs/GITHUB_BRANCH_PROTECTION.md`. |
| *(optional)* | Example staging web build: **`docs/examples/build-admin-web-staging.workflow.yml`** — copy into `.github/workflows/` and add the secret. |

Repo root must be **`hydroalert_system`** for default paths. If your remote root is the parent folder, move `.github` to that root and prefix paths (e.g. `hydroalert_system/backend/api`).
