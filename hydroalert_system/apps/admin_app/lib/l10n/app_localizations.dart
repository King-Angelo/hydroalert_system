import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('fil'),
  ];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(value != null, 'AppLocalizations not found in widget tree.');
    return value!;
  }

  String _t(String key) {
    final code = locale.languageCode == 'fil' ? 'fil' : 'en';
    return _strings[code]?[key] ?? _strings['en']![key]!;
  }

  String get appTitle => _t('appTitle');
  String get appWordmark => _t('appWordmark');
  String get languageLabel => _t('languageLabel');
  String get languageEnglish => _t('languageEnglish');
  String get languageFilipino => _t('languageFilipino');
  String get loginTitle => _t('loginTitle');
  String get emailLabel => _t('emailLabel');
  String get emailHint => _t('emailHint');
  String get passwordLabel => _t('passwordLabel');
  String get rememberMe => _t('rememberMe');
  String get forgotPassword => _t('forgotPassword');
  String get signIn => _t('signIn');
  String get signInWithGoogle => _t('signInWithGoogle');
  String get loginDividerOr => _t('loginDividerOr');
  String get authGoogleUnavailable =>
      _t('authGoogleUnavailable');
  String get authGoogleCancelled => _t('authGoogleCancelled');
  String get signOut => _t('signOut');
  String get emailRequired => _t('emailRequired');
  String get emailInvalid => _t('emailInvalid');
  String get passwordRequired => _t('passwordRequired');
  String get mockSignInFailed => _t('mockSignInFailed');
  String get authSignInFailed => _t('authSignInFailed');
  String get authAdminRequired => _t('authAdminRequired');
  String get passwordResetEmailSent => _t('passwordResetEmailSent');
  String get passwordResetFailed => _t('passwordResetFailed');
  String get navDashboard => _t('navDashboard');
  String get navIncidentVerification => _t('navIncidentVerification');
  String get navUserManagement => _t('navUserManagement');
  String get navSystemLogs => _t('navSystemLogs');
  String get navShelterLogistics => _t('navShelterLogistics');
  String get navIoTDevices => _t('navIoTDevices');
  String get iotDevicesEmpty => _t('iotDevicesEmpty');
  String get iotDevicesError => _t('iotDevicesError');
  String get iotDevicesId => _t('iotDevicesId');
  String get iotDevicesZone => _t('iotDevicesZone');
  String get iotDevicesFirmware => _t('iotDevicesFirmware');
  String get iotDevicesLastSeen => _t('iotDevicesLastSeen');
  String get iotDevicesActive => _t('iotDevicesActive');
  String get iotDevicesInactive => _t('iotDevicesInactive');
  String get iotDevicesWaterCm => _t('iotDevicesWaterCm');
  String get placeholderSuffix => _t('placeholderSuffix');
  String get situationPane => _t('situationPane');
  String telemetryStationTitle(String stationNumber, String name) =>
      _t('telemetryStationTitle')
          .replaceAll('{n}', stationNumber)
          .replaceAll('{name}', name);
  String get telemetryEmpty => _t('telemetryEmpty');
  String telemetryLoadError(String details) =>
      '${_t('telemetryLoadErrorPrefix')}$details';
  String get telemetryNoReading => _t('telemetryNoReading');
  String get telemetryMetersUnit => _t('telemetryMetersUnit');
  String get telemetryWaterLevelLabel => _t('telemetryWaterLevelLabel');
  String get telemetryBadgeOffline => _t('telemetryBadgeOffline');
  String get telemetryBadgeInactive => _t('telemetryBadgeInactive');
  String get telemetrySeverityNormal => _t('telemetrySeverityNormal');
  String get telemetrySeverityAdvisory => _t('telemetrySeverityAdvisory');
  String get telemetrySeverityAlert => _t('telemetrySeverityAlert');
  String get telemetrySeverityCritical => _t('telemetrySeverityCritical');
  String get telemetryBarAdvisory => _t('telemetryBarAdvisory');
  String get telemetryBarAlert => _t('telemetryBarAlert');
  String get telemetryBarCritical => _t('telemetryBarCritical');
  String get telemetryOfflineHint => _t('telemetryOfflineHint');
  String get activityFeed => _t('activityFeed');
  String get activityFeedEmpty => _t('activityFeedEmpty');
  String activityFeedLoadError(String details) =>
      '${_t('activityFeedLoadErrorPrefix')}$details';
  String get actionQueue => _t('actionQueue');
  String get actionQueuePlaceholder => _t('actionQueuePlaceholder');
  String get validate => _t('validate');
  String get reject => _t('reject');
  String get situationMapStaticMock => _t('situationMapStaticMock');
  String get situationMapLive => _t('situationMapLive');
  String get situationMapNoGeo => _t('situationMapNoGeo');
  String situationMapLoadError(String details) =>
      '${_t('situationMapLoadErrorPrefix')}$details';
  String get staticMockMapBadge => _t('staticMockMapBadge');
  String get addMockMapAsset => _t('addMockMapAsset');
  String get statusPending => _t('statusPending');
  String get statusValidated => _t('statusValidated');
  String get statusApproved => _t('statusApproved');
  String get statusRejected => _t('statusRejected');
  String get statusCritical => _t('statusCritical');
  String get statusElevated => _t('statusElevated');
  String get statusHeavy => _t('statusHeavy');
  String get manualAlertTitle => _t('manualAlertTitle');
  String get manualAlertSubtitle => _t('manualAlertSubtitle');
  String get manualAlertApiDisabled => _t('manualAlertApiDisabled');
  String get manualAlertZoneLabel => _t('manualAlertZoneLabel');
  String get manualAlertZoneHint => _t('manualAlertZoneHint');
  String get manualAlertSeverityLabel => _t('manualAlertSeverityLabel');
  String get manualAlertMessageLabel => _t('manualAlertMessageLabel');
  String get manualAlertSend => _t('manualAlertSend');
  String get manualAlertSent => _t('manualAlertSent');
  String get manualAlertFillFields => _t('manualAlertFillFields');
  String manualAlertFailed(String details) =>
      '${_t('manualAlertFailedPrefix')}$details';

  String get opsHealthTitle => _t('opsHealthTitle');
  String get opsHealthApi => _t('opsHealthApi');
  String get opsHealthApiChecking => _t('opsHealthApiChecking');
  String get opsHealthApiNotConfigured => _t('opsHealthApiNotConfigured');
  String get opsHealthApiOk => _t('opsHealthApiOk');
  String opsHealthApiFail(String details) =>
      '${_t('opsHealthApiFailPrefix')}$details';
  String get opsHealthSensors => _t('opsHealthSensors');
  String opsHealthSensorSummary(int total, int stale) =>
      _t('opsHealthSensorSummary')
          .replaceAll('{total}', '$total')
          .replaceAll('{stale}', '$stale');
  String get opsHealthStaleHint => _t('opsHealthStaleHint');

  // ——— Admin hardening (P1): shared UI ———
  String get commonCancel => _t('commonCancel');
  String get commonConfirm => _t('commonConfirm');
  String get commonSave => _t('commonSave');
  String get commonApply => _t('commonApply');
  String get commonClear => _t('commonClear');
  String get commonPrevious => _t('commonPrevious');
  String get commonNext => _t('commonNext');
  String get sessionTerminatedMessage => _t('sessionTerminatedMessage');
  String get authWrongPassword => _t('authWrongPassword');
  String get authUserNotFound => _t('authUserNotFound');
  String get authInvalidCredential => _t('authInvalidCredential');
  String get authTooManyRequests => _t('authTooManyRequests');
  String get authNetworkFailed => _t('authNetworkFailed');
  String get validationZoneRequired => _t('validationZoneRequired');
  String get validationMessageRequired => _t('validationMessageRequired');
  String get validationZoneTooLong => _t('validationZoneTooLong');
  String get validationMessageTooLong => _t('validationMessageTooLong');
  String get validationIntegerNonNegative => _t('validationIntegerNonNegative');
  String get validationRejectionReasonRequired =>
      _t('validationRejectionReasonRequired');
  String get reviewNotesLabel => _t('reviewNotesLabel');
  String get reviewNotesHintValidate => _t('reviewNotesHintValidate');
  String get reviewNotesHintReject => _t('reviewNotesHintReject');
  String reportReviewValidated(String id) =>
      _t('reportReviewValidated').replaceAll('{id}', id);
  String reportReviewRejected(String id) =>
      _t('reportReviewRejected').replaceAll('{id}', id);
  String get reportReviewFailed => _t('reportReviewFailed');
  String errorWithDetails(String details) =>
      '${_t('errorWithDetailsPrefix')}$details';
  String get actionQueueLoadError => _t('actionQueueLoadError');
  String get actionQueueNoPending => _t('actionQueueNoPending');
  String timeAgoMinutes(int n) =>
      _t('timeAgoMinutes').replaceAll('{n}', '$n');
  String timeAgoHours(int n) => _t('timeAgoHours').replaceAll('{n}', '$n');
  String timeAgoDays(int n) => _t('timeAgoDays').replaceAll('{n}', '$n');
  String get timeAgoJustNow => _t('timeAgoJustNow');
  String get reportsFilterAll => _t('reportsFilterAll');
  String get userFilterAll => _t('userFilterAll');
  String get userFilterAdmin => _t('userFilterAdmin');
  String get userFilterOfficial => _t('userFilterOfficial');
  String get userFilterResident => _t('userFilterResident');
  String get userFilterInactive => _t('userFilterInactive');
  String userRoleUpdated(String id) =>
      _t('userRoleUpdated').replaceAll('{id}', id);
  String get userRoleUpdateFailed => _t('userRoleUpdateFailed');
  String userActivated(String id) =>
      _t('userActivated').replaceAll('{id}', id);
  String userDeactivated(String id) =>
      _t('userDeactivated').replaceAll('{id}', id);
  String get userStateUpdateFailed => _t('userStateUpdateFailed');
  String get userSoftDeleteTitle => _t('userSoftDeleteTitle');
  String userSoftDeleteConfirm(String id) =>
      _t('userSoftDeleteConfirm').replaceAll('{id}', id);
  String userSoftDeleted(String id) =>
      _t('userSoftDeleted').replaceAll('{id}', id);
  String get userSoftDeleteFailed => _t('userSoftDeleteFailed');
  String tokensCopied(int n) => _t('tokensCopied').replaceAll('{n}', '$n');
  String get userColumnUserId => _t('userColumnUserId');
  String get userColumnEmail => _t('userColumnEmail');
  String get userColumnUserType => _t('userColumnUserType');
  String get userColumnActive => _t('userColumnActive');
  String get userColumnTokens => _t('userColumnTokens');
  String get locationPreview => _t('locationPreview');
  String get copyTokens => _t('copyTokens');
  String get roleChangeHint => _t('roleChangeHint');
  String get paginationPage => _t('paginationPage');
  String paginationPageOf(int current, int total) =>
      _t('paginationPageOf')
          .replaceAll('{current}', '$current')
          .replaceAll('{total}', '$total');
  String get shelterOpen => _t('shelterOpen');
  String get shelterClosed => _t('shelterClosed');
  String shelterStatusUpdated(String id, String status) =>
      _t('shelterStatusUpdated')
          .replaceAll('{id}', id)
          .replaceAll('{status}', status);
  String shelterCapacityUpdated(String id) =>
      _t('shelterCapacityUpdated').replaceAll('{id}', id);
  String shelterOccupancyUpdated(String id) =>
      _t('shelterOccupancyUpdated').replaceAll('{id}', id);
  String get shelterStatusUpdateFailed => _t('shelterStatusUpdateFailed');
  String get shelterCapacityUpdateFailed => _t('shelterCapacityUpdateFailed');
  String get shelterOccupancyUpdateFailed => _t('shelterOccupancyUpdateFailed');
  String get shelterSoftDeleteTitle => _t('shelterSoftDeleteTitle');
  String shelterSoftDeleteConfirm(String id) =>
      _t('shelterSoftDeleteConfirm').replaceAll('{id}', id);
  String shelterSoftDeleted(String id) =>
      _t('shelterSoftDeleted').replaceAll('{id}', id);
  String get shelterSoftDeleteFailed => _t('shelterSoftDeleteFailed');
  String get shelterLoadError => _t('shelterLoadError');
  String get shelterFilterAll => _t('shelterFilterAll');
  String get shelterOccupancyFilterAll => _t('shelterOccupancyFilterAll');
  String get shelterOccupancyFilterAvailable =>
      _t('shelterOccupancyFilterAvailable');
  String get shelterOccupancyFilterNearCap =>
      _t('shelterOccupancyFilterNearCap');
  String get shelterOccupancyFilterFull => _t('shelterOccupancyFilterFull');
  String get shelterUpdateCapacityTitle => _t('shelterUpdateCapacityTitle');
  String get shelterUpdateOccupancyTitle => _t('shelterUpdateOccupancyTitle');
  String get shelterLabelCapacity => _t('shelterLabelCapacity');
  String get shelterLabelOccupancy => _t('shelterLabelOccupancy');
  String get shelterColumnShelterId => _t('shelterColumnShelterId');
  String get shelterColumnName => _t('shelterColumnName');
  String get shelterColumnZone => _t('shelterColumnZone');
  String get shelterColumnStatus => _t('shelterColumnStatus');
  String get shelterColumnOccupancy => _t('shelterColumnOccupancy');
  String get shelterColumnContact => _t('shelterColumnContact');
  String get shelterActionUpdateCapacity => _t('shelterActionUpdateCapacity');
  String get shelterActionUpdateOccupancy => _t('shelterActionUpdateOccupancy');
  String get shelterActionSoftDelete => _t('shelterActionSoftDelete');
  String get systemLogsColumnTimestamp => _t('systemLogsColumnTimestamp');
  String get systemLogsColumnType => _t('systemLogsColumnType');
  String get systemLogsColumnAction => _t('systemLogsColumnAction');
  String get systemLogsColumnAdminId => _t('systemLogsColumnAdminId');
  String get systemLogsColumnTargetId => _t('systemLogsColumnTargetId');
  String get reportsColumnReportId => _t('reportsColumnReportId');
  String get reportsColumnCreatedAt => _t('reportsColumnCreatedAt');
  String get reportsColumnZone => _t('reportsColumnZone');
  String get reportsColumnResidentId => _t('reportsColumnResidentId');
  String get reportsColumnStatus => _t('reportsColumnStatus');
  String get photoNoUrl => _t('photoNoUrl');
  String get photoLoadFailed => _t('photoLoadFailed');
  String get semanticLoginEmail => _t('semanticLoginEmail');
  String get semanticLoginPassword => _t('semanticLoginPassword');
  String get semanticRememberMe => _t('semanticRememberMe');

  String reportsNoneForFilter(String filter) =>
      _t('reportsNoneForFilter').replaceAll('{filter}', filter);
  String get reportsSelectOne => _t('reportsSelectOne');
  String reportDetailTitle(String id) =>
      _t('reportDetailTitle').replaceAll('{id}', id);
  String get reportsFieldDescription => _t('reportsFieldDescription');
  String get reportsFieldPhoto => _t('reportsFieldPhoto');
  String get reportsFieldReviewer => _t('reportsFieldReviewer');
  String get reportsDecisionLocked => _t('reportsDecisionLocked');
  String get reportsUnableToLoad => _t('reportsUnableToLoad');

  String get userSearchByEmailOrId => _t('userSearchByEmailOrId');
  String get usersUnableToLoad => _t('usersUnableToLoad');
  String get usersEmpty => _t('usersEmpty');
  String get usersSelectOne => _t('usersSelectOne');
  String get userAdminProtected => _t('userAdminProtected');
  String get userActionDeactivate => _t('userActionDeactivate');
  String get userActionActivate => _t('userActionActivate');
  String get userRoleOfficial => _t('userRoleOfficial');
  String get userRoleResident => _t('userRoleResident');
  String get mapNoCoordinates => _t('mapNoCoordinates');
  String mapKeyMissing(String lat, String lng) =>
      _t('mapKeyMissing').replaceAll('{lat}', lat).replaceAll('{lng}', lng);

  String get shelterFilterStatusLabel => _t('shelterFilterStatusLabel');
  String get shelterFilterZoneLabel => _t('shelterFilterZoneLabel');
  String get shelterOccupancyLevelLabel => _t('shelterOccupancyLevelLabel');
  String get shelterSearchByNameOrContact =>
      _t('shelterSearchByNameOrContact');
  String shelterActiveCount(int n) =>
      _t('shelterActiveCount').replaceAll('{n}', '$n');
  String get sheltersEmptyFiltered => _t('sheltersEmptyFiltered');
  String get sheltersSelectOne => _t('sheltersSelectOne');
  String get shelterActionOpen => _t('shelterActionOpen');
  String get shelterActionClose => _t('shelterActionClose');
  String get shelterAuditNotice => _t('shelterAuditNotice');
  String shelterMapLoadFailed(String lat, String lng) =>
      _t('shelterMapLoadFailed')
          .replaceAll('{lat}', lat)
          .replaceAll('{lng}', lng);

  String get systemLogsTypeLabel => _t('systemLogsTypeLabel');
  String get systemLogsDateLast24h => _t('systemLogsDateLast24h');
  String get systemLogsDateLast7d => _t('systemLogsDateLast7d');
  String get systemLogsDateLast30d => _t('systemLogsDateLast30d');
  String get systemLogsDateAllTime => _t('systemLogsDateAllTime');
  String get systemLogsSearchNotes => _t('systemLogsSearchNotes');
  String get systemLogsFilterAction => _t('systemLogsFilterAction');
  String get systemLogsFilterAdminId => _t('systemLogsFilterAdminId');
  String get systemLogsFilterTargetId => _t('systemLogsFilterTargetId');
  String systemLogsMatchingCount(int n) =>
      _t('systemLogsMatchingCount').replaceAll('{n}', '$n');
  String get systemLogsUnableToLoad => _t('systemLogsUnableToLoad');
  String get systemLogsNoMatches => _t('systemLogsNoMatches');
  String get systemLogsLoadingMore => _t('systemLogsLoadingMore');
  String get systemLogsSelectLog => _t('systemLogsSelectLog');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

