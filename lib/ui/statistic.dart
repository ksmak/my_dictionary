import 'package:flutter/material.dart';
import 'package:my_dictionary/dbhelper.dart';

/// Экран статистики (заглушка).
/// Показывает количество выученных слов на разных уровнях.
class StatisticsPage extends StatelessWidget {
  final List<int> currentStats;
  const StatisticsPage({super.key, required this.currentStats});

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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Количество слов по уровням:',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: Colors.grey[300]!),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Уровень',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Количество',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'На сегодня',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      for (int level = 0; level <= 7; level++)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '$level',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${snapshot.data?['learned_count$level'] ?? 0}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            currentStats[level] == 0
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '+${currentStats[level]}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Выученных',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${snapshot.data?['learned_count_all'] ?? 0}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Container(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Нет данных'));
          }
        },
      ),
    );
  }
}
