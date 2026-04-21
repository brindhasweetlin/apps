import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/pokemon.dart';

final pokemonListProvider = FutureProvider<List<Pokemon>>((ref) async {
  final repository = ref.watch(pokemonRepositoryProvider);
  return repository.getPokemonList();
});

final pokemonDetailsProvider = FutureProvider.family<Pokemon?, String>((ref, name) async {
  final repository = ref.watch(pokemonRepositoryProvider);
  return repository.getPokemonDetails(name);
});
