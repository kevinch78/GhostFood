import 'package:ghost_food/data/models/recipe_model.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.clientId,
    required super.recipeId,
    super.kitchenId,
    required super.status,
    required super.totalPrice,
    required super.createdAt,
    super.recipe,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      clientId: json['client_id'],
      recipeId: json['recipe_id'],
      kitchenId: json['kitchen_id'],
      status: _statusFromString(json['status']),
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      recipe: json['recipes'] != null ? RecipeModel.fromJson(json['recipes']) : null,
    );
  }

  static Map<String, dynamic> toJsonForInsert({
    required String clientId,
    required String recipeId,
    required double totalPrice,
  }) {
    return {
      'client_id': clientId,
      'recipe_id': recipeId,
      'total_price': totalPrice,
      'status': 'PENDING_ACCEPTANCE', // El estado inicial siempre es este
    };
  }

  static OrderStatus _statusFromString(String status) {
    switch (status) {
      case 'PENDING_ACCEPTANCE':
        return OrderStatus.pendingAcceptance;
      case 'ACCEPTED':
        return OrderStatus.accepted;
      case 'IN_PREPARATION':
        return OrderStatus.inPreparation;
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.outForDelivery;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        // Por seguridad, si llega un estado desconocido, lo marcamos como cancelado.
        return OrderStatus.cancelled;
    }
  }

  static String statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingAcceptance:
        return 'PENDING_ACCEPTANCE';
      case OrderStatus.accepted:
        return 'ACCEPTED';
      case OrderStatus.inPreparation:
        return 'IN_PREPARATION';
      case OrderStatus.outForDelivery:
        return 'OUT_FOR_DELIVERY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }
}