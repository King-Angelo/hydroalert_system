# Vendored `dart_firebase_admin_plus` (pub 0.5.0)

## Why this copy exists

Upstream `DecodedIdToken.fromMap` (in `lib/src/auth/token_verifier.dart`) incorrectly read:

- `sign_in_provider`, MFA fields, and `identities` from the **JWT root**
- `uid` only from `uid`

Firebase ID tokens place `sign_in_provider`, `identities`, and related fields under the **`firebase`** claim. Google / OIDC sign-in therefore hit `map['sign_in_provider']!` when that key was null → **Null check operator used on a null value** during `verifyIdToken`, which surfaced as HTTP **401** and logged the user out of the admin web app.

## Patch

- Read nested `firebase` / `firebase.identities` / `firebase.sign_in_provider` (and MFA / tenant fields from the same map).
- Resolve `uid` from `uid`, then `user_id`, then `sub`.

## Maintenance

When bumping the dependency on pub.dev, merge changes into this tree or re-apply the patch, then run `dart analyze` in `backend/api`.
