import 'package:flutter/material.dart';
import 'package:my_dictionary/l10n/app_localizations.dart';

import 'package:my_dictionary/ui/statistic.dart';
import 'package:my_dictionary/data/category.dart';
import 'package:my_dictionary/data/word.dart';
import 'package:my_dictionary/dbhelper.dart';

/// Экран для проверки знаний слов.
///
/// Пользователь видит слово и вводит перевод для проверки.
/// Система показывает результат и обновляет уровень знания слова.
class CheckingPage extends StatefulWidget {
  final Category category;

  const CheckingPage({super.key, required this.category});

  @override
  State<CheckingPage> createState() => _CheckingPageState();
}

class _CheckingPageState extends State<CheckingPage> {
  List<Word> words = [];
  int currentIndex = 0;
  List<int> stats = List.filled(8, 0);

  final _translationController = TextEditingController();
  final _succesController = TextEditingController();
  final _failureController = TextEditingController();
  final _rightAnswerController = TextEditingController();

  bool loading = true;

  //флаг проверки
  bool _isChecked = false;

  //флаг правильного ответа
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    // Загружаем слова из выбранной категории
    DBHelper.instance.getFilteredWords(widget.category).then((loadedWords) {
      setState(() {
        loading = false;
        loadedWords.shuffle();
        words = loadedWords;
        currentIndex = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : words.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.txt_today_no_words,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: goBack,
                    child: Text(AppLocalizations.of(context)!.btn_back),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      words[currentIndex].translation.splitMapJoin(
                        ';',
                        onNonMatch: (s) => s.trim(),
                        onMatch: (s) => '\n',
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _translationController,
                      decoration: const InputDecoration(
                        helper: Center(
                          child: Text('', style: TextStyle(fontSize: 10)),
                        ),
                        alignLabelWithHint: true,
                      ),
                      textAlign: TextAlign.center,
                      autofocus: true, // Автофокус для быстрого ввода
                      style: TextStyle(fontSize: 18),
                      onSubmitted: (value) => checkTranslation(
                        words[currentIndex],
                        _translationController.text,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Кнопка проверки
                    _isChecked
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              fixedSize: Size(200, 15),
                            ),
                            onPressed: () {
                              nextWord(currentIndex + 1, words.length - 1);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.btn_next,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              fixedSize: Size(200, 15),
                            ),
                            onPressed: () {
                              checkTranslation(
                                words[currentIndex],
                                _translationController.text,
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.btn_check,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                    SizedBox(height: 30),
                    // Область для сообщений (правильно/неправильно)
                    _isChecked
                        ? _isCorrect
                              ? Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.txt_right,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.txt_wrong,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${AppLocalizations.of(context)!.txt_answer} ${words[currentIndex].name}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )
                        : Container(),
                  ],
                ),
              ),
            ),
    );
  }

  /// Метод для проверки правильности перевода
  void checkTranslation(Word word, String translation) async {
    String translate = _translationController.text.trim().toLowerCase();
    if (translate == word.name.trim().toLowerCase()) {
      // Увеличиваем уровень
      await DBHelper.instance.updateLevel(word.id, word.level + 1);
      setState(() {
        _isChecked = true;
        _isCorrect = true;
      });
      stats[word.level + 1]++;
    } else {
      setState(() {
        _isChecked = true;
        _isCorrect = false;
      });
    }
  }

  // Метод для показа следующего слова для проверки
  // если это последнее слово, то переходим на экран статистики
  void nextWord(int ind, int len) {
    if (ind > len) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StatisticsPage(currentStats: stats),
        ),
      );
      return;
    }
    // Сбрасываем поле ввода и сообщение
    _translationController.text = "";
    currentIndex = ind;
    setState(() {
      _isChecked = false;
      _isCorrect = false;
    });
  }

  // Метод для возрата в начальный экран
  void goBack() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _translationController.dispose();
    _succesController.dispose();
    _failureController.dispose();
    _rightAnswerController.dispose();
    super.dispose();
  }
}
