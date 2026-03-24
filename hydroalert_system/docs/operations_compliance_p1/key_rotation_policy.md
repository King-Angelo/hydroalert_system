# Key & secret rotation policy (P1) — event-driven

**Owner:** TIP development team (execution); Barangay Administrator notified for user-facing impacts.  
**Philosophy:** **Event-driven rotation** during maintenance or incident response; optional **annual review** as the project matures.

---

## English

### 1. Secret inventory (critical)

| Secret | Typical storage | Rotation trigger |
|--------|-----------------|------------------|
| **Firebase service account** JSON | Render env / secure vault — **never Git** | Suspected leak; offboarding of deployer; annual review |
| **FCM / Firebase Admin** credentials | Same; uses service account for HTTP v1 | Same as above |
| **`GOOGLE_MAPS_API_KEY`** | App/build defines or secure config | Abuse on map quota; key visible in client builds — restrict by bundle + HTTP referrer in GCP |
| **Firebase Web API keys** | In apps (public by design) | Rotate if abuse; tighten **App Check** / rules (see Firebase console) |
| **GitHub / CI tokens** | GitHub secrets | Offboarding; token scope change |

See also: [environment_separation_p0.md](../environment_separation_p0.md), [examples/backend-api.env.example](../examples/backend-api.env.example).

### 2. Rotation procedure (generic)

1. **Classify** event (leak suspected vs planned maintenance).  
2. **Generate** new credential in Firebase/GCP (least privilege).  
3. **Deploy** new value to **dev** first; smoke-test admin + API.  
4. **Deploy** to **prod** during agreed window; monitor **System_Logs** and Render logs.  
5. **Revoke** old key after confirmation.  
6. **Document** date, owner, and ticket/adviser notification in [artifact_merge_register.md](artifact_merge_register.md) or project log.

### 3. Client-visible keys (Maps)

- Assume **mobile keys can be extracted** — rely on **API key restrictions** and **usage quotas**.  
- After rotation, rebuild affected apps with new defines; coordinate pilot if needed.

### 4. What Barangay operators should NOT do

- Do not paste service account JSON into messages or screenshots.  
- Do not create ad-hoc Firebase projects for production data without TIP approval.

---

## Filipino (Tagalog)

### 1. Mga sikreto

Ang mga kritikal na sikreto (Firebase service account, FCM, Maps API key) ay naka-store nang ligtas — **hindi** sa Git.  
Tingnan ang environment doc para sa template.

### 2. Kailan i-rotate

- Kahina-hinalang **leak** o kompromiso.  
- Pag-alis ng may access sa deployment.  
- Pag-maintina o pag-aayos ng seguridad.  
- Opsyonal: **taunang** pagsusuri.

### 3. Proseso

Gumawa ng bagong credential → subukan sa **dev** → ilapat sa **prod** → i-revoke ang luma → itala ang petsa at may-akda.

### 4. Hindi dapat gawin ng Barangay ops

Huwag magbahagi ng JSON ng service account o mga sikreto sa chat o screenshot.
