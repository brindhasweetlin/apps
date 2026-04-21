import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/pokemon.dart';

part 'pokemon_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class PokemonModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final List<String>? types;

  @HiveField(4)
  final int? height;

  @HiveField(5)
  final int? weight;

  PokemonModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types,
    this.height,
    this.weight,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String?;
    int id = json['id'] as int? ?? 0;
    if (id == 0 && url != null) {
      final segments = url.split('/');
      id = int.tryParse(segments[segments.length - 2]) ?? 0;
    }

    return PokemonModel(
      id: id,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String? ?? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
      types: (json['types'] as List?)?.map((e) => (e['type']['name'] as String)).toList(),
      height: json['height'] as int?,
      weight: json['weight'] as int?,
    );
  }
  
  Map<String, dynamic> toJson() => _$PokemonModelToJson(this);

  Pokemon toEntity() => Pokemon(
    id: id,
    name: name,
    imageUrl: imageUrl,
    types: types,
    height: height,
    weight: weight,
  );

  factory PokemonModel.fromEntity(Pokemon entity) => PokemonModel(
    id: entity.id,
    name: entity.name,
    imageUrl: entity.imageUrl,
    types: entity.types,
    height: entity.height,
    weight: entity.weight,
  );
}
