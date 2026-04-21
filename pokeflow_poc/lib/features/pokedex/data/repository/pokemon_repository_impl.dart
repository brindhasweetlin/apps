import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../models/pokemon_model.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final Dio dio;
  final Box<PokemonModel> pokemonBox;
  final ConnectivityService connectivity;

  PokemonRepositoryImpl({
    required this.dio,
    required this.pokemonBox,
    required this.connectivity,
  });

  @override
  Future<List<Pokemon>> getPokemonList() async {
    if (await connectivity.isConnected()) {
      try {
        final response = await dio.get('https://pokeapi.co/api/v2/pokemon?limit=20');
        final results = response.data['results'] as List;
        final pokemonList = results.map((e) => PokemonModel.fromJson(e as Map<String, dynamic>)).toList();

        await pokemonBox.clear();
        await pokemonBox.putAll({for (var p in pokemonList) p.id: p});
        
        return pokemonList.map((e) => e.toEntity()).toList();
      } catch (e) {
        return _getCachedPokemon();
      }
    } else {
      return _getCachedPokemon();
    }
  }

  @override
  Future<Pokemon?> getPokemonDetails(String name) async {
    if (await connectivity.isConnected()) {
      try {
        final response = await dio.get('https://pokeapi.co/api/v2/pokemon/$name');
        final model = PokemonModel.fromJson(response.data);
        
        await pokemonBox.put(model.id, model);
        return model.toEntity();
      } catch (e) {
        return _getCachedPokemonByName(name);
      }
    } else {
      return _getCachedPokemonByName(name);
    }
  }

  List<Pokemon> _getCachedPokemon() {
    return pokemonBox.values.map((e) => e.toEntity()).toList();
  }

  Pokemon? _getCachedPokemonByName(String name) {
    try {
      return pokemonBox.values.firstWhere((e) => e.name == name).toEntity();
    } catch (_) {
      return null;
    }
  }
}
