import 'package:flutter/material.dart';
import 'package:pocket_fit/pages/main_navigation.dart';

void main() {
  runApp(const PocketFitApp());
}

class PocketFitApp extends StatelessWidget {
  const PocketFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey.shade800,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
