import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/connectivity_service.dart';
import '../security/security_service.dart';
import '../../features/pokedex/data/models/pokemon_model.dart';
import '../../features/pokedex/data/repository/pokemon_repository_impl.dart';
import '../../features/pokedex/domain/repositories/pokemon_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

final dioProvider = Provider((ref) => Dio());

final connectivityServiceProvider = Provider((ref) => ConnectivityService());

final securityServiceProvider = Provider((ref) => SecurityService());

final pokemonBoxProvider = Provider<Box<PokemonModel>>((ref) {
  return Hive.box<PokemonModel>('pokedex_box');
});

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return PokemonRepositoryImpl(
    dio: ref.watch(dioProvider),
    pokemonBox: ref.watch(pokemonBoxProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(securityServiceProvider));
});
