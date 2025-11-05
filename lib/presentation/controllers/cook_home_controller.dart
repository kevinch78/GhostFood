import 'dart:async';

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
  StreamSubscription? _pendingOrdersSubscription; // Stream separado para pedidos pendientes

  // --- OBSERVABLE STATE VARIABLES ---
  final isLoading = true.obs;
  final allRecipes = <RecipeEntity>[].obs;
  // Nueva lista para el marketplace, que excluye las recetas rechazadas.
  final marketplaceRecipes = <RecipeEntity>[].obs;
  final myAgreements = <AgreementEntity>[].obs;
  // Listas separadas para cada pestaña
  final pendingOrders = <OrderEntity>[].obs;
  final activeOrders = <OrderEntity>[].obs;

  final isRequesting = <String, bool>{}.obs; // Mapa para el estado de carga por receta
  final isAcceptingOrder = <int, bool>{}.obs; // Para el estado de carga al aceptar pedido

  @override
  void onInit() {
    super.onInit();
    loadInitialData();

    // Worker para filtrar las recetas del marketplace.
    // Se ejecutará cada vez que 'allRecipes' o 'myAgreements' cambien.
    // Esto soluciona el race condition de la carga inicial.
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
        _loadAllRecipes(), // Esto solo se necesita una vez.
      ]);
      _listenForMyAgreements(); // Escuchamos convenios en tiempo real.
      _listenForMyAcceptedOrders(); // Escuchamos los pedidos que ya hemos aceptado.
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los datos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAllRecipes() async {
    try {
      final recipes = await _recipeRepository.getAllRecipes();
      allRecipes.assignAll(recipes);
    } catch (e) {
      // El error general se maneja en loadInitialData
      rethrow;
    }
  }

  void _listenForMyAgreements() {
    _agreementsSubscription?.cancel();
    final kitchenId = _sessionController.userProfile.value?.id;
    if (kitchenId == null) return;

    _agreementsSubscription = _agreementRepository.getAgreementsStreamByKitchen(kitchenId).listen((agreements) {
      myAgreements.assignAll(agreements);
      // Ya no es necesario llamar al filtro aquí, el worker 'everAll' se encargará.
      // _filterMarketplaceRecipes(); 
    }, onError: (e) {
      Get.snackbar('Error de Conexión', 'No se pudo escuchar los convenios: $e');
    });
  }

  void _updateMarketplaceAndOrders() {
    // 1. Filtramos las recetas del marketplace (excluyendo las rechazadas)
    final rejectedRecipeIds = myAgreements
        .where((a) => a.status == AgreementStatus.rejected)
        .map((a) => a.recipeId)
        .toSet();

    marketplaceRecipes.assignAll(allRecipes.where((r) => !rejectedRecipeIds.contains(r.id)));

    // 2. Obtenemos las recetas que SÍ tenemos aprobadas
    final licensedRecipeIds = myAgreements
        .where((a) => a.status == AgreementStatus.approved)
        .map((a) => a.recipeId)
        .toList();

    // ← AGREGAR ESTOS LOGS
    print('🔍 DEBUG: Total agreements: ${myAgreements.length}');
    print('🔍 DEBUG: Approved agreements: ${licensedRecipeIds.length}');
    print('🔍 DEBUG: Licensed recipe IDs: $licensedRecipeIds');

    // 3. Reiniciamos la escucha de pedidos pendientes con la nueva lista de recetas licenciadas
    _listenForPendingOrders(licensedRecipeIds);
  }

  void _listenForPendingOrders(List<String> licensedRecipeIds) {
    print('🔍 DEBUG: Listening for pending orders with recipes: $licensedRecipeIds');
    
    _pendingOrdersSubscription?.cancel();
    if (licensedRecipeIds.isNotEmpty) {
      _pendingOrdersSubscription = _orderRepository.getPendingOrdersStream(licensedRecipeIds).listen((orders) {
        print('🔍 DEBUG: Received ${orders.length} pending orders');
        orders.forEach((order) {
          print('   - Order ID: ${order.id}, Recipe: ${order.recipeId}, Status: ${order.status}');
        });
        pendingOrders.assignAll(orders);
      }, onError: (e) {
        print('❌ DEBUG: Error listening to pending orders: $e');
        Get.snackbar('Error de Conexión', 'No se pudo escuchar los pedidos pendientes: $e');
      });
    } else {
      print('⚠️ DEBUG: No licensed recipes, clearing pending orders');
      pendingOrders.clear();
    }
  }

  void _listenForMyAcceptedOrders() {
    _kitchenOrdersSubscription?.cancel();
    final kitchenId = _sessionController.userProfile.value!.id;
    _kitchenOrdersSubscription = _orderRepository.getKitchenOrdersStream(kitchenId).listen((orders) {
      // Filtramos para mostrar solo los que están en progreso
      activeOrders.assignAll(orders.where((o) =>
          o.status == OrderStatus.accepted ||
          o.status == OrderStatus.inPreparation ||
          o.status == OrderStatus.outForDelivery).toList());
    }, onError: (e) {
      Get.snackbar('Error de Conexión', 'No se pudo escuchar los pedidos de la cocina: $e');
    });
  }

  /// Acepta un pedido. Devuelve `true` si tiene éxito, `false` si falla.
  /// La UI es responsable de mostrar el feedback al usuario.
  Future<bool> acceptOrder(OrderEntity order) async {
    isAcceptingOrder[order.id] = true;
    try {
      await _orderRepository.acceptOrder(
        orderId: order.id,
        kitchenId: _sessionController.userProfile.value!.id,
      );
      return true; // Éxito
    } catch (e) {
      // Simplemente capturamos cualquier error y devolvemos false.
      return false; // Fallo
    } finally {
      isAcceptingOrder[order.id] = false;
    }
  }

  Future<void> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    try {
      await _orderRepository.updateOrderStatus(orderId: orderId, status: newStatus);
      Get.snackbar('Estado Actualizado', 'El pedido ahora está en estado: ${newStatus.name}');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el estado del pedido: $e');
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
      // No es necesario recargar, el stream de convenios actualizará la UI automáticamente.
      Get.snackbar('Solicitud Enviada', 'El creador ha sido notificado.');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo enviar la solicitud: $e');
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