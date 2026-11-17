import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers.dart';
import 'presentation/screens/home_screen.dart';

class GorselAraApp extends ConsumerWidget {
  const GorselAraApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    ThemeData theme(Brightness brightness) => ThemeData(useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006B54), brightness: brightness),
      scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xFFFAF9F4) : const Color(0xFF101714),
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: const InputDecorationTheme(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)));
    return MaterialApp(title: 'GörselAra', debugShowCheckedModeBanner: false,
      locale: Locale(settings.language), supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      themeMode: settings.theme, theme: theme(Brightness.light), darkTheme: theme(Brightness.dark),
      home: const HomeScreen());
  }
}
