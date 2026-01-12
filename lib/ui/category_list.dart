import 'package:flutter/material.dart';
import 'package:my_dictionary/model.dart';
import 'package:my_dictionary/ui/category_item.dart';
import 'package:provider/provider.dart';

import 'checking.dart';
import '../data/category.dart';
import 'dictionary_list.dart';
import '../dbhelper.dart';

/// Экран для показа списка категорий.
///
/// Режим - 1.
/// Возможность редактирования категории слов. а также добавление новых слов в эту категорию.
/// При нажатии на категорию открывается следующий экран для редактирования слов в категории.
/// Режим - 2.
/// Возможность тестирования слов в категории. При нажатии на категорию открывается экран
/// тестирования слов.

class CategoryListPage extends StatelessWidget {
  final int mode; // режим: 1 - редактирование, 2 - тестирование

  const CategoryListPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Категории',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        // Загружаем все категории при открытии экрана
        future: DBHelper.instance.getAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // После загрузки категорий инициализируем модель
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<MyModel>(
                context,
                listen: false,
              ).setCategories(snapshot.data as List<Category>);
            });

            return Consumer<MyModel>(
              builder: (context, myModel, child) {
                // Показываем список категорий
                return ListView.separated(
                  itemCount: myModel.categories.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    Category item = myModel.categories[index];
                    return ListTile(
                      leading: Icon(
                        Icons.category,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(item.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: mode == 1
                            ? [
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    // Удаляем категорию
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            "Удаление категории",
                                          ),
                                          content: const Text(
                                            "Вы уверены, что хотите удалить эту категорию?",
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text("Отмена"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text("Удалить"),
                                              onPressed: () {
                                                // Удаляем категорию из БД
                                                Navigator.of(context).pop();
                                                DBHelper.instance
                                                    .deleteCategory(item.id);
                                                Provider.of<MyModel>(
                                                  context,
                                                  listen: false,
                                                ).removeCategory(item.id);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.open_in_browser,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    // Редактируем категорию
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CategoryItemPage(
                                          isNew: false,
                                          id: item.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ]
                            : [],
                      ),
                      onTap: mode == 1
                          ? () {
                              // Открываем экран словаря для редактирования слов в категории
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DictionaryListPage(
                                    categories: myModel.categories,
                                    category: item,
                                  ),
                                ),
                              );
                            }
                          : () {
                              // Режим тестирования - открываем экран проверки слов
                              Provider.of<MyModel>(
                                context,
                                listen: false,
                              ).setCategoryIndex(index);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CheckingPage(categoryId: item.id),
                                ),
                              );
                            },
                      selected: index == myModel.categoryIndex,
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
      floatingActionButton: mode == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryItemPage(isNew: true),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
