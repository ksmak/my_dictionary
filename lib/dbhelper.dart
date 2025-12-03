import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'data.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._instance();
  static Database? _db;
  // A flag to control database recreation in debug mode
  static final bool _shouldRecreateDbInDebug = true;

  DBHelper._instance();

  Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'words.db');

    // Check if in debug mode and if a flag is set to recreate
    if (kDebugMode && _shouldRecreateDbInDebug) {
      await deleteDatabase(path);
    }

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE words(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          name TEXT NOT NULL, 
          image TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP          
        )
      ''');
    await db.execute('''
        CREATE TABLE translations(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          word_id INTEGER,
          name TEXT NOT NULL,
          level INTEGER DEFAULT 0,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (word_id) REFERENCES words (id) ON DELETE CASCADE
        );
      ''');
    await db.execute('''
        CREATE TRIGGER update_timestamp
        AFTER UPDATE ON translations
        FOR EACH ROW
        BEGIN
            UPDATE translations
            SET updated_at = CURRENT_TIMESTAMP
            WHERE id = OLD.id;
        END;
    ''');
  }

  Future<Word> insertWord(Word word) async {
    Database db = await instance.db;
    int wordId = await db.insert('words', {
      'name': word.name,
      'image': word.image,
    });
    for (var translation in word.translations) {
      await db.insert('translations', {
        'word_id': wordId,
        'name': translation.name,
      });
    }
    return await getWordById(wordId) as Word;
  }

  Future<Word?> getWordById(int id) async {
    Database db = await instance.db;
    List<Map<String, Object?>> maps = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      var wordMap = maps.first;
      final List<Map<String, Object?>> translationMaps = await db.query(
        'translations',
        where: 'word_id = ?',
        whereArgs: [wordMap['id']],
      );
      List<Translation> translations = translationMaps.map((translationMap) {
        return Translation(
          id: translationMap['id'] as int,
          wordId: translationMap['word_id'] as int,
          name: translationMap['name'] as String,
          level: translationMap['level'] as int,
          updateAt: translationMap['updated_at'] as String,
        );
      }).toList();

      return Word(
        id: wordMap['id'] as int,
        name: wordMap['name'] as String,
        image: wordMap['image'] as String,
        translations: translations,
        createdAt: wordMap['created_at'] as String,
      );
    }
    return null;
  }

  Future<Word?> getWordByName(String name) async {
    Database db = await instance.db;
    List<Map<String, Object?>> maps = await db.query(
      'words',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      var wordMap = maps.first;
      final List<Map<String, Object?>> translationMaps = await db.query(
        'translations',
        where: 'word_id = ?',
        whereArgs: [wordMap['id']],
      );
      List<Translation> translations = translationMaps.map((translationMap) {
        return Translation(
          id: translationMap['id'] as int,
          wordId: translationMap['word_id'] as int,
          name: translationMap['name'] as String,
          level: translationMap['level'] as int,
          updateAt: translationMap['updated_at'] as String,
        );
      }).toList();

      return Word(
        id: wordMap['id'] as int,
        name: wordMap['name'] as String,
        image: wordMap['image'] as String,
        translations: translations,
        createdAt: wordMap['created_at'] as String,
      );
    }
    return null;
  }

  Future<List<Word>> getAllWords() async {
    Database db = await instance.db;
    List<Word> words = [];
    List<Map<String, Object?>> maps = await db.rawQuery('''
      SELECT 
        w.id, 
        w.name, 
        w.image, 
        w.created_at, 
        t.id AS t_id, 
        t.name AS t_name, 
        t.level AS t_level,
        t.updated_at AS t_updated_at 
      FROM words w
      LEFT JOIN translations t ON w.id = t.word_id
      ORDER BY w.name ASC
    ''');

    for (var map in maps) {
      int wordId = map['id'] as int;
      Word? existingWord = words.firstWhere(
        (word) => word.id == wordId,
        orElse: () => Word(
          id: wordId,
          name: map['name'] as String,
          image: map['image'] as String,
          translations: [],
          createdAt: map['created_at'] as String,
        ),
      );

      if (!words.contains(existingWord)) {
        words.add(existingWord);
      }

      if (map['t_id'] != null) {
        existingWord.translations.add(
          Translation(
            id: map['t_id'] as int,
            wordId: wordId,
            name: map['t_name'] as String,
            level: map['t_level'] as int,
            updateAt: map['t_updated_at'] as String,
          ),
        );
      }
    }

    return words;
  }

  Future<void> updateWord(Word word) async {
    Database db = await instance.db;
    await db.update(
      'words',
      {'name': word.name, 'image': word.image},
      where: 'id = ?',
      whereArgs: [word.id],
    );
    await updateTranslations(word.id, word.translations);
  }

  Future<void> updateTranslationLevel(int id, int level) async {
    Database db = await instance.db;
    await db.update(
      'translations',
      {'level': level},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTranslations(
    int wordId,
    List<Translation> translations,
  ) async {
    Database db = await instance.db;
    await db.delete('translations', where: 'word_id = ?', whereArgs: [wordId]);

    for (var translation in translations) {
      await db.insert('translations', {
        'word_id': wordId,
        'name': translation.name,
        'level': translation.level,
      });
    }
  }

  Future<void> deleteWord(int id) async {
    Database db = await instance.db;
    await db.delete('translations', where: 'word_id = ?', whereArgs: [id]);
    await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    Database db = await instance.db;
    db.close();
  }

  Future<void> initializeWords() async {
    List<Word> words = [
      Word(
        id: 0,
        name: 'apple',
        image: '',
        translations: [Translation(id: 0, wordId: 0, name: 'яблоко', level: 0)],
      ),
      Word(
        id: 0,
        name: 'banana',
        image: '',
        translations: [Translation(id: 0, wordId: 0, name: 'банан', level: 0)],
      ),
      Word(
        id: 0,
        name: 'orange',
        image: '',
        translations: [
          Translation(id: 0, wordId: 0, name: 'апельсин', level: 0),
        ],
      ),
      Word(
        id: 0,
        name: 'grape',
        image: '',
        translations: [
          Translation(id: 0, wordId: 0, name: 'виноград', level: 0),
        ],
      ),
      Word(
        id: 0,
        name: 'pear',
        image: '',
        translations: [Translation(id: 0, wordId: 0, name: 'груша', level: 0)],
      ),
    ];

    for (var word in words) {
      await insertWord(word);
    }
  }
}
