import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar_page.dart';
import 'summary_page.dart';
import 'my_page.dart';
import 'bill_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final language = prefs.getString('language') ?? '简体中文';

  runApp(MyApp(isDarkMode: isDarkMode, language: language));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final String language;

  const MyApp({super.key, required this.isDarkMode, required this.language});

  @override
  State<MyApp> createState() => _MyAppState();

  // 提供一个静态方法让其他Widget可以访问并更新应用状态
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  late String _language;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _language = widget.language;
  }

  void updateTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  void updateLanguage(String language) {
    setState(() {
      _language = language;
    });
  }

  Locale get _locale {
    if (_language == 'English') {
      return const Locale('en', 'US');
    }
    return const Locale('zh', 'CN');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'daily_coffee',
      locale: _locale,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainTabPage(),
    );
  }
}

class MainTabPage extends StatefulWidget {
  const MainTabPage({Key? key}) : super(key: key);
  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const CalendarPage(),
    const SummaryPage(),
    const BillPage(),
    const MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // 获取当前区域设置以决定标签文本
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.brown,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: isEnglish ? 'Calendar' : '日历',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: isEnglish ? 'Track' : '追踪',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: isEnglish ? 'Bills' : '账单',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: isEnglish ? 'Mine' : '我的',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
