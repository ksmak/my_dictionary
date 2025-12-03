import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dbhelper.dart';
import 'model.dart';
import 'pages/word_list.dart';
import 'pages/check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.instance.initDb();
  await DBHelper.instance.initializeWords();
  runApp(
    ChangeNotifierProvider(create: (context) => WordModel(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Dictionary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(255, 87, 34, 1),
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Dictionary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WordList()),
                );
              },
              child: const Text('Edit words', style: TextStyle(fontSize: 24)),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckPage()),
                );
              },
              child: const Text('Start check', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
