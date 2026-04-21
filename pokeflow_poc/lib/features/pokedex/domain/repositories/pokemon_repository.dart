import '../entities/pokemon.dart';

abstract class PokemonRepository {
  Future<List<Pokemon>> getPokemonList();
  Future<Pokemon?> getPokemonDetails(String name);
}
