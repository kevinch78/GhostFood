import 'package:ghost_food/domain/entities/profile_entity.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';

enum AgreementStatus { requested, approved, rejected }

class AgreementEntity {
  final int id;
  final String recipeId;
  final String kitchenId;
  final String creatorId;
  final AgreementStatus status;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final RecipeEntity? recipe;
  final ProfileEntity? kitchen;

  const AgreementEntity({
    required this.id,
    required this.recipeId,
    required this.kitchenId,
    required this.creatorId,
    required this.status,
    required this.requestedAt,
    this.approvedAt,
    this.recipe,
    this.kitchen,
  });

  AgreementEntity copyWith({
    int? id,
    String? recipeId,
    String? kitchenId,
    String? creatorId,
    AgreementStatus? status,
    DateTime? requestedAt,
    DateTime? approvedAt,
    RecipeEntity? recipe,
    ProfileEntity? kitchen,
  }) {
    return AgreementEntity(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      kitchenId: kitchenId ?? this.kitchenId,
      creatorId: creatorId ?? this.creatorId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      recipe: recipe ?? this.recipe,
      kitchen: kitchen ?? this.kitchen,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AgreementEntity &&
      other.id == id &&
      other.recipeId == recipeId &&
      other.kitchenId == kitchenId &&
      other.creatorId == creatorId &&
      other.status == status &&
      other.requestedAt == requestedAt &&
      other.approvedAt == approvedAt &&
      other.recipe == recipe &&
      other.kitchen == kitchen;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      recipeId.hashCode ^
      kitchenId.hashCode ^
      creatorId.hashCode ^
      status.hashCode ^
      requestedAt.hashCode ^
      approvedAt.hashCode ^
      recipe.hashCode ^
      kitchen.hashCode;
  }
}