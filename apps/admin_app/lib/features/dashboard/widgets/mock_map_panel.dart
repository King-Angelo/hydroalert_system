import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';

class MockMapPanel extends StatelessWidget {
  const MockMapPanel({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.situationMapStaticMock, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const _FallbackMap(),
                    ),
                    const IgnorePointer(child: CustomPaint(painter: _GridOverlayPainter())),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AdminColors.border),
                        ),
                        child: Text(
                          l10n.staticMockMapBadge,
                          style: TextStyle(fontSize: 11, letterSpacing: 1.1),
                        ),
                      ),
                    ),
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

class _FallbackMap extends StatelessWidget {
  const _FallbackMap();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      color: const Color(0xFF0D2230),
      child: Center(
        child: Text(l10n.addMockMapAsset),
      ),
    );
  }
}

class _GridOverlayPainter extends CustomPainter {
  const _GridOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const step = 28.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}