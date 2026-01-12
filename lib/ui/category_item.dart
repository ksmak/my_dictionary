import 'package:flutter/material.dart';
import 'package:my_dictionary/data/category.dart';
import 'package:my_dictionary/dbhelper.dart';
import 'package:my_dictionary/model.dart';
import 'package:provider/provider.dart';

/// Экран для редактирования или создания категории.
///
/// Поддерживает два режима:
/// 1. Просмотр (только чтение)
/// 2. Редактирование (добавление/удаление переводов)
class CategoryItemPage extends StatefulWidget {
  final int? id; // ID категории для редактирования (null для новой)
  final bool isNew; // Флаг создания новой категории

  const CategoryItemPage({super.key, this.id, this.isNew = false});

  @override
  State<CategoryItemPage> createState() => _CategoryItemPageState();
}

class _CategoryItemPageState extends State<CategoryItemPage> {
  String _category = '';
  final TextEditingController _categoryController = TextEditingController();
  int _formState = 0; // 0 - просмотр, 1 - редактирование
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Загружаем существующее слово если передан ID
    if (widget.id != null) {
      DBHelper.instance.getCategoryById(widget.id!).then((category) {
        if (category != null) {
          setState(() {
            _category = category.name;
            _categoryController.text = category.name;
          });
        }
      });
    }

    // Новая категория сразу открываем в режиме редактирования
    if (widget.isNew) {
      setState(() {
        _formState = 1;
      });
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  /// Метод для сохранения категории
  void saveCategory() async {
    final String categoryName = _categoryController.text.trim().toLowerCase();

    // Валидация: категория не может быть пустой
    if (categoryName.isEmpty) {
      setState(() {
        _errorMessage = 'Ошибка! Категория не может быть пустой.';
      });
      return;
    }

    // Проверка на дубликаты категорий
    Category? existCategory = await DBHelper.instance.getCategoryByName(
      categoryName,
    );
    if (existCategory != null && existCategory.id != widget.id) {
      setState(() {
        _errorMessage = 'Ошибка! Категория уже существует в словаре.';
      });
      return;
    }

    if (widget.id == null) {
      // СОЗДАНИЕ новой категории
      Category savedCategory = await DBHelper.instance.insertCategory(
        categoryName,
      );
      Provider.of<MyModel>(context, listen: false).addCategory(savedCategory);
    } else {
      // ОБНОВЛЕНИЕ существующей категории
      Category updatedCategory = await DBHelper.instance.updateCategory(
        widget.id!,
        categoryName,
      );
      Provider.of<MyModel>(
        context,
        listen: false,
      ).updateCategory(updatedCategory);
    }
    setState(() {
      _formState = 0;
      _category = categoryName;
    });
  }

  /// Показывает диалог подтверждения удаления категории
  Future<dynamic> deleteCategory() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // Удаляем категорию
        return AlertDialog(
          title: const Text(
            "Удаление категории",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: const Text(
            "Все слова в этой категории также будут удалены. Продолжить?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Удалить", style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Удаляем категорию из БД
                DBHelper.instance.deleteCategory(widget.id!);
                Provider.of<MyModel>(
                  context,
                  listen: false,
                ).removeCategory(widget.id!);
                Navigator.of(context).pop();
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
                  onPressed: deleteCategory,
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
                      _categoryController.text = _category;
                      _errorMessage = '';
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: saveCategory,
                ),
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
                      SizedBox(height: 10),
                      Text(
                        _categoryController.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                      // Поле для ввода категории
                      TextField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Категория',
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
