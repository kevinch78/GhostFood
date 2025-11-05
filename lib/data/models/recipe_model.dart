import 'package:ghost_food/domain/entities/recipe_entity.dart';

class RecipeModel extends RecipeEntity {
  const RecipeModel({
    required super.id,
    required super.creatorId,
    required super.name,
    super.description,
    super.ingredients,
    super.steps,
    super.imageUrl,
    super.category,
    required super.basePrice,
    required super.type,
    required super.createdAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
      creatorId: json['creator_id'],
      name: json['name'],
      description: json['description'],
      ingredients: json['ingredients'] != null ? List<dynamic>.from(json['ingredients']) : null,
      steps: json['steps'] != null ? List<dynamic>.from(json['steps']) : null,
      imageUrl: json['image_url'],
      category: json['category'],
      basePrice: (json['base_price'] as num).toDouble(),
      type: _typeFromString(json['type']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  factory RecipeModel.fromEntity(RecipeEntity entity) {
    return RecipeModel(
      id: entity.id,
      creatorId: entity.creatorId,
      name: entity.name,
      description: entity.description,
      ingredients: entity.ingredients,
      steps: entity.steps,
      imageUrl: entity.imageUrl,
      category: entity.category,
      basePrice: entity.basePrice,
      type: entity.type,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'image_url': imageUrl,
      'category': category,
      'base_price': basePrice,
      'type': _typeToString(type), // ← Usar el método correcto
    };
  }

  // ← CORREGIDO: Ahora coincide con la DB
  static RecipeType _typeFromString(String type) {
    switch (type) {
      case 'AI_GENERATED':  // ← Mayúsculas con guion bajo
        return RecipeType.aiGenerated;
      case 'USER_CREATED':
      default:
        return RecipeType.userCreated;
    }
  }

  // ← NUEVO: Método para convertir enum a string de DB
  static String _typeToString(RecipeType type) {
    switch (type) {
      case RecipeType.aiGenerated:
        return 'AI_GENERATED';  // ← Mayúsculas con guion bajo
      case RecipeType.userCreated:
        return 'USER_CREATED';
    }
  }
}