import 'package:my_dictionary/data/category.dart';

/// Структура Слово. Содержит:
/// - Уникальный идентификатор
/// - Категория (связь с таблицей категорий)
/// - Наименование
/// - Перевод
/// - Уровень знания
/// - Дата последнего обновления уровня
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
///   "level": 3,
///   "updateAt": "2024-06-01T12:00:00Z",
///   "createdAt": "2024-05-01T10:00:00Z"
/// }
/// ```
class Word {
  final int id; // Уникальный ID слова в БД
  final Category category; // Категория слова
  final String name; // Оригинальное слово (например, "Hello")
  final String translation; // Основной перевод слова (например, "Привет")
  final int level; // Уровень знания (0-7)
  final String updateAt; // Дата последнего обновления уровня
  final String createdAt; // Дата добавления слова

  Word({
    required this.id,
    required this.category,
    required this.name,
    required this.translation,
    this.level = 0,
    this.updateAt = '',
    this.createdAt = '',
  });

  // метод для копирования объекта с возможностью изменения полей
  Word copyWith({
    int? id,
    Category? category,
    String? name,
    String? translation,
    int? level,
    String? updateAt,
    String? createdAt,
  }) {
    return Word(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      translation: translation ?? this.translation,
      level: level ?? this.level,
      updateAt: updateAt ?? this.updateAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
