import 'package:my_dictionary/dbhelper.dart';
import 'package:my_dictionary/model.dart';
import 'package:my_dictionary/pages/edit_word.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data.dart';

class WordList extends StatelessWidget {
  const WordList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Word List'),
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
              ).setWords(snapshot.data as List<Word>);
            });

            return Consumer<WordModel>(
              builder: (context, wordModel, child) {
                return ListView.separated(
                  itemCount: wordModel.words.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    Word item = wordModel.words[index];
                    return ListTile(
                      leading: Icon(Icons.wordpress),
                      title: Text(item.name),
                      onLongPress: () {
                        wordModel.setIndex(index);
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditWordPage(id: item.id),
                          ),
                        );
                      },
                      selected: index == wordModel.index,
                      selectedTileColor: Colors.deepOrange[50],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditWordPage(isNew: true),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
