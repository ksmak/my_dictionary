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
  static const bool _shouldRecreateDbInDebug = false;
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
          name TEXT NOT NULL,
          translation TEXT NOT NULL,
          level INTEGER DEFAULT 0,
          update_at DATETIME DEFAULT CURRENT_TIMESTAMP,
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
      'level': word.level,
      'update_at': word.updateAt,
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
        'level': word.level,
        'update_at': word.updateAt,
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

  /// Получает список слов из БД
  Future<List<Word>> getAllWords(int categoryId) async {
    final db = await this.db;

    final category = await getCategoryById(categoryId);

    if (category == null) {
      return [];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Word(
        id: maps[i]['id'],
        category: category,
        name: maps[i]['name'],
        translation: maps[i]['translation'],
        level: maps[i]['level'],
        updateAt: maps[i]['update_at'],
        createdAt: maps[i]['created_at'],
      );
    });
  }

  /// Получает отфильтрованный список слов из БД
  Future<List<Word>> getFilteredWords(Category category) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: '''
        category_id = ? AND (
          level < 2 OR
          (level == 2 AND update_at <= datetime('now', '-1 day')) OR
          (level == 3 AND update_at <= datetime('now', '-3 day')) OR
          (level == 4 AND update_at <= datetime('now', '-7 days')) OR
          (level == 5 AND update_at <= datetime('now', '-14 days')) OR
          (level == 6 AND update_at <= datetime('now', '-30 days')) OR
          (level == 7 AND update_at <= datetime('now', '-90 days'))
        )
      ''',
      whereArgs: [category.id],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Word(
        id: maps[i]['id'],
        category: category,
        name: maps[i]['name'],
        translation: maps[i]['translation'],
        level: maps[i]['level'],
        updateAt: maps[i]['update_at'],
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

    if (maps.isNotEmpty) {
      final category = await getCategoryById(maps[0]['category_id']);

      return Word(
        id: maps[0]['id'],
        category: category!,
        name: maps[0]['name'],
        translation: maps[0]['translation'],
        level: maps[0]['level'],
        updateAt: maps[0]['update_at'],
        createdAt: maps[0]['created_at'],
      );
    }
    return null;
  }

  /// Получает слово по наименованию
  Future<Word?> getWordByName(int categoryId, String name) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'category_id = ? AND name = ?',
      whereArgs: [categoryId, name],
    );

    if (maps.isNotEmpty) {
      final category = await getCategoryById(maps[0]['category_id']);

      return Word(
        id: maps[0]['id'],
        category: category!,
        name: maps[0]['name'],
        translation: maps[0]['translation'],
        level: maps[0]['level'],
        updateAt: maps[0]['update_at'],
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
        SUM(CASE WHEN level == 0 THEN 1 ELSE 0 END) AS learned_count0,
        SUM(CASE WHEN level == 1 THEN 1 ELSE 0 END) AS learned_count1,
        SUM(CASE WHEN level == 2 THEN 1 ELSE 0 END) AS learned_count2,
        SUM(CASE WHEN level == 3 THEN 1 ELSE 0 END) AS learned_count3,
        SUM(CASE WHEN level == 4 THEN 1 ELSE 0 END) AS learned_count4,
        SUM(CASE WHEN level == 5 THEN 1 ELSE 0 END) AS learned_count5,
        SUM(CASE WHEN level == 6 THEN 1 ELSE 0 END) AS learned_count6,
        SUM(CASE WHEN level == 7 THEN 1 ELSE 0 END) AS learned_count7,
        SUM(CASE WHEN level > 7 THEN 1 ELSE 0 END) AS learned_count_all
      FROM words
    ''');
    return result.isNotEmpty
        ? result[0].map((key, value) => MapEntry(key, value as int))
        : {};
  }

  /// Обновляет уровень знания слова
  Future<void> updateLevel(int wordId, int newLevel) async {
    final db = await this.db;
    await db.update(
      'words',
      {'level': newLevel, 'update_at': DateTime.now().toIso8601String()},
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
      Category testCategory1 = await insertCategory('Test Category1');

      // Вставляем тестовые слова
      List<Word> testWords1 = [
        Word(
          id: 0,
          category: testCategory1,
          name: 'hello',
          translation: 'привет',
        ),
        Word(id: 0, category: testCategory1, name: 'world', translation: 'мир'),
        Word(
          id: 0,
          category: testCategory1,
          name: 'computer',
          translation: 'компьютер',
        ),
        Word(
          id: 0,
          category: testCategory1,
          name: 'language',
          translation: 'язык',
        ),
        Word(
          id: 0,
          category: testCategory1,
          name: 'flutter',
          translation: 'флаттер',
        ),
      ];

      for (var word in testWords1) {
        await insertWord(word);
      }

      // Создаем тестовую категорию
      Category testCategory2 = await insertCategory('Test Category2');

      // Вставляем тестовые слова
      List<Word> testWords2 = [
        Word(
          id: 0,
          category: testCategory2,
          name: 'hello',
          translation: 'привет',
        ),
        Word(id: 0, category: testCategory2, name: 'world', translation: 'мир'),
        Word(
          id: 0,
          category: testCategory2,
          name: 'computer',
          translation: 'компьютер',
        ),
        Word(
          id: 0,
          category: testCategory2,
          name: 'language',
          translation: 'язык',
        ),
        Word(
          id: 0,
          category: testCategory2,
          name: 'flutter',
          translation: 'флаттер',
        ),
      ];

      for (var word in testWords2) {
        await insertWord(word);
      }
    }
  }
}
