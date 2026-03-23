# GitHub: branch protection + required CI on `main`

Enforce that **`main`** (and optionally **`develop`**) cannot move forward unless **CI** passes.

---

## 1. Prerequisites

- Repository root on GitHub is **`hydroalert_system`** (so `.github/workflows/ci.yml` runs), **or** you have adjusted workflow paths to match your repo root.
- The **CI** workflow has run at least once on a PR so GitHub registers the check names (Settings → Rules won’t list unknown checks until they appear in the UI once).

---

## 2. Add a ruleset (recommended)

GitHub → your repo → **Settings** → **Rules** → **Rulesets** → **New ruleset** → **New branch ruleset**.

Suggested settings:

| Field | Value |
|--------|--------|
| **Ruleset name** | `Protect main` |
| **Enforcement status** | Active |
| **Target branches** | Add pattern: `main` (add `master` if you use it) |
| **Restrict deletions** | Enable |
| **Require a pull request before merging** | Enable (optional: required approvals ≥ 1) |
| **Require status checks to pass** | Enable |
| **Require branches to be up to date before merging** | Enable (recommended) |

Under **Status checks that are required**, add these **exact** names (they come from the `name:` field of each job in `.github/workflows/ci.yml`):

1. `Backend API (dart analyze)`
2. `shared_models (test)`
3. `Admin app (flutter analyze)`
4. `Firebase options policy (no prod project in repo)`

If a name does not appear in the search box, open a PR, wait for CI to finish, then refresh the ruleset page.

**Optional:** Add the same ruleset for branch pattern `develop` if you use it as an integration branch.

---

## 3. Classic branch protection (alternative)

**Settings** → **Branches** → **Add branch protection rule** → Branch name pattern `main`:

- Require a pull request before merging
- Require status checks to pass before merging  
- Require branches to be up to date before merging  
- Select the same four status checks as above  

---

## 4. Org-level rules

If the repo lives under an organization, an owner can define **repository rules** or **rulesets** at the org level for consistency.

---

## 5. Related

- **`.github/workflows/ci.yml`**
- **`docs/RELEASE_GATE_CHECKLIST.md`**
- **`docs/environment_separation_p0.md`**
