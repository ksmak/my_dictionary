import 'package:flutter/material.dart';
import 'package:my_dictionary/data/category.dart';
import 'package:my_dictionary/data/word.dart';
import 'package:my_dictionary/dbhelper.dart';
import 'package:my_dictionary/model.dart';
import 'package:provider/provider.dart';

/// Экран для редактирования или создания слова.
///
/// Поддерживает два режима:
/// 1. Просмотр (только чтение)
/// 2. Редактирование (добавление/удаление переводов)
class DictionaryItemPage extends StatefulWidget {
  final Category category;
  final int? id; // ID слова для редактирования (null для нового)
  final bool isNew; // Флаг создания нового слова

  const DictionaryItemPage({
    super.key,
    required this.category,
    this.id,
    this.isNew = false,
  });

  @override
  State<DictionaryItemPage> createState() => _DictionaryItemPageState();
}

class _DictionaryItemPageState extends State<DictionaryItemPage> {
  String _word = '';
  String _translation = '';
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  int _formState = 0; // 0 - просмотр, 1 - редактирование
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Загружаем существующее слово если передан ID
    if (widget.id != null) {
      DBHelper.instance.getWordById(widget.id!).then((word) {
        if (word != null) {
          setState(() {
            _word = word.name;
            _translation = word.translation;
            _wordController.text = word.name;
            _translationController.text = word.translation;
            _errorMessage = '';
          });
        }
      });
    }
    // Новое слово сразу открываем в режиме редактирования
    if (widget.isNew) {
      setState(() {
        _formState = 1;
      });
    }
  }

  @override
  void dispose() {
    // Освобождаем все контроллеры
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  /// Метод для сохранения слова в БД (создает новое или обновляет существующее)
  void saveWord() async {
    // Валидация: слово не может быть пустым
    if (_wordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Ошибка! Слово не может быть пустым.';
      });
      return;
    }

    // Валидация: перевод не может быть пустым
    if (_translationController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Ошибка! Перевод не может быть пустым.';
      });
      return;
    }

    // Проверка на дубликаты слов
    Word? existWord = await DBHelper.instance.getWordByName(
      _wordController.text.trim().toLowerCase(),
    );

    if (existWord != null && existWord.id != widget.id) {
      setState(() {
        _errorMessage = 'Ошибка! Слово уже существует в словаре.';
      });
      return;
    }

    if (widget.id == null) {
      // СОЗДАНИЕ нового слова
      Word newWord = Word(
        id: 0,
        category: widget.category,
        name: _wordController.text.trim().toLowerCase(),
        translation: _translationController.text.trim().toLowerCase(),
      );
      Word savedWord = (await DBHelper.instance.insertWord(newWord)) as Word;
      // ignore: use_build_context_synchronously
      Provider.of<MyModel>(context, listen: false).addWord(savedWord);
    } else {
      // ОБНОВЛЕНИЕ существующего слова
      final updatedWord = Word(
        id: widget.id!,
        category: widget.category,
        name: _wordController.text.trim().toLowerCase(),
        translation: _translationController.text.trim().toLowerCase(),
      );
      await DBHelper.instance.updateWord(updatedWord);
      // ignore: use_build_context_synchronously
      Provider.of<MyModel>(context, listen: false).updateWord(updatedWord);
    }
    setState(() {
      _formState = 0;
    });
  }

  /// Показывает диалог подтверждения удаления слова
  Future<dynamic> deleteWord() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Удаление слова",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: const Text(
            "Удалить это слово?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Удалить", style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Удаляем слово из БД
                Navigator.of(context).pop();
                DBHelper.instance.deleteWord(widget.id!);
                Provider.of<MyModel>(
                  context,
                  listen: false,
                ).removeWord(widget.id!);
                // Возвращаемся на экран словаря
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          '',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
        // Меняем кнопки действий в зависимости от режима
        actions: _formState == 0
            ? [
                // РЕЖИМ ПРОСМОТРА: кнопки удаления и редактирования
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: deleteWord,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _formState = 1;
                      _errorMessage = '';
                    });
                  },
                ),
              ]
            : [
                // РЕЖИМ РЕДАКТИРОВАНИЯ: кнопки отмены и сохранения
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      _formState = 0;
                      _errorMessage = '';
                      // Восстанавливаем прежние значения
                      _wordController.text = _word;
                      _translationController.text = _translation;
                    });
                  },
                ),
                IconButton(icon: const Icon(Icons.check), onPressed: saveWord),
              ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onDoubleTap: () {
              setState(() {
                _formState = 1;
                _errorMessage = '';
              });
            },
            onLongPress: () {
              setState(() {
                _formState = 1;
                _errorMessage = '';
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _formState == 0
                  ? [
                      // РЕЖИМ ПРОСМОТРА
                      SizedBox(height: 12),
                      Text('Слово:', style: TextStyle(fontSize: 12)),
                      Text(
                        _wordController.text,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text('Перевод:', style: TextStyle(fontSize: 12)),
                      Text(
                        _translationController.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.id != null
                            ? 'Уровень знания слова: ${Provider.of<MyModel>(context, listen: false).words.firstWhere((word) => word.id == widget.id!).level}'
                            : 'Уровень знания слова: 0',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 20),
                    ]
                  : [
                      // РЕЖИМ РЕДАКТИРОВАНИЯ:
                      _errorMessage.isNotEmpty
                          ? Container(
                              alignment: Alignment.center,
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : Container(),
                      SizedBox(height: 10),
                      SizedBox(height: 20),
                      // Поле для ввода слова
                      TextField(
                        controller: _wordController,
                        decoration: const InputDecoration(labelText: 'Слово'),
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      // Поле для ввода перевода
                      TextField(
                        controller: _translationController,
                        decoration: const InputDecoration(labelText: 'Перевод'),
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
