import 'package:ghost_food/domain/entities/agreement_entity.dart';
import 'package:ghost_food/data/models/recipe_model.dart'; // Asume que ya existe
import 'package:ghost_food/data/models/profile_model.dart'; // Asume que ya existe

class AgreementModel extends AgreementEntity {
  const AgreementModel({
    required super.id,
    required super.recipeId,
    required super.kitchenId,
    required super.creatorId,
    required super.status,
    required super.requestedAt,
    super.approvedAt,
    super.recipe,
    super.kitchen,
  });

  factory AgreementModel.fromJson(Map<String, dynamic> json) {
    return AgreementModel(
      id: json['id'] as int,
      recipeId: json['recipe_id'] as String,
      kitchenId: json['kitchen_id'] as String,
      creatorId: json['creator_id'] as String,
      status: AgreementModel.stringToStatus(json['status'] as String),
      requestedAt: DateTime.parse(json['requested_at'] as String),
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at'] as String) : null,
      // Maneja los objetos anidados de forma segura.
      // Si el join no encuentra datos, 'recipe' o 'kitchen' serán null.
      recipe: json['recipe'] != null ? RecipeModel.fromJson(json['recipe'] as Map<String, dynamic>) : null,
      kitchen: json['kitchen'] != null ? ProfileModel.fromJson(json['kitchen'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'kitchen_id': kitchenId,
      'creator_id': creatorId,
      'status': AgreementModel.statusToString(status),
      'requested_at': requestedAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      // No incluimos los objetos anidados 'recipe' y 'kitchen' aquí,
      // ya que normalmente no se envían de vuelta a la DB en un update/insert.
    };
  }

  static AgreementStatus stringToStatus(String status) {
    switch (status) {
      case 'REQUESTED': return AgreementStatus.requested;
      case 'APPROVED': return AgreementStatus.approved;
      case 'REJECTED': return AgreementStatus.rejected;
      default: throw ArgumentError('Unknown agreement status: $status');
    }
  }

  static String statusToString(AgreementStatus status) {
    switch (status) {
      case AgreementStatus.requested: return 'REQUESTED';
      case AgreementStatus.approved: return 'APPROVED';
      case AgreementStatus.rejected: return 'REJECTED';
    }
  }
}