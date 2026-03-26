# Phase A3 — Real Firebase auth (not mocks)

**Goal:** Admin uses **`FirebaseAuthService`** when Firebase initializes so **`getIdToken()`** returns a real JWT for **`ManualOverrideApiClient`** and other `Authorization: Bearer` calls.

---

## Behavior

| Condition | Auth implementation |
|-----------|------------------------|
| `Firebase.initializeApp` succeeds (`firebaseReady == true`) | **`FirebaseAuthService`** — email/password, **Google (web)**, **`getIdToken`**, admin gate via **`Users/{uid}`** |
| Unsupported platform or init failure | **`MockAuthService`** — **`getIdToken` → null**; HTTP API client is not created unless Firebase also failed partially (see `main.dart`) |

In **debug**, startup logs: `authService=FirebaseAuthService` or `MockAuthService`.

---

## Requirements

1. **Firebase** options + init (Phase A1).
2. **Users** document: `user_type == 'admin'` and `is_active == true` for the signed-in UID (same check after email/password and Google).
3. **Google (web):** Enabled in Firebase Console; OAuth origins/authorized domains (Phase A2 / Console). Login shows **Continue with Google** only when **`supportsGoogleSignIn`** (currently **web + `FirebaseAuthService`**).

---

## Email / password

Handled in **`FirebaseAuthService.signIn`** → **`signInWithEmailAndPassword`**, then **`_isAdminAllowed`**.

## Google (admin web)

**`signInWithPopup(GoogleAuthProvider())`**, then the same admin check. Non-web targets return **`auth-google-web-only`** (admin product is web-first).
