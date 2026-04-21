import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/pokemon_provider.dart';
import 'pokemon_detail_page.dart';

class PokemonListPage extends ConsumerWidget {
  const PokemonListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonAsync = ref.watch(pokemonListProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.getString(locale, 'pokedex')),
        actions: [
          PopupMenuButton<Locale>(
            tooltip: 'Select Language',
            initialValue: locale,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    locale.languageCode.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            onSelected: (Locale newLocale) {
              ref.read(localeProvider.notifier).state = newLocale;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: Row(
                  children: [
                    if (locale.languageCode == 'en') const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('English'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: const Locale('es'),
                child: Row(
                  children: [
                    if (locale.languageCode == 'es') const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('Español'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = 
                themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: pokemonAsync.when(
        data: (pokemonList) => RefreshIndicator(
          onRefresh: () => ref.refresh(pokemonListProvider.future),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: pokemonList.length,
            itemBuilder: (context, index) {
              final pokemon = pokemonList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Hero(
                    tag: 'pokemon-${pokemon.id}',
                    child: Image.network(
                      pokemon.imageUrl,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  title: Text(
                    pokemon.name.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('#${pokemon.id.toString().padLeft(3, '0')}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailPage(pokemonName: pokemon.name),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(pokemonListProvider),
                child: Text(AppLocalization.getString(locale, 'retry')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
