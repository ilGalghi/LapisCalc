import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ro.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ro')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectedLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get selectedLanguage;

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World'**
  String get helloWorld;

  /// No description provided for @angle.
  ///
  /// In en, this message translates to:
  /// **'Angle'**
  String get angle;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get length;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @mass.
  ///
  /// In en, this message translates to:
  /// **'Mass'**
  String get mass;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @scientific.
  ///
  /// In en, this message translates to:
  /// **'Scientific'**
  String get scientific;

  /// No description provided for @calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// No description provided for @converter.
  ///
  /// In en, this message translates to:
  /// **'Converter'**
  String get converter;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @setsignificantfigures.
  ///
  /// In en, this message translates to:
  /// **'Set Significant Figures'**
  String get setsignificantfigures;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @selectlanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectlanguage;

  /// No description provided for @sameday.
  ///
  /// In en, this message translates to:
  /// **'Same Day'**
  String get sameday;

  /// No description provided for @datedifference.
  ///
  /// In en, this message translates to:
  /// **'Date Difference'**
  String get datedifference;

  /// No description provided for @addsubtractdays.
  ///
  /// In en, this message translates to:
  /// **'Add/Subtract Days'**
  String get addsubtractdays;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @difference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get difference;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @dayM.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayM;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @monthM.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthM;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @yearM.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearM;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @usesystemcolorscheme.
  ///
  /// In en, this message translates to:
  /// **'Use system color scheme'**
  String get usesystemcolorscheme;

  /// No description provided for @usingsystemdynamiccolor.
  ///
  /// In en, this message translates to:
  /// **'Using system dynamic color'**
  String get usingsystemdynamiccolor;

  /// No description provided for @usingdefaultcolorscheme.
  ///
  /// In en, this message translates to:
  /// **'Using default color scheme'**
  String get usingdefaultcolorscheme;

  /// No description provided for @adding.
  ///
  /// In en, this message translates to:
  /// **'Adding'**
  String get adding;

  /// No description provided for @subtracting.
  ///
  /// In en, this message translates to:
  /// **'Subtracting'**
  String get subtracting;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @clearedHistory.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get clearedHistory;

  /// No description provided for @onlyforConvertors.
  ///
  /// In en, this message translates to:
  /// **'This settings is exclusively for unit convertors'**
  String get onlyforConvertors;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get leaveReview;

  /// No description provided for @buyMeCoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee!'**
  String get buyMeCoffee;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @tippercentage.
  ///
  /// In en, this message translates to:
  /// **'Tip percentage'**
  String get tippercentage;

  /// No description provided for @tipamount.
  ///
  /// In en, this message translates to:
  /// **'Tip amount'**
  String get tipamount;

  /// No description provided for @totalamount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalamount;

  /// No description provided for @contactme.
  ///
  /// In en, this message translates to:
  /// **'Contact me'**
  String get contactme;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'it', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
