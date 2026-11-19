import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/azkar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tasbih_screen.dart';
import 'services/notifier.dart';
import 'services/prefs.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  await Notifier.init();
  await Notifier.rescheduleAll();
  runApp(const AzkarApp());
}

class AzkarApp extends StatelessWidget {
  const AzkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أذكاري',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // يتبع نمط الهاتف تلقائيًا
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => Notifier.requestPermission());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(goToTab: (i) => setState(() => tab = i)),
      const AzkarPage(),
      const QuranPage(),
      const TasbihPage(),
      const SettingsPage(),
    ];
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (w, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0, .03), end: Offset.zero)
                .animate(a),
            child: w,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'الأذكار'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'القرآن'),
          NavigationDestination(
              icon: Icon(Icons.radio_button_unchecked_rounded),
              selectedIcon: Icon(Icons.radio_button_checked_rounded),
              label: 'المسبحة'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'الإعدادات'),
        ],
      ),
    );
  }
}
