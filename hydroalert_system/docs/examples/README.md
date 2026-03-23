# Example config files

| File | Use |
|------|-----|
| [backend-api.env.example](backend-api.env.example) | Template for backend API environment variables (dev/staging/prod). |
| [render-multi-env.yaml](render-multi-env.yaml) | Example Render Blueprint with **three** Web Services (dev / staging / prod); add secrets in the dashboard. |
| [build-admin-web-staging.workflow.yml](build-admin-web-staging.workflow.yml) | Copy to `.github/workflows/` for optional **staging** admin web builds (Firebase options from a secret). |

Copy and fill locally or configure equivalent keys in your host (e.g. Render) **per environment**.
