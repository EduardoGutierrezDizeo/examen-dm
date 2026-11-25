import 'package:cuenta/config/router/router_config.dart';
import 'package:cuenta/config/theme/app_theme.dart';
import 'package:cuenta/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:cuenta/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper().database;

  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      routerConfig: appRouter,

      themeMode: theme ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('es'),

      theme: AppTheme().themeData(false),
      darkTheme: AppTheme().themeData(true),

      debugShowCheckedModeBanner: false,

      supportedLocales: const [Locale('es')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
