import 'package:flutter/material.dart';
import 'package:my_dictionary/dbhelper.dart';

/// Экран статистики (заглушка).
/// Показывает количество выученных слов на разных уровнях.
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Статистика',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: DBHelper.instance.getLearningStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Text('''
                    Уровень-0:\t${snapshot.data?['learned_count0'] ?? 0}\n       
                    Уровень-1:\t${snapshot.data?['learned_count1'] ?? 0}\n
                    Уровень-2:\t${snapshot.data?['learned_count2'] ?? 0}\n
                    Уровень-3:\t${snapshot.data?['learned_count3'] ?? 0}\n
                    Уровень-4:\t${snapshot.data?['learned_count4'] ?? 0}\n
                    Уровень-5:\t${snapshot.data?['learned_count5'] ?? 0}\n
                    Уровень-6:\t${snapshot.data?['learned_count6'] ?? 0}\n
                    Уровень-7:\t${snapshot.data?['learned_count7'] ?? 0}\n
                    Полностью выученные слова:\t${snapshot.data?['learned_count_all'] ?? 0}\n
                    ''', style: const TextStyle(fontSize: 12)),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Вернуться назад',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Нет данных'));
          }
        },
      ),
    );
  }
}
