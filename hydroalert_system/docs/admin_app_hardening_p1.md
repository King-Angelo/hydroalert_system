# Admin app hardening (P1)

## Localization

- UI strings live in **`apps/admin_app/lib/l10n/app_localizations.dart`** (English + Filipino).
- Prefer `context.l10n.*` everywhere user-visible; keep Firestore/API **values** (e.g. `Pending`, `Open`) in English where the backend expects them—only **labels** are translated.

## Consistent error / success feedback

- Use **`lib/core/ui/app_feedback.dart`** → `showAppSnackBar(context, message, isError: …)` for SnackBars (floating, dismiss icon, semantic live region for errors).
- Long exceptions: `truncateErrorDetails(error)` before showing text.

## Session end & re-auth

- **`AuthService.sessionTerminated`**: Firebase `idTokenChanges` where user becomes `null` (sign-out, revocation, etc.).
- **`AdminShellPage`** listens and navigates to login with **`sessionTerminatedMessage`** as route arguments; **`LoginPage`** shows it on first frame.
- **`ManualOverrideApiClient`**: HTTP **401** triggers optional **`onUnauthorized`** (wired in `main.dart` to **`authService.signOut`**) so expired API sessions align with Firebase sign-out when the backend rejects the token.

## Input validation

- **`lib/core/validation/admin_input_limits.dart`** — shared max lengths.
- **`manual_alert_validators.dart`** — zone + message rules for the manual FCM override card (Form + `TextFormField` validators).
- Review notes dialogs: **`AdminInputLimits.reviewNotesMaxLength`**.

## Accessibility (pass)

- Login: **`Semantics`** on email/password fields; **`MergeSemantics`** + checkbox label; **`autofillHints`** for email/password.
- Shell: compact nav **`Semantics(label: …, button: true)`**; sign-out button labeled.
- SnackBars: **`Semantics(liveRegion: true)`** on content for screen readers.
- **Manual check**: run with TalkBack / VoiceOver; verify focus order on login and sidebar; confirm contrast on error SnackBars (uses theme `colorScheme.error` / `inverseSurface`).

## Related

- QA / reliability: [qa_reliability_p1.md](qa_reliability_p1.md)  
- Environment / API base URL: [environment_separation_p0.md](environment_separation_p0.md)
