import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/ui/app_feedback.dart';
import '../../../core/validation/admin_input_limits.dart';
import '../../../core/validation/manual_alert_validators.dart';
import '../../../l10n/app_localizations.dart';
import '../data/manual_override_api_client.dart';

/// Sends [POST /v1/alerts/manual-override] (FCM token multicast to zone).
class ZoneManualAlertCard extends StatefulWidget {
  const ZoneManualAlertCard({super.key, this.apiClient});

  final ManualOverrideApiClient? apiClient;

  @override
  State<ZoneManualAlertCard> createState() => _ZoneManualAlertCardState();
}

class _ZoneManualAlertCardState extends State<ZoneManualAlertCard> {
  final _formKey = GlobalKey<FormState>();
  final _zoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _severity = 'Advisory';
  bool _sending = false;

  static const _severities = ['Normal', 'Advisory', 'Watch', 'Warning'];

  @override
  void dispose() {
    _zoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final client = widget.apiClient;
    final l10n = context.l10n;
    if (client == null) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final zone = _zoneCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    setState(() => _sending = true);
    try {
      await client.sendManualOverride(
        severity: _severity,
        message: message,
        targetZone: zone,
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        l10n.manualAlertSent,
        duration: const Duration(seconds: 5),
      );
    } on ManualOverrideApiException catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        l10n.manualAlertFailed(truncateErrorDetails(e)),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        l10n.manualAlertFailed(truncateErrorDetails(e)),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final client = widget.apiClient;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_outlined,
                      color: AdminColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.manualAlertTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                client == null
                    ? l10n.manualAlertApiDisabled
                    : l10n.manualAlertSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (client != null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _zoneCtrl,
                  maxLength: AdminInputLimits.manualAlertZoneMaxLength,
                  decoration: InputDecoration(
                    labelText: l10n.manualAlertZoneLabel,
                    hintText: l10n.manualAlertZoneHint,
                  ),
                  validator: (v) => validateManualAlertZone(v, l10n),
                ),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.manualAlertSeverityLabel,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _severity,
                      items: [
                        for (final s in _severities)
                          DropdownMenuItem(value: s, child: Text(s)),
                      ],
                      onChanged: _sending
                          ? null
                          : (v) => setState(() => _severity = v ?? _severity),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageCtrl,
                  maxLines: 3,
                  maxLength: AdminInputLimits.manualAlertMessageMaxLength,
                  decoration: InputDecoration(
                    labelText: l10n.manualAlertMessageLabel,
                  ),
                  validator: (v) => validateManualAlertMessage(v, l10n),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _sending ? null : _submit,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(l10n.manualAlertSend),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
