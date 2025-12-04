import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          seedColor: const Color.fromRGBO(37, 150, 190, 1),
          surface: Colors.white,
          secondary: const Color.fromRGBO(190, 224, 236, 1),
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.robotoSlab(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: GoogleFonts.robotoSlab(
            fontSize: 22,
            // fontWeight: FontWeight.bold,
          ),
          displaySmall: GoogleFonts.robotoSlab(),
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
        title: Text(
          'My Dictionary',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png"),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                fixedSize: Size(250, 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WordList()),
                );
              },
              child: Text(
                'Open Dictionary',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                fixedSize: Size(250, 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckPage()),
                );
              },
              child: Text(
                'Start leaning',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
