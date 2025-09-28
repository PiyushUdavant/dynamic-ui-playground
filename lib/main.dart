import 'package:dynamic_ui_playground/firebase_options.dart';
import 'package:dynamic_ui_playground/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dynamic_ui/presentation/screens/home_page.dart';
import 'features/easter_egg/domain/providers/app_theme_provider.dart';
import 'util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);

    final textTheme = createTextTheme(
      context,
      appTheme.bodyFont,
      appTheme.displayFont,
    );

    Color parseSeed(String hex) {
      final cleaned = hex.replaceFirst('#', '');
      final value = int.parse(
        cleaned.length == 8 ? cleaned : 'FF$cleaned',
        radix: 16,
      );
      return Color(value);
    }

    final materialTheme = MaterialTheme(
      textTheme,
      seedColor: parseSeed(appTheme.baseColor),
    );

    final ThemeData light = materialTheme.light();
    final ThemeData dark = materialTheme.dark();

    return MaterialApp(
      title: 'dynamic_ui_playground',
      theme: light,
      darkTheme: dark,
      themeMode: appTheme.mode,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Dynamic UI'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HomePage(title: title);
  }
}
