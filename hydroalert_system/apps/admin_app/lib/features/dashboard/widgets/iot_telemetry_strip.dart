import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../iot_devices/data/iot_devices_repository.dart';
import '../telemetry/iot_telemetry.dart';

/// Live telemetry cards: one per [IotDeviceRow], wrapping grid; loads via [watchDevices].
class IotTelemetryStrip extends StatelessWidget {
  const IotTelemetryStrip({super.key, required this.repository});

  final IotDevicesRepository repository;

  static const _cardWidth = 288.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return StreamBuilder<List<IotDeviceRow>>(
      stream: repository.watchDevices(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.telemetryLoadError('${snapshot.error}'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final devices = sortedDevicesForTelemetry(snapshot.data ?? []);
        if (devices.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              l10n.telemetryEmpty,
              style: const TextStyle(color: AdminColors.textMuted),
            ),
          );
        }

        final now = DateTime.now();
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < devices.length; i++)
              SizedBox(
                width: _cardWidth,
                child: _IotTelemetryCard(
                  device: devices[i],
                  stationNumber: i + 1,
                  now: now,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _IotTelemetryCard extends StatelessWidget {
  const _IotTelemetryCard({
    required this.device,
    required this.stationNumber,
    required this.now,
  });

  final IotDeviceRow device;
  final int stationNumber;
  final DateTime now;

  Color _stripeColor(TelemetryDepthSeverity? severity) {
    if (severity == null) return AdminColors.textMuted;
    switch (severity) {
      case TelemetryDepthSeverity.normal:
        return AdminColors.primary;
      case TelemetryDepthSeverity.advisory:
        return AdminColors.warning;
      case TelemetryDepthSeverity.alertBand:
        return const Color(0xFFF97316);
      case TelemetryDepthSeverity.critical:
        return AdminColors.danger;
    }
  }

  String _severityLabel(AppLocalizations l10n, TelemetryDepthSeverity? s) {
    if (s == null) return '—';
    switch (s) {
      case TelemetryDepthSeverity.normal:
        return l10n.telemetrySeverityNormal;
      case TelemetryDepthSeverity.advisory:
        return l10n.telemetrySeverityAdvisory;
      case TelemetryDepthSeverity.alertBand:
        return l10n.telemetrySeverityAlert;
      case TelemetryDepthSeverity.critical:
        return l10n.telemetrySeverityCritical;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final depthM = maxDepthMetersFromCm(device.waterLevelCm);
    final severity = severityForDepthMeters(depthM);
    final offline = isTelemetryStale(device.lastSeenAt, now);
    final hasReading = depthM != null;
    final stripe = _stripeColor(hasReading ? severity : null);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: stripe,
                boxShadow: [
                  BoxShadow(
                    color: stripe.withValues(alpha: 0.45),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const SizedBox(width: 3),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.telemetryStationTitle('$stationNumber', device.name),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AdminColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.end,
                          children: [
                            if (offline)
                              _StatusChip(
                                label: l10n.telemetryBadgeOffline,
                                foreground: AdminColors.danger,
                              ),
                            if (!device.isActive)
                              _StatusChip(
                                label: l10n.telemetryBadgeInactive,
                                foreground: AdminColors.warning,
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.telemetryWaterLevelLabel,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: AdminColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (hasReading) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            depthM.toStringAsFixed(2),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              l10n.telemetryMetersUnit,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AdminColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        '—',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textMuted,
                        ),
                      ),
                      Text(
                        l10n.telemetryNoReading,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AdminColors.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _ThresholdBarRow(
                      label: l10n.telemetryBarAdvisory,
                      thresholdM: kTelemetryAdvisoryM,
                      depthM: depthM ?? 0,
                      fillColor: AdminColors.primary,
                      dimmed: !hasReading,
                    ),
                    const SizedBox(height: 6),
                    _ThresholdBarRow(
                      label: l10n.telemetryBarAlert,
                      thresholdM: kTelemetryAlertM,
                      depthM: depthM ?? 0,
                      fillColor: AdminColors.warning,
                      dimmed: !hasReading,
                    ),
                    const SizedBox(height: 6),
                    _ThresholdBarRow(
                      label: l10n.telemetryBarCritical,
                      thresholdM: kTelemetryCriticalM,
                      depthM: depthM ?? 0,
                      fillColor: AdminColors.danger,
                      dimmed: !hasReading,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _severityLabel(l10n, hasReading ? severity : null),
                      style: GoogleFonts.inter(
                        color:
                            hasReading && severity != null ? stripe : AdminColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (offline)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.telemetryOfflineHint,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AdminColors.textMuted,
                          ),
                        ),
                      ),
                    if (device.zone.trim().isNotEmpty &&
                        device.zone.trim() != '—') ...[
                      const SizedBox(height: 4),
                      Text(
                        device.zone,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AdminColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.foreground});

  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: foreground.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: foreground,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ThresholdBarRow extends StatelessWidget {
  const _ThresholdBarRow({
    required this.label,
    required this.thresholdM,
    required this.depthM,
    required this.fillColor,
    required this.dimmed,
  });

  final String label;
  final double thresholdM;
  final double depthM;
  final Color fillColor;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final ratio = dimmed ? 0.0 : barFillRatio(depthM, thresholdM);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AdminColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${thresholdM.toStringAsFixed(1)} m',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: AdminColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        LayoutBuilder(
          builder: (context, constraints) {
            final trackW = constraints.maxWidth;
            final fillW = trackW * ratio;
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Container(
                    height: 5,
                    width: trackW,
                    color: AdminColors.surfaceAlt,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 5,
                      width: fillW,
                      decoration: BoxDecoration(
                        color: fillColor.withValues(alpha: dimmed ? 0.25 : 1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
