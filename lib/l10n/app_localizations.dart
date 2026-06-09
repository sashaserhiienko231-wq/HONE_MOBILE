import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Gaming Hub Ultimate'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBoost.
  ///
  /// In en, this message translates to:
  /// **'Boost'**
  String get navBoost;

  /// No description provided for @navGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get navGames;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System Performance Monitor'**
  String get homeSubtitle;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @dnsBoostTitle.
  ///
  /// In en, this message translates to:
  /// **'DNS BOOST'**
  String get dnsBoostTitle;

  /// No description provided for @dnsBoostBadge.
  ///
  /// In en, this message translates to:
  /// **'LATENCY -40%'**
  String get dnsBoostBadge;

  /// No description provided for @dnsBoostDescription.
  ///
  /// In en, this message translates to:
  /// **'Optimize network packet routing and lower jitter.'**
  String get dnsBoostDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure your optimization experience'**
  String get settingsSubtitle;

  /// No description provided for @settingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load settings'**
  String get settingsLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @optimizationSettings.
  ///
  /// In en, this message translates to:
  /// **'Optimization Settings'**
  String get optimizationSettings;

  /// No description provided for @autoOptimization.
  ///
  /// In en, this message translates to:
  /// **'Auto-Optimization'**
  String get autoOptimization;

  /// No description provided for @autoOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically optimize system performance'**
  String get autoOptimizationDesc;

  /// No description provided for @backgroundMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Background Monitoring'**
  String get backgroundMonitoring;

  /// No description provided for @backgroundMonitoringDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor performance in background'**
  String get backgroundMonitoringDesc;

  /// No description provided for @gameMode.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameMode;

  /// No description provided for @gameModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto-enable optimizations when gaming'**
  String get gameModeDesc;

  /// No description provided for @performanceSettings.
  ///
  /// In en, this message translates to:
  /// **'Performance Settings'**
  String get performanceSettings;

  /// No description provided for @performanceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Performance Alerts'**
  String get performanceAlerts;

  /// No description provided for @thermalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Temperature Alerts'**
  String get thermalAlerts;

  /// No description provided for @batteryAlerts.
  ///
  /// In en, this message translates to:
  /// **'Battery Alerts'**
  String get batteryAlerts;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @neonEffects.
  ///
  /// In en, this message translates to:
  /// **'Neon Effects'**
  String get neonEffects;

  /// No description provided for @animations.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animations;

  /// No description provided for @homeWidgets.
  ///
  /// In en, this message translates to:
  /// **'Home Screen Widgets'**
  String get homeWidgets;

  /// No description provided for @enableWidgets.
  ///
  /// In en, this message translates to:
  /// **'Enable Widgets'**
  String get enableWidgets;

  /// No description provided for @widgetPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance Widget'**
  String get widgetPerformance;

  /// No description provided for @widgetFps.
  ///
  /// In en, this message translates to:
  /// **'FPS Widget'**
  String get widgetFps;

  /// No description provided for @widgetGamingMode.
  ///
  /// In en, this message translates to:
  /// **'Gaming Mode Widget'**
  String get widgetGamingMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @releaseStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get releaseStable;

  /// No description provided for @applicationSection.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get applicationSection;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacyScreenLock.
  ///
  /// In en, this message translates to:
  /// **'Use device screen lock'**
  String get privacyScreenLock;

  /// No description provided for @privacyAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous diagnostics'**
  String get privacyAnalytics;

  /// No description provided for @privacyBackup.
  ///
  /// In en, this message translates to:
  /// **'Encrypt cloud backups'**
  String get privacyBackup;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Gaming Hub'**
  String get homeTitle;

  /// No description provided for @optimizedForDevice.
  ///
  /// In en, this message translates to:
  /// **'Optimized for {device}'**
  String optimizedForDevice(String device);

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navGamingHub.
  ///
  /// In en, this message translates to:
  /// **'Gaming Hub'**
  String get navGamingHub;

  /// No description provided for @navOptimization.
  ///
  /// In en, this message translates to:
  /// **'Optimization'**
  String get navOptimization;

  /// No description provided for @navPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get navPremium;

  /// No description provided for @boostPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Performance Boost'**
  String get boostPageTitle;

  /// No description provided for @boostPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Precision system engine tuning'**
  String get boostPageSubtitle;

  /// No description provided for @systemBoosted.
  ///
  /// In en, this message translates to:
  /// **'System Boosted!'**
  String get systemBoosted;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @startBoost.
  ///
  /// In en, this message translates to:
  /// **'START BOOST'**
  String get startBoost;

  /// No description provided for @boosting.
  ///
  /// In en, this message translates to:
  /// **'BOOSTING...'**
  String get boosting;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'id',
        'it',
        'ja',
        'ko',
        'pl',
        'pt',
        'ru',
        'th',
        'tr',
        'uk',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
