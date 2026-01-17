import 'package:flutter/material.dart';
import 'package:my_dictionary/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:my_dictionary/data/category.dart';
import 'package:my_dictionary/data/word.dart';
import 'package:my_dictionary/dbhelper.dart';
import 'package:my_dictionary/model.dart';

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
  int? _id;
  Word? _word;
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
            _id = widget.id!;
            _word = word;
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
        _errorMessage = AppLocalizations.of(context)!.err_word_no_empty;
      });
      return;
    }

    // Валидация: перевод не может быть пустым
    if (_translationController.text.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.err_trans_no_empty;
      });
      return;
    }

    // Проверка на дубликаты слов
    Word? existWord = await DBHelper.instance.getWordByName(
      widget.category.id,
      _wordController.text.trim().toLowerCase(),
    );

    if (existWord != null && existWord.id != _id) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.err_word_exists;
      });
      return;
    }

    if (_id == null && _word == null) {
      // СОЗДАНИЕ нового слова
      Word newWord = Word(
        id: 0,
        category: widget.category,
        name: _wordController.text.trim().toLowerCase(),
        translation: _translationController.text.trim().toLowerCase(),
      );
      Word savedWord = (await DBHelper.instance.insertWord(newWord)) as Word;
      _id = savedWord.id;
      _word = savedWord;
      // ignore: use_build_context_synchronously
      Provider.of<MyModel>(context, listen: false).addWord(savedWord);
    } else {
      // ОБНОВЛЕНИЕ существующего слова
      Word updatedWord = Word(
        id: _word!.id,
        category: _word!.category,
        name: _wordController.text.trim().toLowerCase(),
        translation: _translationController.text.trim().toLowerCase(),
        level: _word!.level,
        updateAt: _word!.updateAt,
        createdAt: _word!.createdAt,
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
          title: Text(
            AppLocalizations.of(context)!.txt_delete_word,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.txt_ask_delete_word,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.btn_cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.btn_delete,
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                // Удаляем слово из БД
                DBHelper.instance.deleteWord(_id!);
                Provider.of<MyModel>(context, listen: false).removeWord(_id!);
                Navigator.pop(context);
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
                      _wordController.text = _word?.name ?? '';
                      _translationController.text = _word?.translation ?? '';
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
                      Text(
                        AppLocalizations.of(context)!.txt_word,
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        _wordController.text,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.txt_trans,
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        _translationController.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _id != null
                            ? '${AppLocalizations.of(context)!.txt_level}: ${Provider.of<MyModel>(context, listen: false).words.firstWhere((word) => word.id == _id!).level}'
                            : '${AppLocalizations.of(context)!.txt_level}: 0',
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
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.txt_word,
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      // Поле для ввода перевода
                      TextField(
                        controller: _translationController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.txt_trans,
                        ),
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
