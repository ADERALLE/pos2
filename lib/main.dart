import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pos_v1/i10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_routes.dart';
import 'core/models/themes.dart';
import 'core/viewmodels/theme_provider.dart';
import 'core/viewmodels/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fibwxmixrpgwxmrasbxk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpYnd4bWl4cnBnd3htcmFzYnhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5Nzc5MDIsImV4cCI6MjA5MDU1MzkwMn0.rFzNrF0zxPHz8Tn71BQ91Cacw5HVTXB5X38e4b_m8NM',
  );
  runApp(
    const ProviderScope(
      child: CoffeePosApp(),
    ),
  );
}

class CoffeePosApp extends ConsumerWidget {
  const CoffeePosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Coffee POS',
      themeMode: themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      routerConfig: router,
      locale: locale,

      // i18n setup
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
    );
  }
}