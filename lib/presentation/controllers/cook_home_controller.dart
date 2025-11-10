import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/agreement_entity.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/presentation/controllers/active_orders_controller.dart';
import 'package:ghost_food/presentation/controllers/agreement_controller.dart';
import 'package:ghost_food/presentation/controllers/market_place_controller.dart';

/// Este controlador actúa como un orquestador para la pantalla principal del cocinero.
/// Su única responsabilidad es inicializar los controladores hijos y coordinar
/// la comunicación entre ellos.
class CookHomeController extends GetxController {
  // 1. Instanciamos los controladores especializados que harán el trabajo pesado.
  // Usamos los nombres de clase correctos que has creado.
  final MarketPlaceController marketplaceController = Get.put(MarketPlaceController());
  final AgreementController agreementController = Get.put(AgreementController());
  final ActiveOrderController orderManagementController = Get.put(ActiveOrderController());

  // El estado de carga principal vive aquí, para mostrar un indicador global.
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();

    // 2. Creamos la comunicación reactiva.
    // Cuando la lista de recetas o de convenios cambie, se ejecutará `_updateDependencies`.
    everAll(
      [marketplaceController.allRecipes, agreementController.myAgreements],
      (_) => _updateDependencies(),
    );
  }

  /// Carga los datos iniciales que son la base para los demás controladores.
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      // Cargamos todas las recetas y empezamos a escuchar los convenios y pedidos activos.
      await marketplaceController.loadAllRecipes();
      agreementController.listenForMyAgreements();
      orderManagementController.listenForMyAcceptedOrders();
    } finally {
      isLoading.value = false;
    }
  }

  /// Orquesta las actualizaciones entre controladores cuando los datos base cambian.
  void _updateDependencies() {
    // Le dice al MarketplaceController que actualice su lista de recetas visibles.
    marketplaceController.updateMarketplaceRecipes(agreementController.myAgreements);

    // Calculamos qué recetas puede cocinar el usuario (aprobadas + IA).
    final licensedIds = agreementController.myAgreements
        .where((a) => a.status == AgreementStatus.approved)
        .map((a) => a.recipeId)
        .toList();

    final aiIds = marketplaceController.allRecipes
        .where((r) => r.type == RecipeType.aiGenerated)
        .map((r) => r.id)
        .toList();

    // Le pasamos la lista de recetas disponibles al controlador de pedidos
    // para que sepa qué pedidos pendientes debe escuchar.
    final availableRecipeIds = [...licensedIds, ...aiIds].toSet().toList();
    orderManagementController.listenForPendingOrders(availableRecipeIds);
  }
}
