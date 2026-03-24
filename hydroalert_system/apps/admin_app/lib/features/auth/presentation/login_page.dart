import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/ui/app_feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/locale_controller.dart';
import '../data/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authService,
    this.sessionExpiredMessage,
  });

  final AuthService authService;
  /// Shown after [Navigator] replaces stack (e.g. session ended).
  final String? sessionExpiredMessage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _rememberMe = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: kDebugMode ? 'admin@hydroalert.local' : '',
    );
    _passwordController = TextEditingController(
      text: kDebugMode ? 'admin123' : '',
    );
    final expired = widget.sessionExpiredMessage;
    if (expired != null && expired.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showAppSnackBar(context, expired, isError: true);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = context.l10n;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _submitting) return;

    setState(() => _submitting = true);

    final result = await widget.authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.ok) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      return;
    }

    showAppSnackBar(
      context,
      _errorMessage(l10n, result.errorCode),
      isError: true,
    );
  }

  Future<void> _handleForgotPassword() async {
    final l10n = context.l10n;
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      showAppSnackBar(context, l10n.emailInvalid, isError: true);
      return;
    }

    final errorCode = await widget.authService.sendPasswordReset(email: email);
    if (!mounted) return;

    final message = errorCode == null
        ? l10n.passwordResetEmailSent
        : l10n.passwordResetFailed;
    showAppSnackBar(
      context,
      message,
      isError: errorCode != null,
    );
  }

  String _errorMessage(AppLocalizations l10n, String? errorCode) {
    switch (errorCode) {
      case 'auth-not-admin':
        return l10n.authAdminRequired;
      case 'wrong-password':
        return l10n.authWrongPassword;
      case 'user-not-found':
        return l10n.authUserNotFound;
      case 'invalid-email':
        return l10n.emailInvalid;
      case 'invalid-credential':
        return l10n.authInvalidCredential;
      case 'too-many-requests':
        return l10n.authTooManyRequests;
      case 'network-request-failed':
      case 'internal-error':
        return l10n.authNetworkFailed;
      case 'mock-invalid-input':
        return l10n.mockSignInFailed;
      default:
        return l10n.authSignInFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _CyberLoginBackdrop(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: AdminCyberDecor.loginCardFrame(),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: _LanguageMenuButton(
                                currentLocale:
                                    Localizations.localeOf(context),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Icon(
                              Icons.shield_moon_outlined,
                              size: 44,
                              color: AdminColors.primary,
                              shadows: [
                                Shadow(
                                  color: AdminColors.primary
                                      .withValues(alpha: 0.9),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.loginTitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.orbitron(
                                textStyle:
                                    Theme.of(context).textTheme.titleLarge,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Semantics(
                              label: l10n.semanticLoginEmail,
                              textField: true,
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration: InputDecoration(
                                  labelText: l10n.emailLabel,
                                  hintText: l10n.emailHint,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.emailRequired;
                                  }
                                  if (!value.contains('@')) {
                                    return l10n.emailInvalid;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Semantics(
                              label: l10n.semanticLoginPassword,
                              textField: true,
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                autofillHints: const [AutofillHints.password],
                                decoration: InputDecoration(
                                  labelText: l10n.passwordLabel,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.passwordRequired;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final compact =
                                    constraints.maxWidth < 360;

                                final rememberRow = MergeSemantics(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Semantics(
                                        label: l10n.semanticRememberMe,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) => setState(
                                            () => _rememberMe =
                                                value ?? false,
                                          ),
                                        ),
                                      ),
                                      Text(l10n.rememberMe),
                                    ],
                                  ),
                                );

                                final forgotButton = TextButton(
                                  onPressed: _submitting
                                      ? null
                                      : _handleForgotPassword,
                                  child: Text(l10n.forgotPassword),
                                );

                                if (compact) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      rememberRow,
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: forgotButton,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    rememberRow,
                                    const Spacer(),
                                    Flexible(child: forgotButton),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed:
                                  _submitting ? null : _handleLogin,
                              child: _submitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(l10n.signIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberLoginBackdrop extends StatelessWidget {
  const _CyberLoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AdminColors.background,
                AdminColors.backgroundMid,
                const Color(0xFF12081F),
                const Color(0xFF1A0A28),
              ],
              stops: const [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),
        const IgnorePointer(child: CustomPaint(painter: _HexGridPainter())),
      ],
    );
  }
}

class _HexGridPainter extends CustomPainter {
  const _HexGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AdminColors.primary.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const step = 48.0;
    for (double y = 0; y < size.height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LanguageMenuButton extends StatelessWidget {
  const _LanguageMenuButton({required this.currentLocale});

  final Locale currentLocale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopupMenuButton<String>(
      tooltip: l10n.languageLabel,
      initialValue: currentLocale.languageCode,
      onSelected: (value) => LocaleController.setLocale(Locale(value)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'en',
          child: Text(l10n.languageEnglish),
        ),
        PopupMenuItem(
          value: 'fil',
          child: Text(l10n.languageFilipino),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AdminColors.surfaceAlt,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AdminColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 16),
            const SizedBox(width: 6),
            Text(
              currentLocale.languageCode.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}