import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';
import 'package:ghost_food/presentation/controllers/active_orders_controller.dart';

typedef AcceptCallback = Future<void> Function(OrderEntity order);
typedef UpdateStatusCallback = Future<void> Function(int orderId, OrderStatus newStatus);

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final bool isAccepting;
  final AcceptCallback? onAccept;
  final UpdateStatusCallback? onUpdateStatus;
  final ActiveOrderController? activeOrderController;

  const OrderCard({
    Key? key,
    required this.order,
    this.isAccepting = false,
    this.onAccept,
    this.onUpdateStatus,
    this.activeOrderController,
  }) : super(key: key);

  bool get _isPending => order.status == OrderStatus.pendingAcceptance;
  bool get _isActive =>
      order.status == OrderStatus.accepted ||
      order.status == OrderStatus.inPreparation ||
      order.status == OrderStatus.outForDelivery;

  @override
  Widget build(BuildContext context) {
    if (_isPending) {
      return _buildPendingCard(context);
    }

    if (_isActive) {
      return _buildActiveCard(context);
    }

    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF00FFB8).withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Pedido: ${order.recipe?.name ?? 'Desconocido'} - Estado: ${order.status}',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildPendingCard(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF00FFB8).withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nuevo Pedido: ${order.recipe?.name ?? 'Receta desconocida'}',
              style: const TextStyle(
                  color: Color(0xFF00FFB8),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Valor: \$${order.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: (isAccepting || onAccept == null)
                  ? null
                  : () => onAccept!(order),
              icon: isAccepting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(isAccepting ? 'Aceptando...' : 'Aceptar Pedido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFB8),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.recipe?.name ?? 'Receta desconocida',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildStatusChip(),
            const SizedBox(height: 16),
            if (order.status == OrderStatus.accepted)
              ElevatedButton.icon(
                onPressed: (onUpdateStatus == null)
                    ? null
                    : () => onUpdateStatus!(order.id, OrderStatus.inPreparation),
                icon: const Icon(Icons.soup_kitchen_outlined),
                label: const Text('Marcar como "En Preparación"'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44)),
              ),
            if (order.status == OrderStatus.inPreparation)
              ElevatedButton.icon(
                onPressed: (onUpdateStatus == null)
                    ? null
                    : () => onUpdateStatus!(order.id, OrderStatus.outForDelivery),
                icon: const Icon(Icons.delivery_dining_outlined),
                label: const Text('Marcar como "Enviado"'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44)),
              ),
            if (order.status == OrderStatus.outForDelivery)
              ElevatedButton.icon(
                onPressed: (onUpdateStatus == null)
                    ? null
                    : () => onUpdateStatus!(order.id, OrderStatus.delivered),
                icon: const Icon(Icons.done_all),
                label: const Text('Marcar como "Entregado"'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusText = activeOrderController?.getStatusDisplayName(order.status) ??
        (order.status.toString().split('.').last.replaceAll('_', ' ').capitalizeFirst ?? '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF00FFB8).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: const TextStyle(color: Color(0xFF00FFB8), fontWeight: FontWeight.bold),
      ),
    );
  }
}
