import 'package:my_dictionary/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import '../dbhelper.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  final _translationController = TextEditingController();
  final _messageController = TextEditingController();

  void checkTranslation(Word word, String translation) async {
    Translation? findTranslation;
    try {
      findTranslation = word.translations.firstWhere(
        (t) =>
            t.name.trim().toLowerCase() == translation.trim().toLowerCase() &&
            t.level < 11,
      );
    } catch (e) {
      findTranslation = null;
    }
    if (findTranslation != null) {
      Provider.of<WordModel>(context, listen: false).setMessage('Correct!');
      await DBHelper.instance.updateTranslationLevel(
        word.id,
        findTranslation.level + 1,
      );
    } else {
      var msg = 'Incorrect!\nCorrect translations:\n';
      for (var t in word.translations) {
        msg += '- ${t.name}\n';
      }
      Provider.of<WordModel>(context, listen: false).setMessage(msg);
    }
  }

  void goToStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _translationController.text = "";
    _messageController.text = "";
  }

  @override
  void dispose() {
    _translationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change to your desired color
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          '',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.stacked_line_chart),
            onPressed: goToStatistics,
          ),
        ],
      ),
      body: FutureBuilder(
        future: DBHelper.instance.getAllWords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<WordModel>(
                context,
                listen: false,
              ).setFilteredWords(snapshot.data as List<Word>);
              Provider.of<WordModel>(context, listen: false).setIndex(0);
              Provider.of<WordModel>(context, listen: false).setMessage('');
            });
            return Consumer<WordModel>(
              builder: (context, wordModel, child) {
                return (wordModel.words.isEmpty && wordModel.index == -1)
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              wordModel.words[wordModel.index].name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _translationController,
                              decoration: const InputDecoration(
                                helper: Center(
                                  child: Text(
                                    'Enter translation',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                                alignLabelWithHint: true,
                              ),
                              textAlign: TextAlign.center,
                              autofocus: true,
                              style: TextStyle(fontSize: 24),
                              onSubmitted: (value) => checkTranslation(
                                wordModel.words[wordModel.index],
                                _translationController.text,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              child: const Text('Check'),
                              onPressed: () {
                                checkTranslation(
                                  wordModel.words[wordModel.index],
                                  _translationController.text,
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                wordModel.message,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      );
              },
            );
          } else {
            return Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Statistics'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
