import 'package:flutter/material.dart';
import 'package:pocket_fit/pages/main_navigation.dart';
import 'package:pocket_fit/services/notification_service.dart';
import 'package:pocket_fit/services/settings_service.dart';

void main() async {
  // 确保 Flutter 绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化设置服务
  await SettingsService().initialize();

  // 初始化通知服务
  await NotificationService().initialize();

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
