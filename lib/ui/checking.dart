import 'package:flutter/material.dart';
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
                    'На сегодня нет слов для проверки\nПожалуйста, добавьте новое слово в словарь',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: goBack,
                    child: const Text('Вернуться назад'),
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
                    // Текущее слово для перевода
                    Text(
                      words[currentIndex].name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Поле для ввода перевода
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
                      style: TextStyle(fontSize: 22),
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
                              'Следующий',
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
                              'Проверить',
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
                                      'Правильно!',
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
                                      'Неправильно!',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Правильный ответ: ${words[currentIndex].translation}',
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
    if (translate == word.translation.trim().toLowerCase()) {
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
