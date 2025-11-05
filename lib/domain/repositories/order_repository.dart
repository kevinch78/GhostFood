import 'package:ghost_food/domain/entities/order_entity.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';

abstract class OrderRepository {
  Future<OrderEntity> createOrderFromCartItem(CartItem item);

  // Este stream será para que las cocinas escuchen nuevos pedidos.
  Stream<List<OrderEntity>> getPendingOrdersStream(List<String> licensedRecipeIds);
  // Stream para todos los pedidos de una cocina (activos e históricos)
  Stream<List<OrderEntity>> getKitchenOrdersStream(String kitchenId);
  // Stream para todos los pedidos de un cliente
  Stream<List<OrderEntity>> getClientOrdersStream(String clientId);
  Future<void> acceptOrder({required int orderId, required String kitchenId});
  Future<void> updateOrderStatus({required int orderId, required OrderStatus status});
}