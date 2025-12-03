import 'package:my_dictionary/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import '../dbhelper.dart';

class EditWordPage extends StatefulWidget {
  const EditWordPage({super.key, this.id, this.isNew = false});

  final int? id;
  final bool isNew;

  @override
  State<EditWordPage> createState() => _EditWordPageState();
}

class _EditWordPageState extends State<EditWordPage> {
  final TextEditingController _wordController = TextEditingController();
  List<TextEditingController> _translationControllers = [];
  int _formState = 0; // 0 - view, 1 - edit
  String _createdAt = '';

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      DBHelper.instance.getWordById(widget.id!).then((word) {
        if (word != null) {
          _wordController.text = word.name;
          if (_formState == 0) {
            setState(() {
              _translationControllers = word.translations
                  .map(
                    (translation) => TextEditingController(
                      text: '${translation.name} (${translation.level})',
                    ),
                  )
                  .toList();
              _createdAt = 'created: ${word.createdAt}';
            });
          } else {
            setState(() {
              _translationControllers = word.translations
                  .map(
                    (translation) =>
                        TextEditingController(text: translation.name),
                  )
                  .toList();
              _createdAt = 'created: ${word.createdAt}';
            });
          }
        }
      });
    }
    if (widget.isNew) {
      _formState = 1;
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    for (var controller in _translationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void addTranslationField() {
    setState(() {
      _translationControllers.add(TextEditingController());
    });
  }

  void saveWord() async {
    // Checks
    if (_wordController.text.isEmpty) {
      // Show error
      return;
    }

    if (_translationControllers.isEmpty ||
        _translationControllers.any((controller) => controller.text.isEmpty)) {
      // Show error
      return;
    }

    Word? existWord = await DBHelper.instance.getWordByName(
      _wordController.text,
    );
    if (existWord != null && existWord.id != widget.id) {
      // Show error: word already exists
      return;
    }

    if (widget.id == null) {
      // Create new word
      Word newWord = Word(
        id: 0,
        name: _wordController.text,
        image: '',
        translations: _translationControllers
            .map(
              (controller) => Translation(
                id: 0,
                wordId: 0,
                name: controller.text,
                level: 0,
              ),
            )
            .toList(),
      );
      Word savedWord = await DBHelper.instance.insertWord(newWord);
      Provider.of<WordModel>(context, listen: false).addWord(savedWord);
    } else {
      // Update existing word
      final updatedWord = Word(
        id: widget.id!,
        name: _wordController.text,
        image: '',
        translations: _translationControllers
            .map(
              (controller) => Translation(
                id: 0,
                wordId: widget.id!,
                name: controller.text,
                level: 0,
              ),
            )
            .toList(),
      );
      await DBHelper.instance.updateWord(updatedWord);
      Provider.of<WordModel>(context, listen: false).updateWord(updatedWord);
    }
    Navigator.pop(context);
  }

  Future<dynamic> deleteWord() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Word"),
          content: const Text("Are you sure you want to delete this word?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                DBHelper.instance.deleteWord(widget.id!);
                Provider.of<WordModel>(
                  context,
                  listen: false,
                ).removeWord(widget.id!);
                Navigator.pop(context); // Go back after deletion
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Editor Page'),
        actions: _formState == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: deleteWord,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _formState = 1;
                    });
                  },
                ),
              ]
            : [IconButton(icon: const Icon(Icons.check), onPressed: saveWord)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _formState == 0
              ? [
                  Text(
                    _wordController.text,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: _translationControllers
                        .map(
                          (controller) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              controller.text,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  Text(_createdAt),
                ]
              : [
                  TextField(
                    controller: _wordController,
                    decoration: const InputDecoration(labelText: 'Word'),
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: addTranslationField,
                    child: const Text('Add Translation'),
                  ),
                  SizedBox(height: 16),
                  _translationControllers.isEmpty
                      ? Container()
                      : Column(
                          children: _translationControllers
                              .map(
                                (controller) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Translation',
                                    ),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              )
                              .toList(),
                        ), // Other UI elements can be added here
                ],
        ),
      ),
    );
  }
}
