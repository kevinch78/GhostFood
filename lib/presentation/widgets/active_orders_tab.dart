import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';
import '../controllers/cook_home_controller.dart';
import '../controllers/active_orders_controller.dart';
import '../widgets/order_card.dart';
import 'empty_state.dart';

class ActiveOrdersTab extends StatelessWidget {
  final CookHomeController cookHomeController;
  final ActiveOrderController orderController;

  const ActiveOrdersTab({
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
      if (orderController.activeOrders.isEmpty) {
        return const EmptyState(
          icon: Icons.no_food_outlined,
          title: 'Sin pedidos activos',
          subtitle: 'Acepta un pedido pendiente para que aparezca aquí.',
        );
      }
      return RefreshIndicator(
        onRefresh: cookHomeController.loadInitialData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderController.activeOrders.length,
          itemBuilder: (context, index) {
            final order = orderController.activeOrders[index];
            return OrderCard(
              order: order,
              onUpdateStatus: orderController.updateOrderStatus,
            );
          },
        ),
      );
    });
  }
}
