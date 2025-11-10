import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';
import '../controllers/cook_home_controller.dart';
import '../controllers/active_orders_controller.dart';
import '../widgets/order_card.dart';
import 'empty_state.dart';

class PendingOrdersTab extends StatelessWidget {
  final CookHomeController cookHomeController;
  final ActiveOrderController orderController;

  const PendingOrdersTab({
    Key? key,
    required this.cookHomeController,
    required this.orderController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (cookHomeController.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
      }
      if (orderController.pendingOrders.isEmpty) {
        return const EmptyState(
          icon: Icons.notifications_off_outlined,
          title: 'Sin pedidos pendientes',
          subtitle: 'Aquí aparecerán los nuevos pedidos disponibles.',
        );
      }
      return RefreshIndicator(
        onRefresh: cookHomeController.loadInitialData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderController.pendingOrders.length,
          itemBuilder: (context, index) {
            final order = orderController.pendingOrders[index];
            return OrderCard(
              order: order,
              isAccepting: orderController.isAcceptingOrder[order.id] ?? false,
              onAccept: (OrderEntity o) async => orderController.acceptOrder(o),
            );
          },
        ),
      );
    });
  }
}
