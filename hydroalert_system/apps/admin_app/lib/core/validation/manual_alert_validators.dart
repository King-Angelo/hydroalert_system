import '../../l10n/app_localizations.dart';
import 'admin_input_limits.dart';

String? validateManualAlertZone(String? raw, AppLocalizations l10n) {
  final t = raw?.trim() ?? '';
  if (t.isEmpty) return l10n.validationZoneRequired;
  if (t.length > AdminInputLimits.manualAlertZoneMaxLength) {
    return l10n.validationZoneTooLong;
  }
  return null;
}

String? validateManualAlertMessage(String? raw, AppLocalizations l10n) {
  final t = raw?.trim() ?? '';
  if (t.isEmpty) return l10n.validationMessageRequired;
  if (t.length > AdminInputLimits.manualAlertMessageMaxLength) {
    return l10n.validationMessageTooLong;
  }
  return null;
}
