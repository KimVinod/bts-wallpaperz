import 'package:bts_wallpaperz/screens/home/home_screen.dart';
import 'package:bts_wallpaperz/services/firebase_service.dart';
import 'package:bts_wallpaperz/services/settings_service.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await FirebaseService.setup(isRelease: false);
  runApp(BTSWallpaperzApp(themeMode: await SettingsService.loadTheme(), isMaterialYou: await SettingsService.loadMaterialYou()));
}

class BTSWallpaperzApp extends StatefulWidget {
  final ThemeMode themeMode;
  final bool isMaterialYou;
  const BTSWallpaperzApp({super.key, required this.themeMode, required this.isMaterialYou});

  @override
  State<BTSWallpaperzApp> createState() => BTSWallpaperzAppState();

  static BTSWallpaperzAppState of(BuildContext context) => context.findAncestorStateOfType<BTSWallpaperzAppState>()!;
}

class BTSWallpaperzAppState extends State<BTSWallpaperzApp> {
  ThemeMode? _themeMode;
  late bool _isMaterialYou;
  final defaultColorScheme = ColorScheme.fromSeed(seedColor: Colors.purple.shade300);
  final defaultDarkColorScheme = ColorScheme.fromSeed(seedColor: Colors.purple.shade300, brightness: Brightness.dark);

  @override
  void initState() {
    super.initState();
    _initTheme();
    FirebaseService.init();
  }

  void _initTheme() {
    setState(() {
      _themeMode = widget.themeMode;
      _isMaterialYou = widget.isMaterialYou;
    });
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void changeMaterialYou(bool isMaterialYou) {
    setState(() {
      _isMaterialYou = isMaterialYou;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: "Bangtan Wallpaperz",
          theme: ThemeData(
            colorScheme: _isMaterialYou ? lightColorScheme ?? defaultColorScheme : defaultColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: _isMaterialYou ? darkColorScheme ?? defaultDarkColorScheme : defaultDarkColorScheme,
            useMaterial3: true,
          ),
          themeMode: _themeMode,
          home: const HomeScreen(),
        );
      }
    );
  }
}