const _strings = <String, Map<String, String>>{
  'en': {
    'appTitle': 'HydroAlert Admin',
    'appWordmark': 'HYDROALERT',
    'languageLabel': 'Language',
    'languageEnglish': 'English',
    'languageFilipino': 'Filipino',
    'loginTitle': 'HydroAlert Admin Login',
    'emailLabel': 'Email',
    'emailHint': 'admin@hydroalert.local',
    'passwordLabel': 'Password',
    'rememberMe': 'Remember Me',
    'forgotPassword': 'Forgot password?',
    'signIn': 'Sign In',
    'signInWithGoogle': 'Continue with Google',
    'loginDividerOr': 'or',
    'authGoogleUnavailable':
        'Google sign-in is not available in this build.',
    'authGoogleCancelled': 'Google sign-in was cancelled.',
    'signOut': 'Sign out',
    'emailRequired': 'Email is required',
    'emailInvalid': 'Enter a valid email',
    'passwordRequired': 'Password is required',
    'mockSignInFailed': 'Mock sign-in failed. Check your input.',
    'authSignInFailed': 'Sign-in failed. Check credentials and try again.',
    'authAdminRequired': 'This account is not an active admin account.',
    'passwordResetEmailSent': 'Password reset email sent. Check your inbox.',
    'passwordResetFailed': 'Unable to send password reset email.',
    'navDashboard': 'Dashboard',
    'navIncidentVerification': 'Reports',
    'navUserManagement': 'User Management',
    'navSystemLogs': 'System Logs',
    'navShelterLogistics': 'Shelter Logistics',
    'navIoTDevices': 'IoT devices',
    'iotDevicesEmpty': 'No IoT devices in Firestore yet.',
    'iotDevicesError': 'Could not load IoT devices.',
    'iotDevicesId': 'ID',
    'iotDevicesZone': 'Zone',
    'iotDevicesFirmware': 'FW',
    'iotDevicesLastSeen': 'Last seen',
    'iotDevicesActive': 'Active',
    'iotDevicesInactive': 'Inactive',
    'iotDevicesWaterCm': 'Water (cm)\nch0 / ch1 / ch2',
    'placeholderSuffix': 'placeholder',
    'situationPane': 'Situation Pane',
    'telemetryStationTitle': 'Station #{n} · {name}',
    'telemetryEmpty':
        'No IoT stations in Firestore yet. Sensor telemetry will appear here.',
    'telemetryLoadErrorPrefix': 'Could not load telemetry: ',
    'telemetryNoReading': 'No reading yet',
    'telemetryMetersUnit': 'meters',
    'telemetryWaterLevelLabel': 'WATER LEVEL',
    'telemetryBadgeOffline': 'OFFLINE',
    'telemetryBadgeInactive': 'INACTIVE',
    'telemetrySeverityNormal': 'Normal',
    'telemetrySeverityAdvisory': 'Advisory',
    'telemetrySeverityAlert': 'Alert',
    'telemetrySeverityCritical': 'Critical',
    'telemetryBarAdvisory': 'Advisory (3.5 m)',
    'telemetryBarAlert': 'Alert (4.5 m)',
    'telemetryBarCritical': 'Critical (6.0 m)',
    'telemetryOfflineHint': 'No update in the last 10 minutes.',
    'activityFeed': 'Activity Feed',
    'activityFeedEmpty': 'No recent activity in System_Logs.',
    'activityFeedLoadErrorPrefix': 'Could not load activity: ',
    'actionQueue': 'Action Queue',
    'actionQueuePlaceholder': 'Incident verification placeholder panel',
    'validate': 'Validate',
    'reject': 'Reject',
    'situationMapStaticMock': 'Situation Map (Static Mock)',
    'situationMapLive': 'Situation Map',
    'situationMapNoGeo':
        'No devices with map coordinates. Set `location: { lat, lng }` on IoT_Devices (or turn off the Maps API key to use the static mock).',
    'situationMapLoadErrorPrefix': 'Could not load map: ',
    'staticMockMapBadge': 'STATIC MOCK MAP',
    'addMockMapAsset': 'Add assets/images/mock_map.png',
    'statusPending': 'Pending',
    'statusValidated': 'Validated',
    'statusApproved': 'Approved',
    'statusRejected': 'Rejected',
    'statusCritical': 'Critical',
    'statusElevated': 'Elevated',
    'statusHeavy': 'Heavy',
    'manualAlertTitle': 'Zone alert (FCM)',
    'manualAlertSubtitle':
        'Sends push to active users with matching Users.location.zone and device_tokens (no topic subscription).',
    'manualAlertApiDisabled':
        'API URL not set. Run with --dart-define=HYDROADMIN_API_BASE_URL=https://your-api (and use Firebase sign-in, not mock).',
    'manualAlertZoneLabel': 'Target zone',
    'manualAlertZoneHint': 'Must match Users.location.zone exactly',
    'manualAlertSeverityLabel': 'Severity',
    'manualAlertMessageLabel': 'Message',
    'manualAlertSend': 'Send alert',
    'manualAlertSent': 'Alert API call succeeded. Check System logs for push details.',
    'manualAlertFillFields': 'Enter zone and message.',
    'manualAlertFailedPrefix': 'Failed: ',
    'opsHealthTitle': 'Operations & health (P1)',
    'opsHealthApi': 'Backend API',
    'opsHealthApiChecking': 'Checking…',
    'opsHealthApiNotConfigured':
        'Not configured (set HYDROADMIN_API_BASE_URL)',
    'opsHealthApiOk': 'Reachable',
    'opsHealthApiFailPrefix': 'Unreachable: ',
    'opsHealthSensors': 'Sensor health',
    'opsHealthSensorSummary':
        '{total} devices • {stale} stale / no recent data',
    'opsHealthStaleHint':
        'Stale = no last_seen_at within 10 minutes (tune to your telemetry rate).',
    'commonCancel': 'Cancel',
    'commonConfirm': 'Confirm',
    'commonSave': 'Save',
    'commonApply': 'Apply',
    'commonClear': 'Clear',
    'commonPrevious': 'Previous',
    'commonNext': 'Next',
    'sessionTerminatedMessage':
        'Your session ended. Sign in again to continue.',
    'authWrongPassword': 'Incorrect password. Try again.',
    'authUserNotFound': 'No account found for this email.',
    'authInvalidCredential': 'Invalid email or password.',
    'authTooManyRequests': 'Too many attempts. Wait and try again.',
    'authNetworkFailed': 'Network error. Check your connection.',
    'validationZoneRequired': 'Zone is required.',
    'validationMessageRequired': 'Message is required.',
    'validationZoneTooLong': 'Zone is too long.',
    'validationMessageTooLong': 'Message is too long.',
    'validationIntegerNonNegative': 'Enter a valid non-negative integer.',
    'validationRejectionReasonRequired': 'Rejection reason is required.',
    'reviewNotesLabel': 'Review notes',
    'reviewNotesHintValidate': 'Optional validation remarks.',
    'reviewNotesHintReject': 'Reason for rejecting this report.',
    'reportReviewValidated': 'Report {id} validated.',
    'reportReviewRejected': 'Report {id} rejected.',
    'reportReviewFailed': 'Could not update report.',
    'errorWithDetailsPrefix': 'Error: ',
    'actionQueueLoadError': 'Unable to load reports.',
    'actionQueueNoPending': 'No pending reports.',
    'timeAgoJustNow': 'just now',
    'timeAgoMinutes': '{n}m ago',
    'timeAgoHours': '{n}h ago',
    'timeAgoDays': '{n}d ago',
    'reportsFilterAll': 'All',
    'userFilterAll': 'All',
    'userFilterAdmin': 'Admin',
    'userFilterOfficial': 'Official',
    'userFilterResident': 'Resident',
    'userFilterInactive': 'Inactive',
    'userRoleUpdated': 'Role updated for {id}.',
    'userRoleUpdateFailed': 'Failed to update role.',
    'userActivated': 'User {id} activated.',
    'userDeactivated': 'User {id} deactivated.',
    'userStateUpdateFailed': 'Failed to update user state.',
    'userSoftDeleteTitle': 'Soft delete user',
    'userSoftDeleteConfirm':
        'Set {id} inactive and store deleted_at timestamp?',
    'userSoftDeleted': 'User {id} soft deleted.',
    'userSoftDeleteFailed': 'Soft delete failed.',
    'tokensCopied': 'Copied {n} token(s).',
    'userColumnUserId': 'user_id',
    'userColumnEmail': 'email',
    'userColumnUserType': 'user_type',
    'userColumnActive': 'active',
    'userColumnTokens': 'tokens',
    'locationPreview': 'Location preview',
    'copyTokens': 'Copy tokens',
    'roleChangeHint': 'Change role',
    'paginationPage': 'Page',
    'paginationPageOf': 'Page {current} / {total}',
    'shelterOpen': 'Open',
    'shelterClosed': 'Closed',
    'shelterStatusUpdated': 'Shelter {id} marked as {status}.',
    'shelterCapacityUpdated': 'Capacity updated for {id}.',
    'shelterOccupancyUpdated': 'Occupancy updated for {id}.',
    'shelterStatusUpdateFailed': 'Status update failed.',
    'shelterCapacityUpdateFailed': 'Capacity update failed.',
    'shelterOccupancyUpdateFailed': 'Occupancy update failed.',
    'shelterSoftDeleteTitle': 'Soft delete shelter',
    'shelterSoftDeleteConfirm':
        'Set {id} inactive and preserve historical links/logs?',
    'shelterSoftDeleted': 'Shelter {id} soft deleted.',
    'shelterSoftDeleteFailed': 'Soft delete failed.',
    'shelterLoadError': 'Unable to load shelters.',
    'shelterFilterAll': 'All',
    'shelterOccupancyFilterAll': 'All',
    'shelterOccupancyFilterAvailable': 'Available (<80%)',
    'shelterOccupancyFilterNearCap': 'Near cap (80–99%)',
    'shelterOccupancyFilterFull': 'Full (100%)',
    'shelterUpdateCapacityTitle': 'Update capacity',
    'shelterUpdateOccupancyTitle': 'Update occupancy',
    'shelterLabelCapacity': 'capacity',
    'shelterLabelOccupancy': 'current_occupancy',
    'shelterColumnShelterId': 'shelter_id',
    'shelterColumnName': 'name',
    'shelterColumnZone': 'zone',
    'shelterColumnStatus': 'status',
    'shelterColumnOccupancy': 'occupancy',
    'shelterColumnContact': 'contact',
    'shelterActionUpdateCapacity': 'Update capacity',
    'shelterActionUpdateOccupancy': 'Update occupancy',
    'shelterActionSoftDelete': 'Soft delete',
    'systemLogsColumnTimestamp': 'timestamp',
    'systemLogsColumnType': 'type',
    'systemLogsColumnAction': 'action',
    'systemLogsColumnAdminId': 'admin_id',
    'systemLogsColumnTargetId': 'target_id',
    'reportsColumnReportId': 'report_id',
    'reportsColumnCreatedAt': 'created_at',
    'reportsColumnZone': 'zone',
    'reportsColumnResidentId': 'resident_id',
    'reportsColumnStatus': 'status',
    'photoNoUrl': 'No photo URL',
    'photoLoadFailed': 'Unable to load photo',
    'semanticLoginEmail': 'Email address',
    'semanticLoginPassword': 'Password',
    'semanticRememberMe': 'Remember me on this device',
    'reportsNoneForFilter': 'No reports found for {filter}.',
    'reportsSelectOne': 'Select a report to inspect details.',
    'reportDetailTitle': 'Report {id}',
    'reportsFieldDescription': 'Description',
    'reportsFieldPhoto': 'Photo evidence',
    'reportsFieldReviewer': 'Reviewer history',
    'reportsDecisionLocked':
        'Decision already finalized. Reopen is blocked in v1.',
    'reportsUnableToLoad': 'Unable to load reports.',
    'userSearchByEmailOrId': 'Search by email or user_id',
    'usersUnableToLoad': 'Unable to load users.',
    'usersEmpty': 'No users found.',
    'usersSelectOne': 'Select a user to inspect details.',
    'userAdminProtected':
        'Admin accounts are protected from role/state changes.',
    'userActionDeactivate': 'Deactivate',
    'userActionActivate': 'Activate',
    'userRoleOfficial': 'official',
    'userRoleResident': 'resident',
    'mapNoCoordinates': 'No coordinates available',
    'mapKeyMissing': 'Google Maps key missing.\nCoordinates: {lat}, {lng}',
    'shelterFilterStatusLabel': 'Status',
    'shelterFilterZoneLabel': 'Zone',
    'shelterOccupancyLevelLabel': 'Occupancy level',
    'shelterSearchByNameOrContact': 'Search by shelter name or contact',
    'shelterActiveCount': '{n} active shelters',
    'sheltersEmptyFiltered': 'No shelters found for current filters.',
    'sheltersSelectOne': 'Select a shelter to inspect details.',
    'shelterActionOpen': 'Open',
    'shelterActionClose': 'Close',
    'shelterAuditNotice':
        'All changes are logged to System_Logs as immutable audit records.',
    'shelterMapLoadFailed': 'Map failed to load.\nCoordinates: {lat}, {lng}',
    'systemLogsTypeLabel': 'Type',
    'systemLogsDateLast24h': 'Last 24h',
    'systemLogsDateLast7d': 'Last 7d',
    'systemLogsDateLast30d': 'Last 30d',
    'systemLogsDateAllTime': 'All time',
    'systemLogsSearchNotes': 'Search notes/ids',
    'systemLogsFilterAction': 'Filter action',
    'systemLogsFilterAdminId': 'Filter admin_id',
    'systemLogsFilterTargetId': 'Filter target_id',
    'systemLogsMatchingCount': '{n} matching logs',
    'systemLogsUnableToLoad': 'Unable to load system logs.',
    'systemLogsNoMatches': 'No logs found for the current filters.',
    'systemLogsLoadingMore': 'Loading…',
    'systemLogsSelectLog': 'Select a log entry to inspect details.',
  },
  'fil': {
    'appTitle': 'HydroAlert Admin',
    'appWordmark': 'HYDROALERT',
    'languageLabel': 'Wika',
    'languageEnglish': 'Ingles',
    'languageFilipino': 'Filipino',
    'loginTitle': 'Pag-login ng HydroAlert Admin',
    'emailLabel': 'Email',
    'emailHint': 'admin@hydroalert.local',
    'passwordLabel': 'Password',
    'rememberMe': 'Tandaan Ako',
    'forgotPassword': 'Nakalimutan ang password?',
    'signIn': 'Mag-sign In',
    'signInWithGoogle': 'Magpatuloy gamit ang Google',
    'loginDividerOr': 'o',
    'authGoogleUnavailable':
        'Hindi available ang Google sign-in sa build na ito.',
    'authGoogleCancelled': 'Kinansela ang Google sign-in.',
    'signOut': 'Mag-sign out',
    'emailRequired': 'Kailangan ang email',
    'emailInvalid': 'Maglagay ng wastong email',
    'passwordRequired': 'Kailangan ang password',
    'mockSignInFailed': 'Nabigo ang mock sign-in. Suriin ang iyong input.',
    'authSignInFailed': 'Nabigo ang pag-sign in. Suriin ang credentials at subukan muli.',
    'authAdminRequired': 'Ang account na ito ay hindi aktibong admin account.',
    'passwordResetEmailSent':
        'Naipadala na ang email para sa password reset. Tingnan ang inbox.',
    'passwordResetFailed': 'Hindi maipadala ang password reset email.',
    'navDashboard': 'Dashboard',
    'navIncidentVerification': 'Reports',
    'navUserManagement': 'Pamamahala ng User',
    'navSystemLogs': 'System Logs',
    'navShelterLogistics': 'Shelter Logistics',
    'navIoTDevices': 'IoT devices',
    'iotDevicesEmpty': 'Walang IoT device sa Firestore.',
    'iotDevicesError': 'Hindi ma-load ang IoT devices.',
    'iotDevicesId': 'ID',
    'iotDevicesZone': 'Zone',
    'iotDevicesFirmware': 'FW',
    'iotDevicesLastSeen': 'Huling nakita',
    'iotDevicesActive': 'Aktibo',
    'iotDevicesInactive': 'Hindi aktibo',
    'iotDevicesWaterCm': 'Tubig (cm)\nch0 / ch1 / ch2',
    'placeholderSuffix': 'placeholder',
    'situationPane': 'Situation Pane',
    'telemetryStationTitle': 'Himpilan #{n} · {name}',
    'telemetryEmpty':
        'Walang IoT station sa Firestore. Lalabas dito ang telemetry ng sensor.',
    'telemetryLoadErrorPrefix': 'Hindi ma-load ang telemetry: ',
    'telemetryNoReading': 'Walang reading pa',
    'telemetryMetersUnit': 'metro',
    'telemetryWaterLevelLabel': 'LEVEL NG TUBIG',
    'telemetryBadgeOffline': 'OFFLINE',
    'telemetryBadgeInactive': 'HINDI AKTIBO',
    'telemetrySeverityNormal': 'Normal',
    'telemetrySeverityAdvisory': 'Advisory',
    'telemetrySeverityAlert': 'Alert',
    'telemetrySeverityCritical': 'Critical',
    'telemetryBarAdvisory': 'Advisory (3.5 m)',
    'telemetryBarAlert': 'Alert (4.5 m)',
    'telemetryBarCritical': 'Critical (6.0 m)',
    'telemetryOfflineHint': 'Walang update sa nakalipas na 10 minuto.',
    'activityFeed': 'Activity Feed',
    'activityFeedEmpty': 'Walang kamakailang aktibidad sa System_Logs.',
    'activityFeedLoadErrorPrefix': 'Hindi ma-load ang aktibidad: ',
    'actionQueue': 'Action Queue',
    'actionQueuePlaceholder': 'Placeholder panel para sa beripikasyon ng insidente',
    'validate': 'I-validate',
    'reject': 'I-reject',
    'situationMapStaticMock': 'Situation Map (Static Mock)',
    'situationMapLive': 'Situation Map',
    'situationMapNoGeo':
        'Walang device na may map coordinates. Ilagay ang `location: { lat, lng }` sa IoT_Devices (o alisin ang Maps API key para sa static mock).',
    'situationMapLoadErrorPrefix': 'Hindi ma-load ang mapa: ',
    'staticMockMapBadge': 'STATIC MOCK MAP',
    'addMockMapAsset': 'Idagdag ang assets/images/mock_map.png',
    'statusPending': 'Pending',
    'statusValidated': 'Validated',
    'statusApproved': 'Approved',
    'statusRejected': 'Rejected',
    'statusCritical': 'Critical',
    'statusElevated': 'Elevated',
    'statusHeavy': 'Heavy',
    'manualAlertTitle': 'Alerto sa zone (FCM)',
    'manualAlertSubtitle':
        'Magpadala ng push sa mga aktibong user na may tumutugmang Users.location.zone at device_tokens.',
    'manualAlertApiDisabled':
        'Walang API URL. Gumamit ng --dart-define=HYDROADMIN_API_BASE_URL=... (Firebase sign-in, hindi mock).',
    'manualAlertZoneLabel': 'Target zone',
    'manualAlertZoneHint': 'Dapat tumugma sa Users.location.zone',
    'manualAlertSeverityLabel': 'Severity',
    'manualAlertMessageLabel': 'Mensahe',
    'manualAlertSend': 'Ipadala',
    'manualAlertSent': 'OK ang API. Tingnan ang System logs para sa push.',
    'manualAlertFillFields': 'Ilagay ang zone at mensahe.',
    'manualAlertFailedPrefix': 'Nabigo: ',
    'opsHealthTitle': 'Operasyon at kalusugan (P1)',
    'opsHealthApi': 'Backend API',
    'opsHealthApiChecking': 'Sinusuri…',
    'opsHealthApiNotConfigured':
        'Hindi naka-config (HYDROADMIN_API_BASE_URL)',
    'opsHealthApiOk': 'Maaabot',
    'opsHealthApiFailPrefix': 'Hindi maaabot: ',
    'opsHealthSensors': 'Kalusugan ng sensor',
    'opsHealthSensorSummary':
        '{total} device • {stale} walang bagong data / stale',
    'opsHealthStaleHint':
        'Stale = walang last_seen_at sa loob ng 10 minuto.',
    'commonCancel': 'Kanselahin',
    'commonConfirm': 'Kumpirmahin',
    'commonSave': 'I-save',
    'commonApply': 'Ilapat',
    'commonClear': 'I-clear',
    'commonPrevious': 'Nakaraan',
    'commonNext': 'Susunod',
    'sessionTerminatedMessage':
        'Natapos ang session. Mag-sign in muli para magpatuloy.',
    'authWrongPassword': 'Maling password. Subukan muli.',
    'authUserNotFound': 'Walang account sa email na ito.',
    'authInvalidCredential': 'Hindi wastong email o password.',
    'authTooManyRequests': 'Sobrang daming pagsubok. Maghintay at subukan muli.',
    'authNetworkFailed': 'Error sa network. Suriin ang koneksyon.',
    'validationZoneRequired': 'Kailangan ang zone.',
    'validationMessageRequired': 'Kailangan ang mensahe.',
    'validationZoneTooLong': 'Masyadong mahaba ang zone.',
    'validationMessageTooLong': 'Masyadong mahaba ang mensahe.',
    'validationIntegerNonNegative': 'Maglagay ng wastong integer ≥ 0.',
    'validationRejectionReasonRequired': 'Kailangan ang dahilan ng pag-reject.',
    'reviewNotesLabel': 'Mga tala sa review',
    'reviewNotesHintValidate': 'Opsyonal na remarks sa validation.',
    'reviewNotesHintReject': 'Dahilan kung bakit ire-reject ang report.',
    'reportReviewValidated': 'Na-validate ang report {id}.',
    'reportReviewRejected': 'Na-reject ang report {id}.',
    'reportReviewFailed': 'Hindi na-update ang report.',
    'errorWithDetailsPrefix': 'Error: ',
    'actionQueueLoadError': 'Hindi ma-load ang mga report.',
    'actionQueueNoPending': 'Walang pending na report.',
    'timeAgoJustNow': 'ngayon lang',
    'timeAgoMinutes': '{n}m ang nakalipas',
    'timeAgoHours': '{n}h ang nakalipas',
    'timeAgoDays': '{n} araw ang nakalipas',
    'reportsFilterAll': 'Lahat',
    'userFilterAll': 'Lahat',
    'userFilterAdmin': 'Admin',
    'userFilterOfficial': 'Official',
    'userFilterResident': 'Resident',
    'userFilterInactive': 'Hindi aktibo',
    'userRoleUpdated': 'Na-update ang role para sa {id}.',
    'userRoleUpdateFailed': 'Hindi na-update ang role.',
    'userActivated': 'Na-activate ang user {id}.',
    'userDeactivated': 'Na-deactivate ang user {id}.',
    'userStateUpdateFailed': 'Hindi na-update ang estado ng user.',
    'userSoftDeleteTitle': 'Soft delete ng user',
    'userSoftDeleteConfirm':
        'Itakda ang {id} na inactive at magtala ng deleted_at?',
    'userSoftDeleted': 'Na-soft delete ang user {id}.',
    'userSoftDeleteFailed': 'Nabigo ang soft delete.',
    'tokensCopied': 'Kinopya ang {n} token.',
    'userColumnUserId': 'user_id',
    'userColumnEmail': 'email',
    'userColumnUserType': 'user_type',
    'userColumnActive': 'active',
    'userColumnTokens': 'tokens',
    'locationPreview': 'Preview ng lokasyon',
    'copyTokens': 'Kopyahin ang tokens',
    'roleChangeHint': 'Palitan ang role',
    'paginationPage': 'Pahina',
    'paginationPageOf': 'Pahina {current} / {total}',
    'shelterOpen': 'Bukas',
    'shelterClosed': 'Sarado',
    'shelterStatusUpdated': 'Ang shelter {id} ay minarkahan bilang {status}.',
    'shelterCapacityUpdated': 'Na-update ang capacity para sa {id}.',
    'shelterOccupancyUpdated': 'Na-update ang occupancy para sa {id}.',
    'shelterStatusUpdateFailed': 'Nabigo ang pag-update ng status.',
    'shelterCapacityUpdateFailed': 'Nabigo ang pag-update ng capacity.',
    'shelterOccupancyUpdateFailed': 'Nabigo ang pag-update ng occupancy.',
    'shelterSoftDeleteTitle': 'Soft delete ng shelter',
    'shelterSoftDeleteConfirm':
        'Itakda ang {id} na inactive at panatilihin ang history?',
    'shelterSoftDeleted': 'Na-soft delete ang shelter {id}.',
    'shelterSoftDeleteFailed': 'Nabigo ang soft delete.',
    'shelterLoadError': 'Hindi ma-load ang mga shelter.',
    'shelterFilterAll': 'Lahat',
    'shelterOccupancyFilterAll': 'Lahat',
    'shelterOccupancyFilterAvailable': 'May bakante (<80%)',
    'shelterOccupancyFilterNearCap': 'Malapit puno (80–99%)',
    'shelterOccupancyFilterFull': 'Puno (100%)',
    'shelterUpdateCapacityTitle': 'I-update ang capacity',
    'shelterUpdateOccupancyTitle': 'I-update ang occupancy',
    'shelterLabelCapacity': 'capacity',
    'shelterLabelOccupancy': 'current_occupancy',
    'shelterColumnShelterId': 'shelter_id',
    'shelterColumnName': 'pangalan',
    'shelterColumnZone': 'zone',
    'shelterColumnStatus': 'status',
    'shelterColumnOccupancy': 'occupancy',
    'shelterColumnContact': 'contact',
    'shelterActionUpdateCapacity': 'I-update ang capacity',
    'shelterActionUpdateOccupancy': 'I-update ang occupancy',
    'shelterActionSoftDelete': 'Soft delete',
    'systemLogsColumnTimestamp': 'timestamp',
    'systemLogsColumnType': 'type',
    'systemLogsColumnAction': 'action',
    'systemLogsColumnAdminId': 'admin_id',
    'systemLogsColumnTargetId': 'target_id',
    'reportsColumnReportId': 'report_id',
    'reportsColumnCreatedAt': 'created_at',
    'reportsColumnZone': 'zone',
    'reportsColumnResidentId': 'resident_id',
    'reportsColumnStatus': 'status',
    'photoNoUrl': 'Walang photo URL',
    'photoLoadFailed': 'Hindi ma-load ang larawan',
    'semanticLoginEmail': 'Email address',
    'semanticLoginPassword': 'Password',
    'semanticRememberMe': 'Tandaan ako sa device na ito',
    'reportsNoneForFilter': 'Walang report para sa {filter}.',
    'reportsSelectOne': 'Pumili ng report para tingnan ang detalye.',
    'reportDetailTitle': 'Report {id}',
    'reportsFieldDescription': 'Deskripsyon',
    'reportsFieldPhoto': 'Larawan bilang ebidensya',
    'reportsFieldReviewer': 'Kasaysayan ng reviewer',
    'reportsDecisionLocked':
        'Tapos na ang desisyon. Hindi pa suportado ang muling buksan sa v1.',
    'reportsUnableToLoad': 'Hindi ma-load ang mga report.',
    'userSearchByEmailOrId': 'Maghanap ayon sa email o user_id',
    'usersUnableToLoad': 'Hindi ma-load ang mga user.',
    'usersEmpty': 'Walang user na natagpuan.',
    'usersSelectOne': 'Pumili ng user para tingnan ang detalye.',
    'userAdminProtected':
        'Protektado ang mga admin account mula sa pagbabago ng role/estado.',
    'userActionDeactivate': 'I-deactivate',
    'userActionActivate': 'I-activate',
    'userRoleOfficial': 'official',
    'userRoleResident': 'resident',
    'mapNoCoordinates': 'Walang coordinates',
    'mapKeyMissing': 'Walang Google Maps key.\nCoordinates: {lat}, {lng}',
    'shelterFilterStatusLabel': 'Status',
    'shelterFilterZoneLabel': 'Zone',
    'shelterOccupancyLevelLabel': 'Antas ng occupancy',
    'shelterSearchByNameOrContact': 'Maghanap ayon sa pangalan o contact',
    'shelterActiveCount': '{n} aktibong shelter',
    'sheltersEmptyFiltered': 'Walang shelter sa kasalukuyang filter.',
    'sheltersSelectOne': 'Pumili ng shelter para tingnan ang detalye.',
    'shelterActionOpen': 'Buksan',
    'shelterActionClose': 'Isara',
    'shelterAuditNotice':
        'Lahat ng pagbabago ay naka-log sa System_Logs bilang audit record.',
    'shelterMapLoadFailed': 'Hindi na-load ang mapa.\nCoordinates: {lat}, {lng}',
    'systemLogsTypeLabel': 'Uri',
    'systemLogsDateLast24h': 'Huling 24h',
    'systemLogsDateLast7d': 'Huling 7 araw',
    'systemLogsDateLast30d': 'Huling 30 araw',
    'systemLogsDateAllTime': 'Lahat',
    'systemLogsSearchNotes': 'Hanapin sa notes/ids',
    'systemLogsFilterAction': 'I-filter ang action',
    'systemLogsFilterAdminId': 'I-filter ang admin_id',
    'systemLogsFilterTargetId': 'I-filter ang target_id',
    'systemLogsMatchingCount': '{n} tumutugmang log',
    'systemLogsUnableToLoad': 'Hindi ma-load ang system logs.',
    'systemLogsNoMatches': 'Walang log sa kasalukuyang filter.',
    'systemLogsLoadingMore': 'Naglo-load…',
    'systemLogsSelectLog': 'Pumili ng log entry para sa detalye.',
  },
};
