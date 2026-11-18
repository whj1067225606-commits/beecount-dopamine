import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/home_page.dart';
import 'services/shortcut_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const InspirationSparkApp());
}

class InspirationSparkApp extends StatefulWidget {
  const InspirationSparkApp({super.key});

  @override
  State<InspirationSparkApp> createState() => _InspirationSparkAppState();
}

class _InspirationSparkAppState extends State<InspirationSparkApp> {
  final ShortcutService _shortcuts = ShortcutService();
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  String? _launchPanel;

  @override
  void initState() {
    super.initState();
    _bootstrapShortcuts();
  }

  Future<void> _bootstrapShortcuts() async {
    await _shortcuts.setupQuickActions((type) {
      _openFromShortcut(type);
    });
  }

  void _openFromShortcut(String type) {
    setState(() => _launchPanel = type);
    // Rebuild home so it can auto-enter workspace with focus.
    _navKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '灵感火花',
      debugShowCheckedModeBanner: false,
      theme: buildSparkTheme(),
      navigatorKey: _navKey,
      home: HomePage(
        key: ValueKey(_launchPanel ?? 'default'),
        shortcutService: _shortcuts,
        initialPanel: _launchPanel,
      ),
    );
  }
}
