import 'package:my_dictionary/data.dart';
import 'package:flutter/material.dart';

class WordModel extends ChangeNotifier {
  //
  List<Word> words = [];
  int index = -1;
  String message = '';

  void setWords(List<Word> newWords) {
    words = newWords;
    notifyListeners();
  }

  void setFilteredWords(List<Word> newWords) {
    words.clear();
    for (var word in newWords) {
      List<Translation> translations = word.translations
          .where(
            (t) =>
                (t.level == 0) ||
                (t.level == 1 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inHours >
                        1) ||
                (t.level == 2 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inHours >
                        3) ||
                (t.level == 3 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inHours >
                        6) ||
                (t.level == 4 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inHours >
                        12) ||
                (t.level == 5 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inDays >
                        1) ||
                (t.level == 6 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inDays >
                        3) ||
                (t.level == 7 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inDays >
                        7) ||
                (t.level == 8 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inDays >
                        14) ||
                (t.level == 9 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inDays >
                        30) ||
                (t.level == 10 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inDays >
                        90) ||
                (t.level == 11 &&
                    DateTime.now()
                            .difference(DateTime.parse(t.updateAt))
                            .inDays >
                        180),
          )
          .toList();
      if (translations.isNotEmpty) {
        words.add(word);
      }
    }
    notifyListeners();
  }

  void updateWord(Word updatedWord) {
    int index = words.indexWhere((word) => word.id == updatedWord.id);
    if (index != -1) {
      words[index] = updatedWord;
      notifyListeners();
    }
  }

  void addWord(Word newWord) {
    words.add(newWord);
    notifyListeners();
  }

  void removeWord(int id) {
    words.removeWhere((word) => word.id == id);
    notifyListeners();
  }

  void setIndex(int newIndex) {
    index = newIndex;
    notifyListeners();
  }

  void setMessage(String newMessage) {
    message = newMessage;
    notifyListeners();
  }
}
