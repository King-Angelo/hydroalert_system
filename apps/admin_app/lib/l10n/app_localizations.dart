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
  String get placeholderSuffix => _t('placeholderSuffix');
  String get situationPane => _t('situationPane');
  String get activityFeed => _t('activityFeed');
  String get actionQueue => _t('actionQueue');
  String get actionQueuePlaceholder => _t('actionQueuePlaceholder');
  String get validate => _t('validate');
  String get reject => _t('reject');
  String get situationMapStaticMock => _t('situationMapStaticMock');
  String get staticMockMapBadge => _t('staticMockMapBadge');
  String get addMockMapAsset => _t('addMockMapAsset');
  String get statusPending => _t('statusPending');
  String get statusValidated => _t('statusValidated');
  String get statusApproved => _t('statusApproved');
  String get statusRejected => _t('statusRejected');
  String get statusCritical => _t('statusCritical');
  String get statusElevated => _t('statusElevated');
  String get statusHeavy => _t('statusHeavy');
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
    'placeholderSuffix': 'placeholder',
    'situationPane': 'Situation Pane',
    'activityFeed': 'Activity Feed',
    'actionQueue': 'Action Queue',
    'actionQueuePlaceholder': 'Incident verification placeholder panel',
    'validate': 'Validate',
    'reject': 'Reject',
    'situationMapStaticMock': 'Situation Map (Static Mock)',
    'staticMockMapBadge': 'STATIC MOCK MAP',
    'addMockMapAsset': 'Add assets/images/mock_map.png',
    'statusPending': 'Pending',
    'statusValidated': 'Validated',
    'statusApproved': 'Approved',
    'statusRejected': 'Rejected',
    'statusCritical': 'Critical',
    'statusElevated': 'Elevated',
    'statusHeavy': 'Heavy',
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
    'placeholderSuffix': 'placeholder',
    'situationPane': 'Situation Pane',
    'activityFeed': 'Activity Feed',
    'actionQueue': 'Action Queue',
    'actionQueuePlaceholder': 'Placeholder panel para sa beripikasyon ng insidente',
    'validate': 'I-validate',
    'reject': 'I-reject',
    'situationMapStaticMock': 'Situation Map (Static Mock)',
    'staticMockMapBadge': 'STATIC MOCK MAP',
    'addMockMapAsset': 'Idagdag ang assets/images/mock_map.png',
    'statusPending': 'Pending',
    'statusValidated': 'Validated',
    'statusApproved': 'Approved',
    'statusRejected': 'Rejected',
    'statusCritical': 'Critical',
    'statusElevated': 'Elevated',
    'statusHeavy': 'Heavy',
  },
};
