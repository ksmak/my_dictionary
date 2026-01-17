import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('ru'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'My Dictionary'**
  String get app_title;

  /// No description provided for @btn_open_dict.
  ///
  /// In en, this message translates to:
  /// **'Open dictionary'**
  String get btn_open_dict;

  /// No description provided for @btn_lean_words.
  ///
  /// In en, this message translates to:
  /// **'Learn words'**
  String get btn_lean_words;

  /// No description provided for @err_category_not_empty.
  ///
  /// In en, this message translates to:
  /// **'Error! Category cannot be empty.'**
  String get err_category_not_empty;

  /// No description provided for @err_category_exists.
  ///
  /// In en, this message translates to:
  /// **'Error! Category already exists in the dictionary.'**
  String get err_category_exists;

  /// No description provided for @txt_delete_category.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get txt_delete_category;

  /// No description provided for @txt_warning_delete_category.
  ///
  /// In en, this message translates to:
  /// **'All words in this category will also be deleted. Continue?'**
  String get txt_warning_delete_category;

  /// No description provided for @btn_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btn_cancel;

  /// No description provided for @btn_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btn_delete;

  /// No description provided for @txt_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get txt_category;

  /// No description provided for @txt_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get txt_categories;

  /// No description provided for @txt_no_data.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get txt_no_data;

  /// No description provided for @txt_today_no_words.
  ///
  /// In en, this message translates to:
  /// **'There are no words for today checks'**
  String get txt_today_no_words;

  /// No description provided for @btn_back.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get btn_back;

  /// No description provided for @btn_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btn_next;

  /// No description provided for @btn_check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get btn_check;

  /// No description provided for @txt_right.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get txt_right;

  /// No description provided for @txt_wrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong!'**
  String get txt_wrong;

  /// No description provided for @txt_answer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: '**
  String get txt_answer;

  /// No description provided for @err_word_no_empty.
  ///
  /// In en, this message translates to:
  /// **'Error! A word cannot be empty.'**
  String get err_word_no_empty;

  /// No description provided for @err_trans_no_empty.
  ///
  /// In en, this message translates to:
  /// **'Error! A translation cannot be empty.'**
  String get err_trans_no_empty;

  /// No description provided for @err_word_exists.
  ///
  /// In en, this message translates to:
  /// **'Error! The word already exists in the dictionary.'**
  String get err_word_exists;

  /// No description provided for @txt_delete_word.
  ///
  /// In en, this message translates to:
  /// **'Delete a word'**
  String get txt_delete_word;

  /// No description provided for @txt_ask_delete_word.
  ///
  /// In en, this message translates to:
  /// **'Delete this word?'**
  String get txt_ask_delete_word;

  /// No description provided for @txt_trans.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get txt_trans;

  /// No description provided for @txt_level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get txt_level;

  /// No description provided for @txt_word.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get txt_word;

  /// No description provided for @txt_stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get txt_stats;

  /// No description provided for @txt_count_for_level.
  ///
  /// In en, this message translates to:
  /// **'Number of words by level:'**
  String get txt_count_for_level;

  /// No description provided for @txt_count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get txt_count;

  /// No description provided for @txt_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get txt_today;

  /// No description provided for @txt_leant.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get txt_leant;

  /// No description provided for @btn_import.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get btn_import;

  /// No description provided for @btn_export.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get btn_export;

  /// No description provided for @err_import.
  ///
  /// In en, this message translates to:
  /// **'Error! Incorrect data format.'**
  String get err_import;

  /// No description provided for @btn_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btn_close;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
