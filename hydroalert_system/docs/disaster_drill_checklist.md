# Disaster drill checklist (P1)

Run on **staging** first. Check each box and note **time**, **owner**, and **anomalies**.

**Date:** _______________  **Facilitator:** _______________

---

## A. Preconditions

- [ ] Staging Firebase project + Render (or host) URL documented  
- [ ] Admin app build points at **staging** API + Firebase (`HYDROADMIN_API_BASE_URL`, correct `firebase_options`)  
- [ ] At least one **test** user with `device_tokens` + `location.zone` aligned with drill scenario  
- [ ] `FCM_DRY_RUN` decision: **on** for safe rehearsal, **off** only if sending real pushes to test devices is approved  

---

## B. Sensor / data path

- [ ] **Telemetry** written to `IoT_Devices` (or readings subcollection per schema)  
- [ ] **Admin → IoT devices** shows updated **last seen** / levels  
- [ ] **Operations & health** shows API **reachable** and sensor **not stale** (or intentionally stale for fault drill)  

---

## C. Alert path (manual or automated)

- [ ] Trigger **manual override** (or automated threshold path when implemented) for the test zone  
- [ ] **System_Logs** contains `manual_override` (or equivalent) with expected `push` fields  
- [ ] **Target device(s)** receive notification **within agreed window** (goal ≤ 30 s end-to-end when full pipeline exists)  
- [ ] If **dry run**: confirm logs show dry-run / validate-only behavior  

---

## D. Degraded modes

- [ ] **API stopped** or wrong URL: admin shows failure; no silent success  
- [ ] **Wrong zone string**: no unintended recipients (spot-check `Users` query assumptions)  
- [ ] **Rate limit / dedupe**: second identical send within window is skipped as designed  

---

## E. Post-drill

- [ ] Export or screenshot **critical logs** (Render + Firestore `System_Logs`) for **post-disaster analysis** archive  
- [ ] File issues for gaps (latency, UX, missing timestamps)  
- [ ] Update [qa_reliability_p1.md](qa_reliability_p1.md) if process changes  

---

## Notes

_Use this space for timings, participant feedback, and follow-ups._
