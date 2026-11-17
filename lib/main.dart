import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/blog_screen.dart';
import 'presentation/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    final settings = await Hive.openBox<String>('gorselara_blog_settings');
    final history = await Hive.openBox<String>('gorselara_blog_history');
    runApp(ProviderScope(overrides: [
      settingsBox.overrideWithValue(settings), historyBox.overrideWithValue(history),
    ], child: const GorselAraApp()));
  } catch (_) {
    runApp(MaterialApp(home: Scaffold(body: Center(child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        const Text('Yerel veriler açılamadı. Depolama alanını kontrol edin.'),
        FilledButton(onPressed: main, child: const Text('Yeniden dene')),
      ])))));
  }
}

class GorselAraApp extends ConsumerWidget {
  const GorselAraApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: 'GörselAra', debugShowCheckedModeBanner: false,
    themeMode: ref.watch(themeProvider),
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF006B54)), scaffoldBackgroundColor: const Color(0xFFFAF9F4)),
    darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF006B54), brightness: Brightness.dark)),
    home: const BlogScreen(),
  );
}
