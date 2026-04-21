import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/locale_provider.dart';
import 'core/security/security_service.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/pokedex/data/models/pokemon_model.dart';
import 'features/pokedex/presentation/pages/pokemon_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final security = SecurityService();
  final encryptionKey = await security.getHiveKey();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PokemonModelAdapter());
  }
  
  await Hive.openBox<PokemonModel>(
      'pokedex_box',
      encryptionCipher: HiveAesCipher(encryptionKey)
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'PokeFlow POC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: authState.when(
        data: (user) => user == null ? const LoginPage() : const PokemonListPage(),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) => const LoginPage(),
      ),
    );
  }
}
