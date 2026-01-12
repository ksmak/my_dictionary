import 'package:my_dictionary/data/category.dart';

/// Структура Слово. Содержит:
/// - Уникальный идентификатор
/// - Категория (связь с таблицей категорий)
/// - Наименование
/// - Перевод
/// - Уровень знания наименования
/// - Уровень знания перевода
/// - Дата последнего обновления уровня наименования
/// - Дата последнего обновления уровня перевода
/// - Дата добавления слова
///
/// Используется во всех слоях приложения:
/// - UI: отображение в списках, карточках
/// - Бизнес-логика: тренировки, статистика
/// - Данные: сохранение в SQLite
///
/// Пример JSON из БД:
/// ```json
/// {
///   "id": 1,
///   "category": {"id": 2, "name": "Greetings", "created_at": "2023-10-10 10:00:00"},
///   "name": "Hello",
///   "translation": "Привет",
///   "nameLevel": 3,
///   "translationLevel": 2,
///   "updateAtNameLevel": "2024-06-01T12:00:00Z",
///   "updateAtTranslationLevel": "2024-06-02T12:00:00Z",
///   "createdAt": "2024-05-01T10:00:00Z",
///   "testType": 1
/// }
/// ```
class Word {
  final int id; // Уникальный ID слова в БД
  final Category category; // Категория слова
  final String name; // Оригинальное слово (например, "Hello")
  final String translation; // Основной перевод слова (например, "Привет")
  final int nameLevel; // Уровень знания оригинального слова (0-7)
  final int translationLevel; // Уровень знания перевода (0-7)
  final String
  updateAtNameLevel; // Дата последнего обновления уровня оригинального слова
  final String
  updateAtTranslationLevel; // Дата последнего обновления уровня перевода
  final String createdAt; // Дата добавления слова
  final int testType; // Тип теста для текущего слова (временное поле)

  Word({
    required this.id,
    required this.category,
    required this.name,
    required this.translation,
    this.nameLevel = 0,
    this.translationLevel = 0,
    this.updateAtNameLevel = '',
    this.updateAtTranslationLevel = '',
    this.createdAt = '',
    this.testType = 0,
  });

  // метод для копирования объекта с возможностью изменения полей
  Word copyWith({
    int? id,
    Category? category,
    String? name,
    String? translation,
    int? nameLevel,
    int? translationLevel,
    String? updateAtNameLevel,
    String? updateAtTranslationLevel,
    String? createdAt,
    int? testType,
  }) {
    return Word(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      translation: translation ?? this.translation,
      nameLevel: nameLevel ?? this.nameLevel,
      translationLevel: translationLevel ?? this.translationLevel,
      updateAtNameLevel: updateAtNameLevel ?? this.updateAtNameLevel,
      updateAtTranslationLevel:
          updateAtTranslationLevel ?? this.updateAtTranslationLevel,
      createdAt: createdAt ?? this.createdAt,
      testType: testType ?? this.testType,
    );
  }
}
