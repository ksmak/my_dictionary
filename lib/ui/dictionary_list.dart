import 'package:flutter/material.dart';
import 'package:my_dictionary/data/category.dart';
import 'package:my_dictionary/ui/dictionary_item.dart';
import 'package:provider/provider.dart';

import '/model.dart';
import '/dbhelper.dart';
import '../data/word.dart';

/// Экран для показа списка слов.
///
/// Позволяет:
/// 1. Просматривать все слова
/// 2. Открывать слово для просмотра/редактирования
/// 3. Добавлять новые слова (через FAB)
/// 4. Видеть новые слова (иконка "new")
class DictionaryListPage extends StatelessWidget {
  final Category category;

  const DictionaryListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          category.name,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        // Загружаем все слова при открытии экрана
        future: DBHelper.instance.getAllWords(category.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // После загрузки слов инициализируем модель
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<MyModel>(
                context,
                listen: false,
              ).setWords(snapshot.data as List<Word>);
            });

            return Consumer<MyModel>(
              builder: (context, myModel, child) {
                // Показываем список слов
                return ListView.separated(
                  itemCount: myModel.words.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    Word item = myModel.words[index];
                    return ListTile(
                      leading: Icon(Icons.wordpress),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        item.translation,
                        style: TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: myModel.words[index].level == 0
                          ? Image.asset("assets/images/new.png")
                          : null,
                      onTap: () {
                        // Открываем экран редактирования при тапе
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DictionaryItemPage(
                              category: category,
                              id: item.id,
                            ),
                          ),
                        );
                      },
                      selected: index == myModel.wordIndex,
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: Text('Нет данных'));
          }
        },
      ),
      // Кнопка для добавления нового слова
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DictionaryItemPage(category: category, isNew: true),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
