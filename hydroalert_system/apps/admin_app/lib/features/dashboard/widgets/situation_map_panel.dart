import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/config/maps_config.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../iot_devices/data/iot_devices_repository.dart';
import 'mock_map_panel.dart';

/// Situation map: Google Maps when [MapsConfig.isConfigured] and the platform
/// supports `google_maps_flutter`; otherwise [MockMapPanel].
///
/// On **web**, `google.maps` can appear slightly after the first frame (or after
/// the script in `index.html` finishes). This widget briefly polls so we do not
/// stick on the static mock when the JS API is only milliseconds late.
class SituationMapPanel extends StatefulWidget {
  const SituationMapPanel({
    super.key,
    required this.iotDevicesRepository,
    this.mockAssetPath = 'assets/images/mock_map.png',
  });

  final IotDevicesRepository iotDevicesRepository;
  final String mockAssetPath;

  static bool platformSupportsMapsSdk() {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

  @override
  State<SituationMapPanel> createState() => _SituationMapPanelState();
}

class _SituationMapPanelState extends State<SituationMapPanel> {
  static const _webPollAttempts = 80;
  static const _webPollDelay = Duration(milliseconds: 100);

  bool _webMapsPollDone = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb &&
        SituationMapPanel.platformSupportsMapsSdk() &&
        !MapsConfig.isConfigured) {
      _pollWebMapsReady();
    } else {
      _webMapsPollDone = true;
    }
  }

  Future<void> _pollWebMapsReady() async {
    for (var i = 0; i < _webPollAttempts && mounted; i++) {
      if (MapsConfig.isConfigured) {
        setState(() {});
        return;
      }
      await Future<void>.delayed(_webPollDelay);
    }
    if (mounted) {
      setState(() => _webMapsPollDone = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SituationMapPanel.platformSupportsMapsSdk()) {
      return MockMapPanel(assetPath: widget.mockAssetPath);
    }

    if (kIsWeb && !_webMapsPollDone && !MapsConfig.isConfigured) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.situationMapLive,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!MapsConfig.isConfigured) {
      return MockMapPanel(assetPath: widget.mockAssetPath);
    }
    return _LiveSituationMap(
      iotDevicesRepository: widget.iotDevicesRepository,
    );
  }
}

class _LiveSituationMap extends StatefulWidget {
  const _LiveSituationMap({required this.iotDevicesRepository});

  final IotDevicesRepository iotDevicesRepository;

  @override
  State<_LiveSituationMap> createState() => _LiveSituationMapState();
}

class _LiveSituationMapState extends State<_LiveSituationMap> {
  GoogleMapController? _controller;
  StreamSubscription<List<IotDeviceRow>>? _sub;
  List<IotDeviceRow> _devices = const [];
  Object? _streamError;
  int? _lastFitToken;

  static const _defaultCenter = LatLng(14.5995, 120.9842);

  int _fitTokenFor(List<IotDeviceRow> devices) {
    final geo = devices.where((d) => d.hasMapCoordinates).toList();
    return Object.hashAll(
      geo.map((d) => Object.hash(d.deviceId, d.latitude, d.longitude)),
    );
  }

  @override
  void initState() {
    super.initState();
    _sub = widget.iotDevicesRepository.watchDevices().listen(
      (devices) {
        if (!mounted) return;
        setState(() {
          _devices = devices;
          _streamError = null;
        });
        _scheduleFitIfNeeded(devices);
      },
      onError: (Object e, StackTrace _) {
        if (!mounted) return;
        setState(() {
          _streamError = e;
        });
      },
    );
  }

  void _scheduleFitIfNeeded(List<IotDeviceRow> devices) {
    final token = _fitTokenFor(devices);
    if (token == _lastFitToken) return;
    _lastFitToken = token;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fitToDevices(devices);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _lastFitToken = null;
    _scheduleFitIfNeeded(_devices);
  }

  Future<void> _fitToDevices(List<IotDeviceRow> devices) async {
    final c = _controller;
    if (c == null || !mounted) return;

    final geo = devices.where((d) => d.hasMapCoordinates).toList();
    if (geo.isEmpty) {
      await c.moveCamera(CameraUpdate.newLatLngZoom(_defaultCenter, 11));
      return;
    }
    if (geo.length == 1) {
      final d = geo.first;
      await c.moveCamera(
        CameraUpdate.newLatLngZoom(LatLng(d.latitude!, d.longitude!), 14),
      );
      return;
    }

    var minLat = geo.first.latitude!;
    var maxLat = geo.first.latitude!;
    var minLng = geo.first.longitude!;
    var maxLng = geo.first.longitude!;
    for (final d in geo) {
      minLat = math.min(minLat, d.latitude!);
      maxLat = math.max(maxLat, d.latitude!);
      minLng = math.min(minLng, d.longitude!);
      maxLng = math.max(maxLng, d.longitude!);
    }

    if (minLat == maxLat && minLng == maxLng) {
      await c.moveCamera(CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 14));
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    try {
      await c.moveCamera(CameraUpdate.newLatLngBounds(bounds, 64));
    } catch (_) {
      await c.moveCamera(CameraUpdate.newLatLngZoom(_defaultCenter, 11));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final err = _streamError;
    if (err != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.situationMapLive,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l10n.situationMapLoadError('$err'),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final geo = _devices.where((d) => d.hasMapCoordinates).toList();
    final markers = <Marker>{};
    for (final d in geo) {
      markers.add(
        Marker(
          markerId: MarkerId(d.deviceId),
          position: LatLng(d.latitude!, d.longitude!),
          infoWindow: InfoWindow(
            title: d.name,
            snippet: d.zone,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.situationMapLive,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: _defaultCenter,
                        zoom: 11,
                      ),
                      markers: markers,
                      onMapCreated: _onMapCreated,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                    ),
                    if (geo.isEmpty)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Material(
                          color: AdminColors.background.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Text(
                              l10n.situationMapNoGeo,
                              style: const TextStyle(fontSize: 12),
                            ),
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
