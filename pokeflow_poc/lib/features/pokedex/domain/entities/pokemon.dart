class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String>? types;
  final int? height;
  final int? weight;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types,
    this.height,
    this.weight,
  });
}
