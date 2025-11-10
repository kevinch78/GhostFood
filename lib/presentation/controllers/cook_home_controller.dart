import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/agreement_entity.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/domain/repositories/agreement_repository.dart';
import 'package:ghost_food/domain/repositories/recipe_repository.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:ghost_food/domain/repositories/order_repository.dart';

class CookHomeController extends GetxController {
  final RecipeRepository _recipeRepository = Get.find();
  final AgreementRepository _agreementRepository = Get.find();
  final OrderRepository _orderRepository = Get.find();
  final SessionController _sessionController = Get.find();

  StreamSubscription? _agreementsSubscription;
  StreamSubscription? _kitchenOrdersSubscription;
  StreamSubscription? _pendingOrdersSubscription;

  // --- OBSERVABLE STATE VARIABLES ---
  final isLoading = true.obs;
  final allRecipes = <RecipeEntity>[].obs;
  final marketplaceRecipes = <RecipeEntity>[].obs;
  final myAgreements = <AgreementEntity>[].obs;
  final pendingOrders = <OrderEntity>[].obs;
  final activeOrders = <OrderEntity>[].obs;

  final isRequesting = <String, bool>{}.obs;
  final isAcceptingOrder = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    everAll([allRecipes, myAgreements], (_) => _updateMarketplaceAndOrders());
  }

  @override
  void onClose() {
    _agreementsSubscription?.cancel();
    _pendingOrdersSubscription?.cancel();
    _kitchenOrdersSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _loadAllRecipes(),
      ]);
      _listenForMyAgreements();
      _listenForMyAcceptedOrders();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los datos: $e',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAllRecipes() async {
    try {
      final recipes = await _recipeRepository.getAllRecipes();
      allRecipes.assignAll(recipes);
    } catch (e) {
      rethrow;
    }
  }

  void _listenForMyAgreements() {
    _agreementsSubscription?.cancel();
    final kitchenId = _sessionController.userProfile.value?.id;
    if (kitchenId == null) return;

    _agreementsSubscription = _agreementRepository.getAgreementsStreamByKitchen(kitchenId).listen((agreements) {
      myAgreements.assignAll(agreements);
    }, onError: (e) {
      Get.snackbar(
        'Error de Conexión',
        'No se pudo escuchar los convenios: $e',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    });
  }

  void _updateMarketplaceAndOrders() {
    // 1. Filtrar recetas del marketplace
    final rejectedRecipeIds = myAgreements
        .where((a) => a.status == AgreementStatus.rejected)
        .map((a) => a.recipeId)
        .toSet();

    marketplaceRecipes.assignAll(
      allRecipes.where((r) => 
        !rejectedRecipeIds.contains(r.id) && 
        r.type != RecipeType.aiGenerated
      )
    );

    // 2. Obtener recetas disponibles (aprobadas + IA)
    final licensedRecipeIds = myAgreements
        .where((a) => a.status == AgreementStatus.approved)
        .map((a) => a.recipeId)
        .toList();

    final aiRecipeIds = allRecipes
        .where((r) => r.type == RecipeType.aiGenerated)
        .map((r) => r.id)
        .toList();

    final allAvailableRecipeIds = [...licensedRecipeIds, ...aiRecipeIds];

    print('🔍 DEBUG: Total agreements: ${myAgreements.length}');
    print('🔍 DEBUG: Approved agreements: ${licensedRecipeIds.length}');
    print('🔍 DEBUG: AI recipes: ${aiRecipeIds.length}');
    print('🔍 DEBUG: Total available recipes: ${allAvailableRecipeIds.length}');

    // 3. Escuchar pedidos pendientes
    _listenForPendingOrders(allAvailableRecipeIds);
  }

  void _listenForPendingOrders(List<String> availableRecipeIds) {
    print('🔍 DEBUG: Listening for pending orders with recipes: $availableRecipeIds');
    
    _pendingOrdersSubscription?.cancel();
    if (availableRecipeIds.isNotEmpty) {
      _pendingOrdersSubscription = _orderRepository.getPendingOrdersStream(availableRecipeIds).listen((orders) {
        print('🔍 DEBUG: Received ${orders.length} pending orders');
        orders.forEach((order) {
          print('   - Order ID: ${order.id}, Recipe: ${order.recipeId}, Status: ${order.status}, Kitchen: ${order.kitchenId}');
        });
        
        // ✅ FILTRO ADICIONAL: Asegurarnos de que solo mostramos pedidos que NO tienen cocina asignada
        final trulyPendingOrders = orders.where((order) => 
          order.kitchenId == null && 
          order.status == OrderStatus.pendingAcceptance
        ).toList();
        
        print('🔍 DEBUG: After filtering: ${trulyPendingOrders.length} truly pending orders');
        pendingOrders.assignAll(trulyPendingOrders);
      }, onError: (e) {
        print('❌ DEBUG: Error listening to pending orders: $e');
        Get.snackbar(
          'Error de Conexión',
          'No se pudo escuchar los pedidos pendientes: $e',
          backgroundColor: const Color(0xFFFF6B6B),
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      });
    } else {
      print('⚠️ DEBUG: No available recipes, clearing pending orders');
      pendingOrders.clear();
    }
  }

  void _listenForMyAcceptedOrders() {
    _kitchenOrdersSubscription?.cancel();
    final kitchenId = _sessionController.userProfile.value!.id;
    _kitchenOrdersSubscription = _orderRepository.getKitchenOrdersStream(kitchenId).listen((orders) {
      print('🔍 DEBUG: Kitchen orders received: ${orders.length}');
      orders.forEach((order) {
        print('   - Order ${order.id}: ${order.status.name}');
      });
      
      // Filtramos para mostrar solo los que están en progreso
      activeOrders.assignAll(orders.where((o) =>
          o.status == OrderStatus.accepted ||
          o.status == OrderStatus.inPreparation ||
          o.status == OrderStatus.outForDelivery).toList());
    }, onError: (e) {
      Get.snackbar(
        'Error de Conexión',
        'No se pudo escuchar los pedidos de la cocina: $e',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    });
  }

  Future<void> acceptOrder(OrderEntity order) async {
    isAcceptingOrder[order.id] = true;
    try {
      print('🔍 DEBUG: Accepting order ${order.id}...');
      await _orderRepository.acceptOrder(
        orderId: order.id,
        kitchenId: _sessionController.userProfile.value!.id,
      );
      print('✅ DEBUG: Order ${order.id} accepted successfully');
      
      // ✅ FIX: Remover manualmente el pedido de la lista pendiente
      // Esto proporciona feedback inmediato mientras el stream se actualiza
      pendingOrders.removeWhere((o) => o.id == order.id);
      print('🔍 DEBUG: Removed order ${order.id} from pending list');
      
      // El stream de _kitchenOrdersSubscription lo agregará automáticamente a activeOrders
    } catch (e) {
      print('❌ DEBUG: Error accepting order ${order.id}: $e');
      rethrow;
    } finally {
      isAcceptingOrder[order.id] = false;
    }
  }

  Future<void> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    try {
      await _orderRepository.updateOrderStatus(orderId: orderId, status: newStatus);
      
      // ✅ Snackbar personalizado con el estilo de la app
      Get.snackbar(
        'Estado Actualizado',
        'El pedido ahora está en estado: ${_getStatusDisplayName(newStatus)}',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el estado del pedido: $e',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      rethrow;
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
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

  Future<void> requestAgreement(RecipeEntity recipe) async {
    isRequesting[recipe.id] = true;
    try {
      await _agreementRepository.createAgreement(
        recipeId: recipe.id,
        creatorId: recipe.creatorId,
        kitchenId: _sessionController.userProfile.value!.id,
      );
      
      // ✅ Snackbar personalizado
      Get.snackbar(
        'Solicitud Enviada',
        'El creador ha sido notificado.',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo enviar la solicitud: $e',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      rethrow;
    } finally {
      isRequesting[recipe.id] = false;
    }
  }

  AgreementStatus? getAgreementStatusForRecipe(String recipeId) {
    final agreement = myAgreements.firstWhereOrNull((a) => a.recipeId == recipeId);
    return agreement?.status;
  }

  String? getCurrentUserId() {
    return _sessionController.userProfile.value?.id;
  }
}