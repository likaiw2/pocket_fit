import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pocket_fit/pages/main_navigation.dart';
import 'package:pocket_fit/services/notification_service.dart';
import 'package:pocket_fit/services/settings_service.dart';
import 'package:pocket_fit/services/localization_service.dart';
import 'package:pocket_fit/l10n/app_localizations.dart';

void main() async {
  // 确保 Flutter 绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化设置服务
  await SettingsService().initialize();

  // 初始化通知服务
  await NotificationService().initialize();

  // 加载语言设置
  final language = await SettingsService().getLanguage();
  LocalizationService().setLanguage(language);

  runApp(const PocketFitApp());
}

class PocketFitApp extends StatefulWidget {
  const PocketFitApp({super.key});

  @override
  State<PocketFitApp> createState() => _PocketFitAppState();
}

class _PocketFitAppState extends State<PocketFitApp> {
  final _localizationService = LocalizationService();

  @override
  void initState() {
    super.initState();
    // 监听语言变化
    _localizationService.languageNotifier.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketFit',
      debugShowCheckedModeBanner: false,

      // 国际化配置
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', ''),
        Locale('en', ''),
      ],
      locale: Locale(_localizationService.currentLanguage),

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
