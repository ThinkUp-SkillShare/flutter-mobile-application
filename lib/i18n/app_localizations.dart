import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
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
  ];

  /// Search bar label
  ///
  /// In en, this message translates to:
  /// **'Search for groups, subjects...'**
  String get global_searchBarLabel;

  /// No description provided for @featuredGroups.
  ///
  /// In en, this message translates to:
  /// **'Featured Groups'**
  String get featuredGroups;

  /// No description provided for @popularSubjects.
  ///
  /// In en, this message translates to:
  /// **'Popular Subjects'**
  String get popularSubjects;

  /// No description provided for @noGroupsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No groups available'**
  String get noGroupsAvailable;

  /// No description provided for @createOrJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Create or join a group to get started'**
  String get createOrJoinGroup;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @exploreGroups.
  ///
  /// In en, this message translates to:
  /// **'Explore Groups'**
  String get exploreGroups;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your Account'**
  String get loginToYourAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @pleaseEnterAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter all fields'**
  String get pleaseEnterAllFields;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Tag joined {year}
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get profile_joined;

  /// Group stats bottom label
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get profile_groups;

  /// Doc stats bottom label
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get profile_docs;

  /// Friend stats bottom label
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get profile_friends;

  /// Badge Section Title
  ///
  /// In en, this message translates to:
  /// **'My Badges'**
  String get profile_badgeSectionTitle;

  /// Activity Summary Section Title
  ///
  /// In en, this message translates to:
  /// **'Activity Overview'**
  String get profile_activitySummarySectionTitle;

  /// Text Number of Hours
  ///
  /// In en, this message translates to:
  /// **'Study hours:'**
  String get profile_textNumberHours;

  /// Abbreviation for Monday
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get profile_mondayTag;

  /// Abbreviation for Tuesday
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get profile_tuesdayTag;

  /// Abbreviation for Wednesday
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get profile_wednesdayTag;

  /// Abbreviation for Thursday
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get profile_thursdayTag;

  /// Abbreviation for Friday
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get profile_fridayTag;

  /// Abbreviation for Saturday
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get profile_saturdayTag;

  /// Abbreviation for Sunday
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get profile_sundayTag;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language option in settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language name
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Notifications section
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Theme section
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Default option
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get predetermined;

  /// System theme
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;
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
      <String>['en', 'es'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
