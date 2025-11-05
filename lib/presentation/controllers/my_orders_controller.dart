import 'dart:async';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:ghost_food/domain/repositories/order_repository.dart';

class MyOrdersController extends GetxController {
  final OrderRepository _orderRepository = Get.find();
  final SessionController _sessionController = Get.find();

  StreamSubscription? _ordersSubscription;

  final isLoading = true.obs;
  final myOrders = <OrderEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenForMyOrders();
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    super.onClose();
  }

  void _listenForMyOrders() {
    isLoading.value = true;
    _ordersSubscription?.cancel();
    final clientId = _sessionController.userProfile.value?.id;
    if (clientId == null) {
        isLoading.value = false;
        return;
    }

    _ordersSubscription = _orderRepository.getClientOrdersStream(clientId).listen((orders) {
      myOrders.assignAll(orders);
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'No se pudieron cargar tus pedidos: $e');
    });
  }
}