import 'package:flutter/material.dart';
import 'package:my_dictionary/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:convert' show utf8;
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import 'package:my_dictionary/data/category.dart';
import 'package:my_dictionary/ui/dictionary_item.dart';
import 'package:my_dictionary/model.dart';
import 'package:my_dictionary/dbhelper.dart';
import 'package:my_dictionary/data/word.dart';

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

  void exportData() async {
    final words = await DBHelper.instance.getAllWords(category.id);
    List<List<String>> csvData = [
      ['name', 'translation', 'level'],
    ];
    for (var word in words) {
      csvData.add([word.name, word.translation, word.level.toString()]);
    }
    String csv = const ListToCsvConverter().convert(csvData);
    final data = Uint8List.fromList(utf8.encode(csv));

    if (!await FlutterFileDialog.isPickDirectorySupported()) {
      print("Picking directory not supported");
      return;
    }

    final pickedDirectory = await FlutterFileDialog.pickDirectory();

    if (pickedDirectory != null) {
      await FlutterFileDialog.saveFileToDirectory(
        directory: pickedDirectory,
        data: data,
        mimeType: "text/csv",
        fileName: "${category.name}.csv",
        replace: true,
      );
    }
    // final params = SaveFileDialogParams(
    //   sourceFilePath: null,
    //   data: data,
    //   fileName: '${category.name}.csv',
    // );
    // await FlutterFileDialog.saveFile(params: params);
  }

  Future<dynamic> importData(BuildContext context) async {
    final params = OpenFileDialogParams(
      dialogType: OpenFileDialogType.document,
      sourceType: SourceType.photoLibrary,
      fileExtensionsFilter: ['csv'],
      allowedUtiTypes: ['text/csv'],
    );
    final filePath = await FlutterFileDialog.pickFile(params: params);
    if (filePath != null) {
      try {
        final input = File(filePath).openRead();
        final csvData = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();
        for (var i = 1; i < csvData.length; i++) {
          var row = csvData[i];
          if (row.length >= 2) {
            String name = row[0].toString();
            String translation = row[1].toString();
            int level = row.length > 2
                ? int.tryParse(row[2].toString()) ?? 0
                : 0;
            final existWord = await DBHelper.instance.getWordByName(
              category.id,
              name,
            );
            if (existWord == null) {
              final Word newWord = Word(
                id: 0,
                category: category,
                name: name,
                translation: translation,
                level: level,
              );
              await DBHelper.instance.insertWord(newWord);
            }
          }
        }
        // Обновляем список слов после импорта
        final words = await DBHelper.instance.getAllWords(category.id);
        Provider.of<MyModel>(context, listen: false).setWords(words);
      } catch (e) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context)!.err_import),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.btn_close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    }
  }

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.only(top: 30.0),
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.file_download),
              title: Text(AppLocalizations.of(context)!.btn_export),
              onTap: () {
                Navigator.pop(context);
                exportData();
              },
            ),
            ListTile(
              leading: Icon(Icons.file_upload),
              title: Text(AppLocalizations.of(context)!.btn_import),
              onTap: () {
                Navigator.pop(context);
                importData(context);
              },
            ),
          ],
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
            return Center(
              child: Text(AppLocalizations.of(context)!.txt_no_data),
            );
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
