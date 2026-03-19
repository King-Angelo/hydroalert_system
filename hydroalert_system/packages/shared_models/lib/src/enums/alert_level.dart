enum AlertLevel { normal, advisory, watch, warning }

AlertLevel alertLevelFromJson(String value) {
  switch (value.trim().toLowerCase()) {
    case 'normal':
    case 'green':
      return AlertLevel.normal;
    case 'advisory':
    case 'alert':
    case 'yellow':
      return AlertLevel.advisory;
    case 'watch':
    case 'orange':
      return AlertLevel.watch;
    case 'warning':
    case 'critical':
    case 'red':
      return AlertLevel.warning;
    default:
      throw ArgumentError.value(value, 'value', 'Unsupported AlertLevel value');
  }
}

String alertLevelToJson(AlertLevel level) => level.name;

AlertLevel alertLevelFromWaterLevelMeters(double meters) {
  if (meters <= 3.5) return AlertLevel.normal;
  if (meters < 4.5) return AlertLevel.advisory;
  if (meters < 6.0) return AlertLevel.watch;
  return AlertLevel.warning;
}

extension AlertLevelX on AlertLevel {
  String get label => switch (this) {
    AlertLevel.normal => 'Normal',
    AlertLevel.advisory => 'Advisory',
    AlertLevel.watch => 'Watch',
    AlertLevel.warning => 'Warning',
  };

  int get priority => switch (this) {
    AlertLevel.normal => 0,
    AlertLevel.advisory => 1,
    AlertLevel.watch => 2,
    AlertLevel.warning => 3,
  };
}
