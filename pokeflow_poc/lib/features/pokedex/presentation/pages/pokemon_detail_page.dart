import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../domain/entities/pokemon.dart';
import '../providers/pokemon_provider.dart';

class PokemonDetailPage extends ConsumerWidget {
  final String pokemonName;

  const PokemonDetailPage({super.key, required this.pokemonName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonAsync = ref.watch(pokemonDetailsProvider(pokemonName));
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(pokemonName.toUpperCase()),
      ),
      body: pokemonAsync.when(
        data: (pokemon) => pokemon == null
            ? Center(child: Text(AppLocalization.getString(locale, 'not_found')))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'pokemon-${pokemon.id}',
                        child: Image.network(
                          pokemon.imageUrl,
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '#${pokemon.id.toString().padLeft(3, '0')}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        pokemon.name.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      if (pokemon.types != null)
                        Wrap(
                          spacing: 8,
                          children: pokemon.types!
                              .map((type) => Chip(label: Text(type.toUpperCase())))
                              .toList(),
                        ),
                      const SizedBox(height: 20),
                      _InfoRow(
                        label: AppLocalization.getString(locale, 'height'),
                        value: '${(pokemon.height ?? 0) / 10} m',
                      ),
                      _InfoRow(
                        label: AppLocalization.getString(locale, 'weight'),
                        value: '${(pokemon.weight ?? 0) / 10} kg',
                      ),
                    ],
                  ),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
