import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'dbhelper.dart';
import 'model.dart';
import 'ui/category_list.dart';

// Главная функция приложения
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Обязательная инициализация Flutter
  await DBHelper.instance.populateTestData(); // Загружаем тестовые слова в БД
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          MyModel(), // Провайдер для управления состоянием слов
      child: MyApp(),
    ),
  );
}

// Основной виджет приложения
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
          secondary: const Color.fromRGBO(190, 224, 236, 1), // Цвет кнопок
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.robotoSlab(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ), // Заголовки
          bodyMedium: GoogleFonts.robotoSlab(fontSize: 20), // Текст кнопок
        ),
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('ru'), // Russion
      ],
      home: MainPage(), // Стартовый экран
    );
  }
}

// Главный экран с навигацией
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          AppLocalizations.of(context)!.app_title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png"), // Логотип приложения
            SizedBox(height: 30),
            // Кнопка перехода к словарю
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                fixedSize: Size(250, 15),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryListPage(mode: 1),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.btn_open_dict,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: 40),
            // Кнопка начала обучения
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                fixedSize: Size(250, 15),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryListPage(mode: 2),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.btn_lean_words,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
