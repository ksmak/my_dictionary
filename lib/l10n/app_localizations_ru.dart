// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get app_title => 'Мой словарь';

  @override
  String get btn_open_dict => 'Открыть словарь';

  @override
  String get btn_lean_words => 'Учить слова';

  @override
  String get err_category_not_empty =>
      'Ошибка! Категория не может быть пустой.';

  @override
  String get err_category_exists =>
      'Ошибка! Категория уже существует в словаре.';

  @override
  String get txt_delete_category => 'Удаление категории';

  @override
  String get txt_warning_delete_category =>
      'Все слова в этой категории также будут удалены. Продолжить?';

  @override
  String get btn_cancel => 'Отмена';

  @override
  String get btn_delete => 'Удалить';

  @override
  String get txt_category => 'Категория';

  @override
  String get txt_categories => 'Категории';

  @override
  String get txt_no_data => 'Нет данных';

  @override
  String get txt_today_no_words => 'На сегодня нет слов для проверки';

  @override
  String get btn_back => 'Вернуться назад';

  @override
  String get btn_next => 'Следующий';

  @override
  String get btn_check => 'Проверить';

  @override
  String get txt_right => 'Правильно!';

  @override
  String get txt_wrong => 'Неправильно!';

  @override
  String get txt_answer => 'Правильный ответ: ';

  @override
  String get err_word_no_empty => 'Ошибка! Слово не может быть пустым.';

  @override
  String get err_trans_no_empty => 'Ошибка! Перевод не может быть пустым.';

  @override
  String get err_word_exists => 'Ошибка! Слово уже существует в словаре.';

  @override
  String get txt_delete_word => 'Удаление слова';

  @override
  String get txt_ask_delete_word => 'Удалить это слово?';

  @override
  String get txt_trans => 'Перевод';

  @override
  String get txt_level => 'Уровень';

  @override
  String get txt_word => 'Слово';

  @override
  String get txt_stats => 'Статистика';

  @override
  String get txt_count_for_level => 'Количество слов по уровням:';

  @override
  String get txt_count => 'Количество';

  @override
  String get txt_today => 'На сегодня';

  @override
  String get txt_leant => 'Выученных';

  @override
  String get btn_import => 'Импортировать данные';

  @override
  String get btn_export => 'Экспортировать данные';

  @override
  String get err_import => 'Ошибка! Неправильный формат данных.';

  @override
  String get btn_close => 'Закрыть';
}
