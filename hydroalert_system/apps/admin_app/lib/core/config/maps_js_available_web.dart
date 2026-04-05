import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// True when the Maps JS API from `web/index.html` finished loading (`google.maps`).
///
/// Uses [globalContext] instead of `package:web` [Window] so behavior matches
/// `globalThis` in the browser and works across dart2js / dart2wasm web.
bool isGoogleMapsScriptLoaded() {
  try {
    final g = globalContext;
    if (!g.has('google')) return false;
    final google = g['google'];
    if (google == null) return false;
    final ns = google as JSObject;
    return ns.has('maps');
  } catch (_) {
    return false;
  }
}
