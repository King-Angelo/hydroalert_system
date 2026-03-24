# Runbook: Daily monitoring & flood dashboard (P1)

**Roles:** Barangay Administrator, DRRM / Emergency Responders (primary); TIP team (support, break-fix).  
**Apps:** Admin dashboard (control unit), resident/official apps as applicable.  
**Related:** [observability_p1.md](../observability_p1.md), [admin_app_hardening_p1.md](../admin_app_hardening_p1.md), [disaster_drill_checklist.md](../disaster_drill_checklist.md).

---

## English

### 1. Preconditions

- [ ] You are using the **production** Firebase project and **production** API URL for live operations (see [environment_separation_p0.md](../environment_separation_p0.md)).  
- [ ] Admin account is **active** (`user_type: admin`, `is_active: true` in Firestore `Users`).  
- [ ] You know who to call on the **TIP** side if the dashboard or API is down (see [README.md](README.md) governance table).

### 2. Morning / shift start (5–10 minutes)

1. Open the **Admin** app → **Dashboard**.  
2. Check **Operations & health** (if enabled): API reachable; sensor summary not stale.  
3. Open **IoT devices**: confirm **last seen** / readings look recent for active zones.  
4. Open **System Logs** (recent window): scan for errors, failed `manual_override`, or unusual spikes.  
5. Note anything abnormal in the **shift log** (paper or shared doc — Barangay procedure).

### 3. During elevated weather (continuous)

1. Prefer **verified** shelter and zone data in **production** only.  
2. When issuing warnings: follow [incident_response_sop.md](incident_response_sop.md) severity mapping (Yellow / Orange / Red).  
3. Use **FCM** paths documented in [notifications_fcm_p0.md](../notifications_fcm_p0.md); admin **manual override** only by authorized operators.  
4. After each significant action, confirm a matching entry appears in **System_Logs** (audit).

### 4. End of shift

1. Hand off **open issues** (stale sensors, failed pushes, account lockouts).  
2. If prod was changed (config, accounts), record **who / when / what** per Barangay policy.

### 5. When to escalate to TIP

- API unreachable or repeated **401** / auth failures.  
- Massive FCM failures in `System_Logs` `manual_override` push fields.  
- Firestore rules or Firebase project access errors.  
- Suspected **secret leak** → also follow [key_rotation_policy.md](key_rotation_policy.md).

---

## Filipino (Tagalog)

### 1. Mga paunang kondisyon

- [ ] **Production** ang Firebase at API para sa live na operasyon.  
- [ ] Aktibo ang admin account.  
- [ ] Alam kung sino ang TIP contact kung may teknikal na sira.

### 2. Simula ng shift (5–10 minuto)

1. Buksan ang **Admin** app → **Dashboard**.  
2. Suriin ang **Operations & health** at **IoT devices** (huling reading / last seen).  
3. Tingnan ang **System Logs** para sa error o abnormal na aktibidad.  
4. Itala ang aberya sa shift log ng Barangay.

### 3. Kapag masama ang panahon

Sundin ang [incident_response_sop.md](incident_response_sop.md) para sa **Yellow / Orange / Red**.  
Gamitin lamang ang awtorisadong paraan ng abiso (FCM — tingnan ang notifications doc).  
Dapat may **System_Logs** entry ang mahahalagang aksyon.

### 4. Pagpasa ng shift

Ilista ang bukas na isyu at mga pagbabago sa prod.

### 5. Kailan tawagan ang TIP

API down, maraming failed push, Firebase/Rules error, o posibleng **leak** ng sikreto.
