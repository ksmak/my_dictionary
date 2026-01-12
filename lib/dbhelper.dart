import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'data/category.dart';
import 'data/word.dart';

/// Класс для работы с базой данных SQLite.
///
/// Реализует singleton паттерн для единого подключения к БД.
/// Отвечает за все CRUD операции со словами и переводами.
///
/// Структура БД:
/// - categories: таблица категорий (id, name, created_at)
/// - words: таблица слов (id, name, translation, name_level, translation_level,
///          update_at_name_level, update_at_translation_level, created_at)
class DBHelper {
  static final DBHelper instance = DBHelper._instance();
  static Database? _db;
  static const bool _shouldRecreateDbInDebug = true;
  static const int _databaseVersion = 1;

  DBHelper._instance();

  Future<Database> get db async => _db ??= await _initDb();

  /// Инициализация базы данных
  Future<Database> _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mydict.db');

    // В режиме отладки пересоздаем БД (удобно для разработки)
    if (kDebugMode && _shouldRecreateDbInDebug) {
      try {
        await deleteDatabase(path);
      } catch (e) {
        // Игнорируем ошибку если файла нет
      }
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Создание таблиц
  Future<void> _onCreate(Database db, int version) async {
    // Создаем таблицу категорий
    await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          name TEXT NOT NULL UNIQUE,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP          
        )
      ''');
    // Создаем таблицу слов
    await db.execute('''
        CREATE TABLE words(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          category_id INTEGER,
          name TEXT NOT NULL UNIQUE,
          translation TEXT NOT NULL,
          name_level INTEGER DEFAULT 0,
          translation_level INTEGER DEFAULT 0,
          update_at_name_level DATETIME DEFAULT CURRENT_TIMESTAMP,
          update_at_translation_level DATETIME DEFAULT CURRENT_TIMESTAMP,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP          
        )
      ''');

    // Создаем индекс для ускорения поиска слов по имени
    await db.execute('''
        CREATE INDEX idx_words_name 
        ON words(name)
      ''');

    // Создаем индекс для ускорения поиска слов по переводу
    await db.execute('''
        CREATE INDEX idx_words_translation 
        ON words(translation)
      ''');
  }

  /// Получение списка всех категорий из БД
  Future<List<Category>> getAllCategories() async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createdAt: maps[i]['created_at'],
      );
    });
  }

  /// Вставляет новую категорию в БД
  Future<Category> insertCategory(String name) async {
    final db = await this.db;
    final id = await db.insert('categories', {'name': name});
    return await getCategoryById(id) as Category;
  }

  /// Обновляет категорию в БД
  Future<Category> updateCategory(int id, String name) async {
    final db = await this.db;
    await db.update(
      'categories',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
    return await getCategoryById(id) as Category;
  }

  /// Удаляет категорию из БД по ID
  Future<void> deleteCategory(int id) async {
    final db = await this.db;
    await db.delete('words', where: 'category_id = ?', whereArgs: [id]);
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  /// Получает категорию по ID
  Future<Category?> getCategoryById(int id) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category(
        id: maps[0]['id'],
        name: maps[0]['name'],
        createdAt: maps[0]['created_at'],
      );
    }
    return null;
  }

  /// Получает категорию по наименованию
  Future<Category?> getCategoryByName(String name) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Category(
        id: maps[0]['id'],
        name: maps[0]['name'],
        createdAt: maps[0]['created_at'],
      );
    }
    return null;
  }

  /// Вставляет новое слово в БД
  Future<Word?> insertWord(Word word) async {
    final db = await this.db;
    final id = await db.insert('words', {
      'category_id': word.category.id,
      'name': word.name,
      'translation': word.translation,
      'name_level': word.nameLevel,
      'translation_level': word.translationLevel,
      'update_at_name_level': word.updateAtNameLevel,
      'update_at_translation_level': word.updateAtTranslationLevel,
      'created_at': word.createdAt,
    });
    return await getWordById(id);
  }

  /// Обновляет данные слова в БД
  Future<Word?> updateWord(Word word) async {
    final db = await this.db;
    final id = await db.update(
      'words',
      {
        'category_id': word.category.id,
        'name': word.name,
        'translation': word.translation,
        'name_level': word.nameLevel,
        'translation_level': word.translationLevel,
        'update_at_name_level': word.updateAtNameLevel,
        'update_at_translation_level': word.updateAtTranslationLevel,
        'created_at': word.createdAt,
      },
      where: 'id = ?',
      whereArgs: [word.id],
    );
    return await getWordById(id);
  }

  /// Удаляет слово из БД по ID
  Future<int> deleteWord(int id) async {
    final db = await this.db;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  /// Получает списка слов из БД
  Future<List<Word>> getAllWords(int categoryId) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );

    final category = await getCategoryById(categoryId);

    return List.generate(maps.length, (i) {
      return Word(
        id: maps[i]['id'],
        category: category!,
        name: maps[i]['name'],
        translation: maps[i]['translation'],
        nameLevel: maps[i]['name_level'],
        translationLevel: maps[i]['translation_level'],
        updateAtNameLevel: maps[i]['update_at_name_level'],
        updateAtTranslationLevel: maps[i]['update_at_translation_level'],
        createdAt: maps[i]['created_at'],
      );
    });
  }

  /// Получает отфильтрованный список слов из БД
  Future<List<Word>> getFilteredWords(int categoryId) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: '''
        category_id = ? AND (
          (name_level == 0 AND translation_level == 0) OR
          (name_level == 1 AND update_at_name_level <= datetime('now', '-1 day')) OR
          (translation_level == 1 AND update_at_translation_level <= datetime('now', '-1 day')) OR
          (name_level == 2 AND update_at_name_level <= datetime('now', '-1 day')) OR
          (translation_level == 2 AND update_at_translation_level <= datetime('now', '-1 day')) OR
          (name_level == 3 AND update_at_name_level <= datetime('now', '-1 day')) OR
          (translation_level == 3 AND update_at_translation_level <= datetime('now', '-1 day')) OR
          (name_level == 4 AND update_at_name_level <= datetime('now', '-7 days')) OR
          (translation_level == 4 AND update_at_translation_level <= datetime('now', '-7 days')) OR
          (name_level == 5 AND update_at_name_level <= datetime('now', '-14 days')) OR
          (translation_level == 5 AND update_at_translation_level <= datetime('now', '-14 days')) OR
          (name_level == 6 AND update_at_name_level <= datetime('now', '-30 days')) OR
          (translation_level == 6 AND update_at_translation_level <= datetime('now', '-30 days')) OR
          (name_level == 7 AND update_at_name_level <= datetime('now', '-90 days')) OR
          (translation_level == 7 AND update_at_translation_level <= datetime('now', '-90 days'))
        )
      ''',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );

    final category = await getCategoryById(categoryId);

    return List.generate(maps.length, (i) {
      return Word(
        id: maps[i]['id'],
        category: category!,
        name: maps[i]['name'],
        translation: maps[i]['translation'],
        nameLevel: maps[i]['name_level'],
        translationLevel: maps[i]['translation_level'],
        updateAtNameLevel: maps[i]['update_at_name_level'],
        updateAtTranslationLevel: maps[i]['update_at_translation_level'],
        createdAt: maps[i]['created_at'],
      );
    });
  }

  /// Получает слово по ID
  Future<Word?> getWordById(int id) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );

    final category = await getCategoryById(maps[0]['category_id']);

    if (maps.isNotEmpty) {
      return Word(
        id: maps[0]['id'],
        category: category!,
        name: maps[0]['name'],
        translation: maps[0]['translation'],
        nameLevel: maps[0]['name_level'],
        translationLevel: maps[0]['translation_level'],
        updateAtNameLevel: maps[0]['update_at_name_level'],
        updateAtTranslationLevel: maps[0]['update_at_translation_level'],
        createdAt: maps[0]['created_at'],
      );
    }
    return null;
  }

  /// Получает слово по наименованию
  Future<Word?> getWordByName(String name) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'name = ?',
      whereArgs: [name],
    );

    final category = await getCategoryById(maps[0]['category_id']);

    if (maps.isNotEmpty) {
      return Word(
        id: maps[0]['id'],
        category: category!,
        name: maps[0]['name'],
        translation: maps[0]['translation'],
        nameLevel: maps[0]['name_level'],
        translationLevel: maps[0]['translation_level'],
        updateAtNameLevel: maps[0]['update_at_name_level'],
        updateAtTranslationLevel: maps[0]['update_at_translation_level'],
        createdAt: maps[0]['created_at'],
      );
    }
    return null;
  }

  /// Получает слово по переводу
  Future<Word?> getWordByTranslation(String translation) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'translation = ?',
      whereArgs: [translation],
    );

    final category = await getCategoryById(maps[0]['category_id']);

    if (maps.isNotEmpty) {
      return Word(
        id: maps[0]['id'],
        category: category!,
        name: maps[0]['name'],
        translation: maps[0]['translation'],
        nameLevel: maps[0]['name_level'],
        translationLevel: maps[0]['translation_level'],
        updateAtNameLevel: maps[0]['update_at_name_level'],
        updateAtTranslationLevel: maps[0]['update_at_translation_level'],
        createdAt: maps[0]['created_at'],
      );
    }
    return null;
  }

  /// Получает статистику по изученным словам, разложенную по уровням
  Future<Map<String, int>> getLearningStatistics() async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN name_level == 0 OR translation_level == 0 THEN 1 ELSE 0 END) AS learned_count0,
        SUM(CASE WHEN name_level == 1 OR translation_level == 1 THEN 1 ELSE 0 END) AS learned_count1,
        SUM(CASE WHEN name_level == 2 OR translation_level == 2 THEN 1 ELSE 0 END) AS learned_count2,
        SUM(CASE WHEN name_level == 3 OR translation_level == 3 THEN 1 ELSE 0 END) AS learned_count3,
        SUM(CASE WHEN name_level == 4 OR translation_level == 4 THEN 1 ELSE 0 END) AS learned_count4,
        SUM(CASE WHEN name_level == 5 OR translation_level == 5 THEN 1 ELSE 0 END) AS learned_count5,
        SUM(CASE WHEN name_level == 6 OR translation_level == 6 THEN 1 ELSE 0 END) AS learned_count6,
        SUM(CASE WHEN name_level == 7 OR translation_level == 7 THEN 1 ELSE 0 END) AS learned_count7,
        SUM(CASE WHEN name_level > 7 OR translation_level > 7 THEN 1 ELSE 0 END) AS learned_count_all
      FROM words
    ''');
    return result.isNotEmpty
        ? result[0].map((key, value) => MapEntry(key, value as int))
        : {};
  }

  /// Обновляет уровень знания имени слова
  Future<void> updateNameLevel(int wordId, int newLevel) async {
    final db = await this.db;
    await db.update(
      'words',
      {
        'name_level': newLevel,
        'update_at_name_level': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [wordId],
    );
  }

  /// Обновляет уровень знания перевода слова
  Future<void> updateTranslationLevel(int wordId, int newLevel) async {
    final db = await this.db;
    await db.update(
      'words',
      {
        'translation_level': newLevel,
        'update_at_translation_level': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [wordId],
    );
  }

  /// Закрывает соединение с БД
  Future<void> close() async {
    try {
      final db = await this.db;
      await db.close();
      _db = null;
    } catch (e) {
      debugPrint('Ошибка при закрытии БД: $e');
    }
  }

  /// Заполняет БД тестовыми данными (только для разработки)
  Future<void> populateTestData() async {
    if (kDebugMode && _shouldRecreateDbInDebug) {
      final db = await this.db;

      // Проверяем, есть ли уже данные
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM words'),
      );
      if (count != null && count > 0) {
        return; // Данные уже есть, не заполняем
      }

      // Создаем тестовую категорию
      Category testCategory = await insertCategory('Test Category');

      // Вставляем тестовые слова
      List<Word> testWords = [
        Word(
          id: 0,
          category: testCategory,
          name: 'hello',
          translation: 'привет',
        ),
        Word(id: 0, category: testCategory, name: 'world', translation: 'мир'),
        Word(
          id: 0,
          category: testCategory,
          name: 'computer',
          translation: 'компьютер',
        ),
        Word(
          id: 0,
          category: testCategory,
          name: 'language',
          translation: 'язык',
        ),
        Word(
          id: 0,
          category: testCategory,
          name: 'flutter',
          translation: 'флаттер',
        ),
      ];

      for (var word in testWords) {
        await insertWord(word);
      }
    }
  }
}
