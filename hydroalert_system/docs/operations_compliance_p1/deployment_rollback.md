# Deployment & rollback plan (P1)

**Context:** “Modern Waterfall” lifecycle — **final adjustments** before **pilot**; **maintenance & evaluation** allows limited revisions. This doc maps that to **Git + Render + Firebase** as implemented in the repo.

---

## English

### 1. Source of truth

- **Application code:** Git repository (`main` / protected branches per [GITHUB_BRANCH_PROTECTION.md](../GITHUB_BRANCH_PROTECTION.md)).  
- **Promotion checks:** [RELEASE_GATE_CHECKLIST.md](../RELEASE_GATE_CHECKLIST.md).  
- **API hosting:** Render — [DEPLOY_RENDER.md](../../backend/api/DEPLOY_RENDER.md), [RENDER_PER_ENVIRONMENT.md](../RENDER_PER_ENVIRONMENT.md).

### 2. Normal deploy (prod)

1. Merge tested changes to the release branch per team policy.  
2. CI green ([`ci.yml`](../../.github/workflows/ci.yml)).  
3. Render deploys from connected branch (auto or manual — document which you use in [artifact_merge_register.md](artifact_merge_register.md) note).  
4. Post-deploy: hit health endpoint; spot-check admin login and **System Logs** write path.

### 3. Rollback (preferred order)

| Layer | Action |
|-------|--------|
| **Render** | Use Render **rollback** to previous successful deploy **or** redeploy prior **Git commit** (same image/build). |
| **API env vars** | If misconfiguration: revert env in Render dashboard; redeploy. |
| **Firestore rules / indexes** | Revert via Git-tracked `firestore.rules` / `firestore.indexes.json` and `firebase deploy` from TIP (document project alias). |
| **Mobile apps** | Roll back by shipping previous store/build version; hotfix forward if stores delay is unacceptable. |

**Firebase Cloud Functions:** If you add Functions later, rollback = deploy previous function version or redeploy from known-good tag; note revision ID in change log.

### 4. When NOT to rollback blindly

- Data migration already applied — coordinate with TIP; may need **forward fix**.  
- Security incident — prefer **isolate + rotate secrets** ([key_rotation_policy.md](key_rotation_policy.md)) before re-enabling traffic.

### 5. Communication

- Barangay Administrator: inform if **public-facing** behavior changes or outage > agreed threshold.  
- Document **start/end** time and owner in shift log + optional `System_Logs` note if you maintain an incident type.

### 6. Pilot (dev ~50 participants)

- Use **dev** Firebase project and dev API URL; never pilot against **prod** user PII without explicit approval.  
- After pilot, capture “functional gaps” in maintenance notes and link from [artifact_merge_register.md](artifact_merge_register.md).

---

## Filipino (Tagalog)

### 1. Pinagmulan ng katotohanan

Ang code ay nasa **Git**; ang API sa **Render**. Sundin ang release gate at branch protection.

### 2. Karaniwang deploy (prod)

CI green → deploy sa Render → suriin ang health at login.

### 3. Rollback

Unahin ang **Render rollback** o **muling-deploy** ng nakaraang commit.  
Ibalik ang maling **env vars**.  
Ang Firestore rules ay mula sa Git + `firebase deploy`.  
Ang mobile app ay maaaring **bumalik sa nakaraang build** kung kinakailangan.

### 4. Pag-iingat

Kung may data migration na, hindi laging ang rollback ang tamang solusyon — kumonsulta sa TIP.

### 5. Komunikasyon

Ipaalam sa Barangay Admin kung may outage o malaking pagbabago.

### 6. Pilot (dev)

Gamitin ang **dev** na project para sa ~50 kalahok; iwasan ang prod PII nang walang pahintulot.
