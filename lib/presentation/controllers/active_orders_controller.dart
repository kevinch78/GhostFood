import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';
import 'package:ghost_food/domain/repositories/order_repository.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';

class ActiveOrderController extends GetxController {
  final OrderRepository _orderRepository = Get.find();
  final SessionController _sessionController = Get.find();

  StreamSubscription? _pendingOrdersSubscription;
  StreamSubscription? _kitchenOrdersSubscription;

  final pendingOrders = <OrderEntity>[].obs;
  final activeOrders = <OrderEntity>[].obs;
  final isAcceptingOrder = <int, bool>{}.obs;

  @override
  void onClose() {
    _pendingOrdersSubscription?.cancel();
    _kitchenOrdersSubscription?.cancel();
    super.onClose();
  }

  void listenForPendingOrders(List<String> availableRecipeIds) {
    _pendingOrdersSubscription?.cancel();
    if (availableRecipeIds.isEmpty) {
      pendingOrders.clear();
      return;
    }

    _pendingOrdersSubscription =
        _orderRepository.getPendingOrdersStream(availableRecipeIds).listen((orders) {
      final trulyPending = orders.where((o) =>
          o.kitchenId == null && o.status == OrderStatus.pendingAcceptance).toList();
      pendingOrders.assignAll(trulyPending);
    });
  }

  void listenForMyAcceptedOrders() {
    _kitchenOrdersSubscription?.cancel();
    final kitchenId = _sessionController.userProfile.value!.id;

    _kitchenOrdersSubscription =
        _orderRepository.getKitchenOrdersStream(kitchenId).listen((orders) {
      activeOrders.assignAll(orders.where((o) =>
          o.status == OrderStatus.accepted ||
          o.status == OrderStatus.inPreparation ||
          o.status == OrderStatus.outForDelivery).toList());
    });
  }

  Future<void> acceptOrder(OrderEntity order) async {
    isAcceptingOrder[order.id] = true;
    try {
      await _orderRepository.acceptOrder(
        orderId: order.id,
        kitchenId: _sessionController.userProfile.value!.id,
      );
      pendingOrders.removeWhere((o) => o.id == order.id);

      Get.snackbar(
        '¡Pedido Aceptado!',
        'Prepara "${order.recipe?.name ?? 'receta desconocida'}" para el cliente.',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } finally {
      isAcceptingOrder[order.id] = false;
    }
  }

  Future<void> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    await _orderRepository.updateOrderStatus(orderId: orderId, status: newStatus);
    Get.snackbar(
      'Estado Actualizado',
      'El pedido ahora está en estado: ${getStatusDisplayName(newStatus)}',
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  String getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingAcceptance:
        return 'Pendiente de Aceptación';
      case OrderStatus.accepted:
        return 'Aceptado';
      case OrderStatus.inPreparation:
        return 'En Preparación';
      case OrderStatus.outForDelivery:
        return 'Enviado';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}
