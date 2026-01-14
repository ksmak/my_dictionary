// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'My Dictionary';

  @override
  String get btn_open_dict => 'Open Dictionary';

  @override
  String get btn_lean_words => 'Learn Words';

  @override
  String get err_category_not_empty => 'Error! Category cannot be empty.';

  @override
  String get err_category_exists =>
      'Error! Category already exists in the dictionary.';

  @override
  String get txt_delete_category => 'Delete Category';

  @override
  String get txt_warning_delete_category =>
      'All words in this category will also be deleted. Continue?';

  @override
  String get btn_cancel => 'Cancel';

  @override
  String get btn_delete => 'Delete';

  @override
  String get txt_category => 'Category';

  @override
  String get txt_categories => 'Categories';

  @override
  String get txt_no_data => 'No data';

  @override
  String get txt_today_no_words => 'There are no words for today checks';

  @override
  String get btn_back => 'Go back';

  @override
  String get btn_next => 'Next';

  @override
  String get btn_check => 'Check';

  @override
  String get txt_right => 'Correct!';

  @override
  String get txt_wrong => 'Wrong!';

  @override
  String get txt_answer => 'Correct answer: ';

  @override
  String get err_word_no_empty => 'Error! A word cannot be empty.';

  @override
  String get err_trans_no_empty => 'Error! A translation cannot be empty.';

  @override
  String get err_word_exists =>
      'Error! The word already exists in the dictionary.';

  @override
  String get txt_delete_word => 'Delete a word';

  @override
  String get txt_ask_delete_word => 'Delete this word?';

  @override
  String get txt_trans => 'Translation';

  @override
  String get txt_level => 'Level';

  @override
  String get txt_word => 'Word';

  @override
  String get txt_stats => 'Statistics';

  @override
  String get txt_count_for_level => 'Number of words by level:';

  @override
  String get txt_count => 'Count';

  @override
  String get txt_today => 'Today';

  @override
  String get txt_leant => 'Learned';
}
