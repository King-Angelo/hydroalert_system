import 'package:flutter/material.dart';

/// Consistent SnackBar UX: floating, optional error styling, dismiss affordance.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Semantics(
          liveRegion: true,
          child: Text(message),
        ),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: isError ? scheme.error : scheme.inverseSurface,
        showCloseIcon: true,
        closeIconColor: isError ? scheme.onError : scheme.onInverseSurface,
      ),
    );
}

/// Avoid dumping huge exception blobs into the UI.
String truncateErrorDetails(Object error, {int maxLen = 220}) {
  final s = error.toString().trim();
  if (s.length <= maxLen) return s;
  return '${s.substring(0, maxLen)}…';
}
