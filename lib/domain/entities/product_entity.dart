import 'package:ghost_food/domain/entities/profile_entity.dart';

class ProductEntity {
  final String id;
  final String cookId;
  final String name;
  final String? description;
  final double price;
  final String? category;
  final String? imageUrl;
  final bool available;
  final ProfileEntity? cook;

  const ProductEntity({
    required this.id,
    required this.cookId,
    required this.name,
    this.description,
    required this.price,
    this.category,
    this.imageUrl,
    required this.available,
    this.cook,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductEntity &&
        other.id == id &&
        other.cookId == cookId &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.category == category &&
        other.imageUrl == imageUrl &&
        other.available == available &&
        other.cook == cook;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cookId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        price.hashCode ^
        category.hashCode ^
        imageUrl.hashCode ^
        available.hashCode ^
        cook.hashCode;
  }

  ProductEntity copyWith({
    String? id,
    String? cookId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? available,
    ProfileEntity? cook,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      cookId: cookId ?? this.cookId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      available: available ?? this.available,
      cook: cook ?? this.cook,
    );
  }
}