# Incident response SOP — HydroAlert (P1)

**Aligned severity (operational):** **Yellow (Advisory)** · **Orange (Watch)** · **Red (Warning)**  
**Technical mapping:** Backend / FCM also uses `Normal`, `Advisory`, `Watch`, `Warning` — see [firestore_schema.md](../firestore_schema.md) enum `alert_severity`. For public communication, use **Yellow / Orange / Red** as below.

---

## English

### A. Roles

| Role | Duty |
|------|------|
| **Barangay Administrator** | Decision authority on warnings, account actions, incident validation. |
| **DRRM / Emergency Responders** | Continuous monitoring of flood dashboard; rapid response; field coordination. |
| **TIP team** | Restore service (API, Firebase, apps); post-incident technical report; support NPC-aligned data handling. |

### B. Severity model (operator-facing)

| Tier | Meaning | Typical actions |
|------|---------|-----------------|
| **Yellow — Advisory** | Elevated awareness; localized or early signal | Increase monitoring frequency; verify sensors; prepare messaging templates; optional targeted notice per Barangay policy. |
| **Orange — Watch** | Significant hazard likely; protective action planning | Coordinate with **Manila DRRMO** per local protocol; pre-position resources; narrowcast/broadcast per approved channels; use admin dashboard as **control unit**. |
| **Red — Warning** | Danger imminent or occurring; immediate protective action | Execute last-mile warning plan (**FCM** lock-screen capable + other Barangay channels); prioritize life safety; document timestamps in **System_Logs**. |

### C. Communication channels

1. **FCM push notifications** — primary digital reach (see [notifications_fcm_p0.md](../notifications_fcm_p0.md)).  
2. **Admin dashboard** — authoritative internal view for operators; manual override only by trained admins.  
3. **Barangay / DRRMO channels** — voice, SMS blast, sirens, barangay networks as required by coordination agreements.

### D. Standard operating sequence (all severities)

1. **Detect** — dashboard, IoT readings, resident reports (`Incident_Reports`).  
2. **Verify** — cross-check sensors + official shelter data in **prod**.  
3. **Decide** — assign Yellow / Orange / Red; record decision owner and time.  
4. **Act** — send notifications per channel policy; log admin actions.  
5. **Document** — ensure `System_Logs` reflects overrides and key decisions (see [access_control_audit.md](access_control_audit.md)).  
6. **Review** — after event, short hotwash (what worked, gaps); link to [disaster_drill_checklist.md](../disaster_drill_checklist.md) for formal drills.

### E. Data privacy (NPC-aligned posture)

- Collect and display **minimum necessary** personal data.  
- Restrict Firestore and console access per [access_control_audit.md](access_control_audit.md).  
- On suspected breach: **contain**, **preserve logs**, notify **Project Adviser / CCS** and follow institutional legal guidance; coordinate with **Manila DRRMO** for public safety messaging without oversharing personal data.

### F. Service degradation / outage

If the **app or API is down** during an event:

1. Switch to **agreed offline procedures** (radio, physical deployment, DRRMO net).  
2. TIP: follow [deployment_rollback.md](deployment_rollback.md) and [qa_reliability_p1.md](../qa_reliability_p1.md) escalation paths.  
3. Do **not** share service account JSON or API keys in chat; use secure channels only.

---

## Filipino (Tagalog)

### A. Mga tungkulin

| Tungkulin | Gawain |
|-----------|--------|
| **Barangay Administrator** | Desisyon sa babala, account, at validation. |
| **DRRM / Responders** | Tuloy-tuloy na monitoring; mabilis na tugon. |
| **TIP** | Ayusin ang serbisyo; teknikal na ulat; suporta sa privacy. |

### B. Antas ng grabidad

| Antas | Kahulugan | Halimbawang aksyon |
|-------|-----------|---------------------|
| **Yellow — Advisory** | Paalala; maagang babala | Mas masinsing monitoring; i-verify ang sensor. |
| **Orange — Watch** | Malaking panganib; maghanda | Makipag-ugnayan sa **Manila DRRMO**; maghanda ng resources at mensahe. |
| **Red — Warning** | Agarang panganib | **Last-mile** na babala (**FCM** + ibang awtorisadong channel); unahin ang buhay; **System_Logs**. |

### C. Komunikasyon

1. **FCM push** — pangunahing digital.  
2. **Admin dashboard** — internal na control unit.  
3. **Barangay / DRRMO** — iba pang channel ayon sa protocol.

### D. Hakbang

Detect → Verify → Decide (Yellow/Orange/Red) → Act → Document → Review.

### E. Privacy

Minimum na datos; limitadong access; kung may breach, i-report sa Adviser/CCS at sumunod sa legal guidance.

### F. Kung down ang sistema

Offline procedures; TIP ayusin ang serbisyo; **huwag** ibahagi ang secrets sa chat.
