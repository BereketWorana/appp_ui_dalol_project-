class RoomType {
  final int id;
  final String name;
  final String? slug;
  final double? basePrice;

  RoomType({
    required this.id,
    required this.name,
    this.slug,
    this.basePrice,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    final int id = int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final String name = json['name']?.toString() ?? 'Standard Room';
    final String? slug = json['slug']?.toString();
    final double? basePrice = double.tryParse(
      json['base_price']?.toString() ?? json['price']?.toString() ?? '',
    );

    return RoomType(
      id: id,
      name: name,
      slug: slug,
      basePrice: basePrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'name': name,
      'slug': slug,
      'base_price': basePrice?.toStringAsFixed(2),
    };
  }
}
