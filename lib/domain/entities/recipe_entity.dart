import 'package:flutter/foundation.dart';

enum RecipeType { userCreated, aiGenerated }

class RecipeEntity {
  final String id;
  final String creatorId;
  final String name;
  final String? description;
  final List<dynamic>? ingredients; // Usamos List<dynamic> para la flexibilidad de JSONB
  final List<dynamic>? steps;       // Usamos List<dynamic> para la flexibilidad de JSONB
  final String? imageUrl;
  final String? category;
  final double basePrice;
  final RecipeType type;
  final DateTime createdAt;

  const RecipeEntity({
    required this.id,
    required this.creatorId,
    required this.name,
    this.description,
    this.ingredients,
    this.steps,
    this.imageUrl,
    this.category,
    required this.basePrice,
    required this.type,
    required this.createdAt,
  });

  // El método copyWith es una buena práctica para crear copias modificadas de la entidad.
  RecipeEntity copyWith({
    String? id,
    String? creatorId,
    String? name,
    String? description,
    List<dynamic>? ingredients,
    List<dynamic>? steps,
    String? imageUrl,
    String? category,
    double? basePrice,
    RecipeType? type,
    DateTime? createdAt,
  }) {
    return RecipeEntity(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Los operadores de igualdad son importantes para comparar objetos y para que los
  // widgets reactivos (como Obx) funcionen correctamente con listas.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is RecipeEntity &&
      other.id == id &&
      other.creatorId == creatorId &&
      other.name == name &&
      other.description == description &&
      listEquals(other.ingredients, ingredients) &&
      listEquals(other.steps, steps) &&
      other.imageUrl == imageUrl &&
      other.category == category &&
      other.basePrice == basePrice &&
      other.type == type &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ creatorId.hashCode ^ name.hashCode ^ description.hashCode ^
           ingredients.hashCode ^ steps.hashCode ^ imageUrl.hashCode ^
           category.hashCode ^ basePrice.hashCode ^ type.hashCode ^ createdAt.hashCode;
  }
}