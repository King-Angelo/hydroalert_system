/// Logical environment label for builds (does **not** switch Firebase project by itself).
///
/// Set at compile time:
/// `--dart-define=HYDRO_ENV=dev` | `staging` | `production`
enum HydroEnvironment {
  dev,
  staging,
  production,
}

abstract final class RuntimeEnvironment {
  static const String _raw = String.fromEnvironment(
    'HYDRO_ENV',
    defaultValue: 'dev',
  );

  static HydroEnvironment get current {
    switch (_raw.toLowerCase().trim()) {
      case 'staging':
        return HydroEnvironment.staging;
      case 'prod':
      case 'production':
        return HydroEnvironment.production;
      default:
        return HydroEnvironment.dev;
    }
  }

  static String get label => switch (current) {
        HydroEnvironment.dev => 'dev',
        HydroEnvironment.staging => 'staging',
        HydroEnvironment.production => 'production',
      };
}
