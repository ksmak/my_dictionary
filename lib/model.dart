import 'package:my_dictionary/data/category.dart';
import 'package:my_dictionary/data/word.dart';
import 'package:flutter/material.dart';

class MyModel extends ChangeNotifier {
  // Приватные поле для инкапсуляции состояния
  List<Category> _categories = []; // список категорий
  List<Word> _words = []; // список слов
  int _categoryIndex = -1; // текущий индекс категории
  int _wordIndex = -1; // текущий индекс слова
  String _message = ''; // сообщение

  // Публичные геттеры для доступа
  List<Word> get words => List.unmodifiable(_words);
  List<Category> get categories => List.unmodifiable(_categories);
  int get categoryIndex => _categoryIndex;
  int get wordIndex => _wordIndex;
  String get message => _message;

  // метод для загрузки списка категорий
  void setCategories(List<Category> newCategories) {
    _categories.clear();
    _categories = newCategories;
    if (_categories.isNotEmpty) {
      _categoryIndex = 0;
    } else {
      _categoryIndex = -1;
    }
    notifyListeners();
  }

  // метод добавления новой категории
  void addCategory(Category newCategory) {
    _categories.add(newCategory);
    notifyListeners();
  }

  // метод удаления категории по id
  void removeCategory(int id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }

  // method обновления категории
  void updateCategory(Category updatedCategory) {
    int index = _categories.indexWhere(
      (category) => category.id == updatedCategory.id,
    );
    if (index != -1) {
      _categories[index] = updatedCategory;
      notifyListeners();
    }
  }

  // метод для загрузки списка слов (для показа словаря)
  void setWords(List<Word> newWords) {
    _words.clear();
    _words = newWords;
    if (_words.isNotEmpty) {
      _wordIndex = 0;
    } else {
      _wordIndex = -1;
    }
    notifyListeners();
  }

  // метод обновляет слово в списке
  void updateWord(Word updatedWord) {
    int index = _words.indexWhere((word) => word.id == updatedWord.id);
    if (index != -1) {
      _words[index] = updatedWord;
      notifyListeners();
    }
  }

  // метод добавляет новое слово в список
  void addWord(Word newWord) {
    _words.add(newWord);
    notifyListeners();
  }

  // метод удаляет слово из списка по id
  void removeWord(int id) {
    _words.removeWhere((word) => word.id == id);
    notifyListeners();
  }

  // метод устанавливает текущий индекс категории
  void setCategoryIndex(int newIndex) {
    _categoryIndex = newIndex;
    notifyListeners();
  }

  // метод устанавливает текущий индекс слова
  void setWordIndex(int newIndex) {
    _wordIndex = newIndex;
    notifyListeners();
  }

  // метод устанавливает сообщение
  void setMessage(String newMessage) {
    _message = newMessage;
    notifyListeners();
  }
}
