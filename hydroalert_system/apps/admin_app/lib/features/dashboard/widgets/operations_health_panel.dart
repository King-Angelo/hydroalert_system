import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/admin_api_config.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../iot_devices/data/iot_devices_repository.dart';

/// P1: API reachability + **sensor health** from `IoT_Devices.last_seen_at`.
class OperationsHealthPanel extends StatefulWidget {
  const OperationsHealthPanel({
    super.key,
    required this.iotDevicesRepository,
  });

  final IotDevicesRepository iotDevicesRepository;

  @override
  State<OperationsHealthPanel> createState() => _OperationsHealthPanelState();
}

class _OperationsHealthPanelState extends State<OperationsHealthPanel> {
  static const _staleAfter = Duration(minutes: 10);
  static const _pingInterval = Duration(seconds: 30);

  Timer? _timer;
  ApiPingState _api = const ApiPingState.unknown();

  @override
  void initState() {
    super.initState();
    _pingApi();
    _timer = Timer.periodic(_pingInterval, (_) => _pingApi());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pingApi() async {
    if (!AdminApiConfig.isConfigured) {
      if (mounted) {
        setState(() => _api = const ApiPingState.notConfigured());
      }
      return;
    }

    final base = AdminApiConfig.baseUrl;
    final uri = Uri.parse('$base/health/detailed');
    final sw = Stopwatch()..start();
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      sw.stop();
      if (!mounted) return;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        int? uptimeSec;
        try {
          final body = jsonDecode(res.body) as Map<String, dynamic>?;
          final u = body?['uptime_seconds'];
          if (u is int) {
            uptimeSec = u;
          } else if (u is num) {
            uptimeSec = u.toInt();
          }
        } catch (_) {}
        setState(() {
          _api = ApiPingState.ok(
            latencyMs: sw.elapsedMilliseconds,
            uptimeSeconds: uptimeSec,
          );
        });
      } else {
        setState(() {
          _api = ApiPingState.fail(
            'HTTP ${res.statusCode}',
            sw.elapsedMilliseconds,
          );
        });
      }
    } catch (e) {
      sw.stop();
      if (!mounted) return;
      setState(() {
        _api = ApiPingState.fail('$e', sw.elapsedMilliseconds);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.opsHealthTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<IotDeviceRow>>(
              stream: widget.iotDevicesRepository.watchDevices(),
              builder: (context, snap) {
                final devices = snap.data ?? const <IotDeviceRow>[];
                final now = DateTime.now();
                var stale = 0;
                for (final d in devices) {
                  final seen = d.lastSeenAt;
                  if (seen == null || now.difference(seen) > _staleAfter) {
                    stale++;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row(
                      context,
                      label: l10n.opsHealthApi,
                      value: _api.label(l10n),
                      valueColor: _api.color,
                      trailing: _api.latencyLabel,
                    ),
                    if (_api.uptimeLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _api.uptimeLabel!,
                          style: TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const Divider(height: 20),
                    _row(
                      context,
                      label: l10n.opsHealthSensors,
                      value: l10n.opsHealthSensorSummary(devices.length, stale),
                      valueColor:
                          stale > 0 ? AdminColors.warning : AdminColors.primary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.opsHealthStaleHint,
                      style: TextStyle(
                        color: AdminColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
    String? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: AdminColors.textMuted, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(color: AdminColors.textMuted, fontSize: 12),
          ),
      ],
    );
  }
}

/// Last API probe result for the operations strip.
class ApiPingState {
  const ApiPingState._({
    required this.kind,
    this.detail,
    this.latencyMs,
    this.uptimeSeconds,
  });

  const ApiPingState.unknown()
      : this._(kind: PingKind.unknown, detail: null, latencyMs: null);

  const ApiPingState.notConfigured()
      : this._(kind: PingKind.notConfigured, detail: null, latencyMs: null);

  ApiPingState.ok({required int latencyMs, int? uptimeSeconds})
      : this._(
          kind: PingKind.ok,
          detail: null,
          latencyMs: latencyMs,
          uptimeSeconds: uptimeSeconds,
        );

  ApiPingState.fail(String message, int latencyMs)
      : this._(kind: PingKind.fail, detail: message, latencyMs: latencyMs);

  final PingKind kind;
  final String? detail;
  final int? latencyMs;
  final int? uptimeSeconds;

  String label(AppLocalizations l10n) {
    switch (kind) {
      case PingKind.unknown:
        return l10n.opsHealthApiChecking;
      case PingKind.notConfigured:
        return l10n.opsHealthApiNotConfigured;
      case PingKind.ok:
        return l10n.opsHealthApiOk;
      case PingKind.fail:
        return l10n.opsHealthApiFail(detail ?? '');
    }
  }

  Color get color {
    switch (kind) {
      case PingKind.ok:
        return AdminColors.primary;
      case PingKind.fail:
        return AdminColors.danger;
      case PingKind.notConfigured:
      case PingKind.unknown:
        return AdminColors.textMuted;
    }
  }

  String? get latencyLabel {
    if (latencyMs == null) return null;
    return '${latencyMs}ms';
  }

  String? get uptimeLabel {
    if (uptimeSeconds == null) return null;
    final s = uptimeSeconds!;
    if (s < 60) return 'API process uptime: ${s}s';
    if (s < 3600) return 'API process uptime: ${s ~/ 60}m';
    return 'API process uptime: ${s ~/ 3600}h ${(s % 3600) ~/ 60}m';
  }
}

enum PingKind { unknown, notConfigured, ok, fail }
