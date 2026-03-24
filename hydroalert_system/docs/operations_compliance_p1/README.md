# Operations & Compliance (P1) — HydroAlert

**Document set version:** 1.0  
**Repository path:** `docs/operations_compliance_p1/`  
**Technical stack (reference):** Firebase + Render API + Flutter apps — see [environment_separation_p0.md](../environment_separation_p0.md).

---

## English

### Purpose

This folder is the **master compliance pack** for **operations** (Barangay Administrator, Emergency Responders / DRRM) and **technical implementation** (TIP development team). It links runbooks, incident response, access control, key rotation, and deployment rollback to **existing** engineering docs in this monorepo.

### Governance & approval

| Role | Responsibility |
|------|------------------|
| **Barangay Administrator & Emergency Responders** | Exclusive operational authority to monitor sensors, manage accounts (within policy), validate incidents, and execute flood-dashboard procedures. |
| **TIP development team** (Dino, Eco, Mangahas, Vicente) | Technical implementation, Firebase/GCP/Render configuration, secure development practices, and maintenance of this repository. |
| **Project Adviser** (Ms. Jenelyn Aranas) & **CCS faculty** | **Formal approval** of this document set for academic / institutional compliance. |

**Approval record:** Use [approval_record_template.md](approval_record_template.md) (print or PDF export).

### Environments (operational truth)

| Tier | Use | Drills |
|------|-----|--------|
| **Dev** | Internal validation; pilot (~50 participants) | Secondary |
| **Prod** | Live Barangay 728; official shelters; live IoT | **Authoritative** |

> **Note:** Some engineering docs still mention an optional **staging** Firebase project for safe rehearsal. Operationally you run **dev + prod**; if staging is unused, treat it as *optional* in those docs.

### Document index (read in this order for onboarding)

| # | Document | Audience |
|---|----------|----------|
| 1 | [runbook_daily_monitoring.md](runbook_daily_monitoring.md) | Barangay Admin, DRRM, TIP (support) |
| 2 | [incident_response_sop.md](incident_response_sop.md) | Barangay Admin, DRRM, TIP (support) |
| 3 | [access_control_audit.md](access_control_audit.md) | TIP (primary), Barangay Admin (account policy) |
| 4 | [key_rotation_policy.md](key_rotation_policy.md) | TIP (primary) |
| 5 | [deployment_rollback.md](deployment_rollback.md) | TIP (primary), Barangay Admin (awareness) |
| 6 | [artifact_merge_register.md](artifact_merge_register.md) | Adviser, CCS, TIP |

### Existing repo artifacts (do not duplicate — link here)

| Topic | Location |
|-------|----------|
| Environment separation & secrets | [environment_separation_p0.md](../environment_separation_p0.md) |
| Render per environment | [RENDER_PER_ENVIRONMENT.md](../RENDER_PER_ENVIRONMENT.md) |
| Release gate (promotion checks) | [RELEASE_GATE_CHECKLIST.md](../RELEASE_GATE_CHECKLIST.md) |
| Branch protection / CI | [GITHUB_BRANCH_PROTECTION.md](../GITHUB_BRANCH_PROTECTION.md) |
| Disaster drill (staging/prod rehearsal) | [disaster_drill_checklist.md](../disaster_drill_checklist.md) |
| QA & reliability | [qa_reliability_p1.md](../qa_reliability_p1.md) |
| Admin app hardening | [admin_app_hardening_p1.md](../admin_app_hardening_p1.md) |
| FCM / notifications | [notifications_fcm_p0.md](../notifications_fcm_p0.md) |
| Firestore schema (audit collections) | [firestore_schema.md](../firestore_schema.md) |
| System log retention | [database_operations.md](../database_operations.md) |
| API deploy (Render) | [../../backend/api/DEPLOY_RENDER.md](../../backend/api/DEPLOY_RENDER.md) |

### Tools (as mandated by the project)

- **Development:** Visual Studio Code.  
- **Policy / access enforcement:** Google Cloud / **Firebase console** (IAM, Firestore rules, Auth).  
- **Source & change control:** GitHub (see branch protection doc).

---

## Filipino (Tagalog)

### Layunin

Ang folder na ito ang **pangunahing compliance pack** para sa **operasyon** (Barangay Administrator, Emergency Responders / DRRM) at **teknikal na implementasyon** (TIP dev team). Hinihikayat ang **bilingual** na runbooks para sa accessibility at community-centered communication.

### Pamamahala at pag-apruba

| Tungkulin | Responsibilidad |
|-----------|-----------------|
| **Barangay Administrator at Emergency Responders** | Eksklusibong awtoridad sa pang-araw-araw na monitoring ng sensor, pamamahala ng account (ayon sa patakaran), pag-validate ng insidente, at paggamit ng flood dashboard. |
| **TIP development team** | Teknikal na setup, seguridad, at maintenance ng repository. |
| **Project Adviser (Ms. Jenelyn Aranas) at CCS faculty** | **Opisyal na pag-apruba** ng dokumentong ito. |

**Rekord ng apruba:** [approval_record_template.md](approval_record_template.md)

### Kapaligiran (operasyon)

| Tier | Gamit | Drill |
|------|-------|-------|
| **Dev** | Internal / pilot (~50 kalahok) | Pangalawang priyoridad |
| **Prod** | Live na Barangay 728; opisyal na shelter; live IoT | **Ito ang batayan ng drill** |

### Indeks ng mga dokumento

Tingnan ang mga link sa talahanayan sa **English** section sa itaas — pareho ang mga file; babasahin ang bawat dokumento may **English** at **Filipino** na seksyon.

### Umiiral nang mga dokumento sa repo

Ang teknikal na detalye (Firebase, Render, schema) ay nasa mga linked doc sa itaas; **huwag kopyahin** — **i-link** lamang sa compliance reports.

---

## Revision history

| Version | Date | Author team | Notes |
|---------|------|-------------|-------|
| 1.0 | 2026-03 | TIP HydroAlert | Initial P1 pack |
