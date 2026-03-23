import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/iot_devices_repository.dart';

/// Read-only live view of [IoT_Devices] for admins.
class IotDevicesPage extends StatelessWidget {
  const IotDevicesPage({super.key, required this.repository});

  final IotDevicesRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return StreamBuilder<List<IotDeviceRow>>(
      stream: repository.watchDevices(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: SelectableText(
              '${l10n.iotDevicesError}\n${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snapshot.data!;
        if (rows.isEmpty) {
          return Center(child: Text(l10n.iotDevicesEmpty));
        }

        rows.sort((a, b) {
          final ta = a.lastSeenAt;
          final tb = b.lastSeenAt;
          if (ta == null && tb == null) return a.deviceId.compareTo(b.deviceId);
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final d = rows[i];
            final levels = d.waterLevelCm;
            final levelStr = levels == null
                ? '—'
                : levels.map((v) => v.toStringAsFixed(1)).join(' / ');
            final seen = d.lastSeenAt == null
                ? '—'
                : '${d.lastSeenAt!.toLocal()}';

            return ListTile(
              title: Text(
                d.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${l10n.iotDevicesId}: ${d.deviceId}\n'
                '${l10n.iotDevicesZone}: ${d.zone} · '
                '${l10n.iotDevicesFirmware}: ${d.firmwareVersion ?? "—"}\n'
                '${l10n.iotDevicesLastSeen}: $seen',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    d.isActive ? l10n.iotDevicesActive : l10n.iotDevicesInactive,
                    style: TextStyle(
                      color:
                          d.isActive ? AdminColors.primary : AdminColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.iotDevicesWaterCm}\n$levelStr',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
