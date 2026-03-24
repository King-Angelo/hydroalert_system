# Access control & audit (P1)

**Principle:** Separated roles; **least privilege**; **prod** data accessible only to authorized operators and systems.

---

## English

### 1. Application roles (product)

| Role | Access (summary) |
|------|------------------|
| **Resident user** | Survival-centric features; submit **Incident_Reports**; receive notifications; **no** admin console. |
| **Official** | Barangay official workflows as implemented in the official app (per Firestore rules and `user_type`). |
| **Barangay Administrator** (`user_type: admin`) | **Admin app**: sensor/IoT view, user management (policy-bound), incident validation, system logs read, manual override (when API configured), shelter logistics. **Exclusive operational authority** per project charter. |
| **Emergency responders / DRRM** | Operational monitoring and verified logs as implemented (may share admin accounts or dedicated accounts per Barangay policy — document locally). |

Firebase Auth + Firestore `Users` document governs **admin** eligibility (`user_type == admin` and `is_active == true`) — see [firestore_schema.md](../firestore_schema.md).

### 2. Technical roles (TIP team)

| Capability | Who |
|------------|-----|
| GitHub org/repo, branch protection | TIP + CCS policy |
| Firebase console (IAM, rules, Auth) | TIP (named individuals) |
| Render service config & env | TIP |
| Service account JSON distribution | TIP only; secure channel |

### 3. Audit evidence (Firestore — canonical names)

Stakeholders may refer to “automatic logs” or legacy names; **this repository’s schema** uses:

| Evidence | Collection / path | Notes |
|----------|-------------------|-------|
| Privileged admin/API actions | **`System_Logs`** | Types include `report_review`, `user_management_action`, `shelter_update`, `manual_override` — see schema. |
| Resident flood / incident submissions | **`Incident_Reports`** | Status workflow `Pending` / `Validated` / `Rejected`. |
| Sensor telemetry & device health | **`IoT_Devices`** and subcollection **`readings`** | `last_seen_at`, `latest_reading` for dashboards. |
| Account identity & tokens (sensitive) | **`Users`** | `device_tokens`, `location` — restrict export; NPC-aligned handling. |

**Retention:** `System_Logs` retention job — [database_operations.md](../database_operations.md).

**Console audit:** Where available, enable and periodically review **Google Cloud / Firebase audit logs** for IAM and rules changes (TIP).

### 4. Operator checklist (quarterly)

- [ ] Admin user list reviewed; deactivate departed staff (`is_active: false`).  
- [ ] Firebase IAM: remove unused accounts.  
- [ ] GitHub: 2FA for org members; rotate PATs if any.  
- [ ] Confirm `System_Logs` visible in admin app for recent critical actions.

### 5. Access violations

1. Revoke credentials immediately.  
2. Preserve logs before deletion.  
3. Notify **Project Adviser / CCS** and follow institutional policy.  
4. Execute [key_rotation_policy.md](key_rotation_policy.md) if secrets were exposed.

---

## Filipino (Tagalog)

### 1. Mga tungkulin sa app

- **Resident** — mga feature para sa kaligtasan; magsumite ng report; walang admin console.  
- **Official** — ayon sa app at patakaran.  
- **Barangay Administrator** — buong admin app para sa monitoring, validation, at logs; **eksklusibong awtoridad** sa operasyon.  
- **Responders / DRRM** — monitoring at verified logs ayon sa lokal na setup ng account.

### 2. TIP (teknikal)

Firebase console, Render, GitHub — TIP at patakaran ng CCS.

### 3. Ebidensya ng audit

- **`System_Logs`** — mga aksyon ng admin/API.  
- **`Incident_Reports`** — mga insidente mula resident.  
- **`IoT_Devices`** / **`readings`** — datos ng sensor.  
- **`Users`** — sensitibong datos; limitadong access.

### 4. Ika-tatlumpung araw / quarterly

Suriin ang admin users, IAM, GitHub, at visibility ng logs.

### 5. Paglabag

I-revoke agad; panatilihin ang logs; i-report sa Adviser/CCS; i-rotate ang sikreto kung kailangan.
