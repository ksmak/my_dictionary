import 'package:my_dictionary/model.dart';
import 'package:flutter/material.dart';
import 'package:my_dictionary/ui/statistic.dart';
import 'package:provider/provider.dart';
import '../data/word.dart';
import '../dbhelper.dart';

/// Экран для проверки знаний слов.
///
/// Пользователь видит слово и вводит перевод для проверки.
/// Система показывает результат и обновляет уровень знания слова.
class CheckingPage extends StatelessWidget {
  final int categoryId;

  const CheckingPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: DBHelper.instance.getFilteredWords(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Загрузили слова → показываем интерфейс проверки
            return _WordListContent(words: snapshot.data as List<Word>);
          } else {
            return Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}

/// Виджет для проверки перевода конкретного слова.
class _WordListContent extends StatefulWidget {
  final List<Word> words;

  const _WordListContent({required this.words});

  @override
  _WordListContentState createState() => _WordListContentState();
}

class _WordListContentState extends State<_WordListContent> {
  final _translationController = TextEditingController();
  final _succesController = TextEditingController();
  final _failureController = TextEditingController();
  final _rightAnswerController = TextEditingController();

  //флаг проверки
  bool _isChecked = false;

  //флаг правильного ответа
  int _isCorrect = 0;

  /// Метод для проверки правильности перевода
  void checkTranslation(Word word, String translation) async {
    String translate = _translationController.text.trim().toLowerCase();
    if (word.testType == 1) {
      if (translate == word.translation.trim().toLowerCase()) {
        // Увеличиваем уровень
        await DBHelper.instance.updateNameLevel(word.id, word.nameLevel + 1);
        setState(() {
          _isCorrect = 1;
        });
      } else {
        setState(() {
          _isCorrect = -1;
        });
      }
    } else {
      if (translate == word.name.trim().toLowerCase()) {
        // Увеличиваем уровень
        await DBHelper.instance.updateTranslationLevel(
          word.id,
          word.translationLevel + 1,
        );
        setState(() {
          _isCorrect = 1;
        });
      } else {
        setState(() {
          _isCorrect = -1;
        });
      }
    }
    setState(() {
      _isChecked = true;
    });
  }

  // Метод для показа следующего слова для проверки
  // если это последнее слово, то переходим на экран статистики
  void nextWord(int ind, int len) {
    if (ind > len) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StatisticsPage()),
      );
      return;
    }
    // Сбрасываем поле ввода и сообщение
    _translationController.text = "";
    Provider.of<MyModel>(context, listen: false).setWordIndex(ind);
    setState(() {
      _isChecked = false;
      _isCorrect = 0;
    });
  }

  // Метод для возрата в начальный экран
  void goBack() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    Provider.of<MyModel>(context, listen: false).setWords(widget.words);
    Provider.of<MyModel>(context, listen: false).setWordIndex(0);
    // Сбрасываем поле ввода и сообщение
    _translationController.text = "";
  }

  @override
  void dispose() {
    _translationController.dispose();
    _succesController.dispose();
    _failureController.dispose();
    _rightAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyModel>(
      builder: (context, wordModel, child) {
        // Если нет слов для проверки - пустой контейнер
        if (wordModel.words.isEmpty || wordModel.wordIndex == -1) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Нет слов для проверки\nПожалуйста, добавьте новое слово в словарь',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: goBack,
                  child: const Text('Вернуться назад'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                // Текущее слово для перевода
                Text(
                  wordModel.words[wordModel.wordIndex].testType == 1
                      ? wordModel.words[wordModel.wordIndex].name
                      : wordModel.words[wordModel.wordIndex].translation,
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
                    wordModel.words[wordModel.wordIndex],
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
                          nextWord(
                            wordModel.wordIndex + 1,
                            wordModel.words.length - 1,
                          );
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
                            wordModel.words[wordModel.wordIndex],
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
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: _isCorrect == 1
                        ? [
                            Text(
                              'Правильно!',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ]
                        : _isCorrect == -1
                        ? [
                            Text(
                              'Неправильно!',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              wordModel.words[wordModel.wordIndex].testType == 1
                                  ? wordModel
                                        .words[wordModel.wordIndex]
                                        .translation
                                  : wordModel.words[wordModel.wordIndex].name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ]
                        : [],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
