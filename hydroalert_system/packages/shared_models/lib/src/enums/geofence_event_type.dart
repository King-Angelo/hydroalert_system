enum GeofenceEventType { enter, exit, dwell }

GeofenceEventType geofenceEventTypeFromJson(String value) {
  switch (value.trim().toLowerCase()) {
    case 'enter':
    case 'entered':
      return GeofenceEventType.enter;
    case 'exit':
    case 'exited':
      return GeofenceEventType.exit;
    case 'dwell':
    case 'stay':
    case 'inside':
      return GeofenceEventType.dwell;
    default:
      throw ArgumentError.value(
        value,
        'value',
        'Unsupported GeofenceEventType value',
      );
  }
}

String geofenceEventTypeToJson(GeofenceEventType type) => type.name;

extension GeofenceEventTypeX on GeofenceEventType {
  String get label => switch (this) {
    GeofenceEventType.enter => 'Enter',
    GeofenceEventType.exit => 'Exit',
    GeofenceEventType.dwell => 'Dwell',
  };
}
