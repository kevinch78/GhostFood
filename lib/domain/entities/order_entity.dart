import 'package:ghost_food/domain/entities/recipe_entity.dart';

enum OrderStatus {
  pendingAcceptance,
  accepted,
  inPreparation,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderEntity {
  final int id;
  final String clientId;
  final String recipeId;
  final String? kitchenId;
  final OrderStatus status;
  final double totalPrice;
  final DateTime createdAt;

  // Campos opcionales para joins
  final RecipeEntity? recipe;

  const OrderEntity({
    required this.id,
    required this.clientId,
    required this.recipeId,
    this.kitchenId,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    this.recipe,
  });
}