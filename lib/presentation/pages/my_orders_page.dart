import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/data/models/order_model.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';
import 'package:ghost_food/presentation/controllers/my_orders_controller.dart';
import 'package:ghost_food/presentation/widgets/custom_app_bar.dart';
import 'package:ghost_food/presentation/widgets/empty_state.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyOrdersController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: const CustomAppBar(
        title: 'Mis Pedidos',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
        }
        if (controller.myOrders.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Aún no tienes pedidos',
            subtitle: 'Explora las recetas y pide algo delicioso.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myOrders.length,
          itemBuilder: (context, index) {
            return _OrderCard(order: controller.myOrders[index]);
          },
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.recipe?.name ?? 'Receta Desconocida',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(color: Color(0xFF00FFB8), fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pedido el ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const Divider(color: Colors.white24, height: 24),
            _OrderStatusTracker(currentStatus: order.status),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusTracker extends StatelessWidget {
  final OrderStatus currentStatus;
  const _OrderStatusTracker({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final allStatuses = [
      OrderStatus.pendingAcceptance,
      OrderStatus.accepted,
      OrderStatus.inPreparation,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentIndex = allStatuses.indexOf(currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(allStatuses.length, (index) {
        final status = allStatuses[index];
        final isActive = index <= currentIndex;
        final isCurrent = index == currentIndex;

        // No mostramos "Pendiente de Aceptación" si ya fue aceptado.
        if (status == OrderStatus.pendingAcceptance && currentIndex > 0) {
          return const SizedBox.shrink();
        }

        return _StatusStep(
          title: _statusToText(status),
          icon: _statusToIcon(status),
          isActive: isActive,
          isCurrent: isCurrent,
          isLast: index == allStatuses.length - 1,
        );
      }),
    );
  }

  String _statusToText(OrderStatus status) {
    return OrderModel.statusToString(status).replaceAll('_', ' ').capitalizeFirst ?? '';
  }

  IconData _statusToIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingAcceptance: return Icons.hourglass_top_outlined;
      case OrderStatus.accepted: return Icons.check_circle_outline;
      case OrderStatus.inPreparation: return Icons.soup_kitchen_outlined;
      case OrderStatus.outForDelivery: return Icons.delivery_dining_outlined;
      case OrderStatus.delivered: return Icons.home_work_outlined;
      case OrderStatus.cancelled: return Icons.cancel_outlined;
    }
  }
}

class _StatusStep extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final bool isCurrent;
  final bool isLast;

  const _StatusStep({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isCurrent ? const Color(0xFF00FFB8) : Colors.green;
    final inactiveColor = Colors.white38;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: isActive ? activeColor : inactiveColor, size: 24),
            if (!isLast)
              Container(width: 2, height: 20, color: isActive ? activeColor : inactiveColor),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : inactiveColor,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}