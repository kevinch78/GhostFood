import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/auth/auth_service.dart';
import 'package:ghost_food/data/models/order_model.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';
import 'package:ghost_food/presentation/controllers/cook_home_controller.dart';
import 'package:ghost_food/domain/entities/agreement_entity.dart';
import 'package:ghost_food/presentation/controllers/recipe_detail_page.dart';
import 'package:ghost_food/presentation/widgets/custom_app_bar.dart';
import 'package:ghost_food/presentation/widgets/empty_state.dart';

class CookHomePage extends StatefulWidget {
  const CookHomePage({super.key});

  @override
  State<CookHomePage> createState() => _CookHomePageState();
}

class _CookHomePageState extends State<CookHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CookHomeController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: CustomAppBar(
        title: 'Marketplace de Recetas',
        actions: [
          IconButton(
            onPressed: () => Get.find<AuthService>().signOutAndClean(),
            icon: const Icon(Icons.logout, color: Color(0xFFFF6B6B)),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(controller),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecipeMarketplaceView(controller),
                _buildPendingOrdersView(controller),
                _buildActiveOrdersView(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(CookHomeController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF00FFB8),
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          // 🥘 Tab Recetas
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.storefront, size: 20),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Recetas',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          // 📦 Tab Pedidos
          Tab(
            child: Obx(() {
              final pendingCount = controller.pendingOrders.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Badge(
                    label: Text('$pendingCount'),
                    isLabelVisible: pendingCount > 0,
                    child: const Icon(Icons.notifications_active_outlined, size: 20),
                  ),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: Text(
                      'Pedidos',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              );
            }),
          ),

          // 🔥 Tab En Progreso
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.outdoor_grill_outlined, size: 20),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'En Progreso',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeMarketplaceView(CookHomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
      }
      return RefreshIndicator(
        onRefresh: controller.loadInitialData,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: controller.marketplaceRecipes.length,
          itemBuilder: (context, index) {
            final recipe = controller.marketplaceRecipes[index];
            final status = controller.getAgreementStatusForRecipe(recipe.id);
            final isRequesting = controller.isRequesting[recipe.id] ?? false;
            final isApproved = status == AgreementStatus.approved;

            return GestureDetector(
              onTap: isApproved ? () => Get.to(() => RecipeDetailPage(recipe: recipe)) : null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (recipe.imageUrl != null)
                      Image.network(recipe.imageUrl!,
                          height: 150, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                              'Precio Sugerido: \$${recipe.basePrice.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 16),
                          if (recipe.creatorId != controller.getCurrentUserId())
                            _buildActionButton(
                              status: status,
                              isRequesting: isRequesting,
                              onPressed: () =>
                                  controller.requestAgreement(recipe),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPendingOrdersView(CookHomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
      }
      if (controller.pendingOrders.isEmpty) {
        return const EmptyState(
          icon: Icons.notifications_off_outlined,
          title: 'Sin pedidos pendientes',
          subtitle:
              'Aquí aparecerán los nuevos pedidos de tus recetas licenciadas.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadInitialData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.pendingOrders.length,
          itemBuilder: (context, index) {
            final order = controller.pendingOrders[index];
            return _buildPendingOrderCard(controller, order);
          },
        ),
      );
    });
  }

  Widget _buildActiveOrdersView(CookHomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
      }
      if (controller.activeOrders.isEmpty) {
        return const EmptyState(
          icon: Icons.no_food_outlined,
          title: 'Sin pedidos activos',
          subtitle: 'Acepta un pedido pendiente para que aparezca aquí.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadInitialData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.activeOrders.length,
          itemBuilder: (context, index) {
            final order = controller.activeOrders[index];
            return _buildActiveOrderCard(controller, order);
          },
        ),
      );
    });
  }

  Widget _buildActiveOrderCard(
      CookHomeController controller, OrderEntity order) {
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
            _buildStatusChip(order.status),
            const SizedBox(height: 16),
            if (order.status == OrderStatus.accepted)
              ElevatedButton.icon(
                onPressed: () => controller.updateOrderStatus(
                    order.id, OrderStatus.inPreparation),
                icon: const Icon(Icons.soup_kitchen_outlined),
                label: const Text('Marcar como "En Preparación"'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44)),
              ),
            if (order.status == OrderStatus.inPreparation)
              ElevatedButton.icon(
                onPressed: () => controller.updateOrderStatus(
                    order.id, OrderStatus.outForDelivery),
                icon: const Icon(Icons.delivery_dining_outlined),
                label: const Text('Marcar como "Enviado"'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44)),
              ),
            if (order.status == OrderStatus.outForDelivery)
              ElevatedButton.icon(
                onPressed: () => controller.updateOrderStatus(
                    order.id, OrderStatus.delivered),
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

  Widget _buildStatusChip(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF00FFB8).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        OrderModel.statusToString(status)
                .replaceAll('_', ' ')
                .capitalizeFirst ??
            '',
        style: const TextStyle(
            color: Color(0xFF00FFB8), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPendingOrderCard(
      CookHomeController controller, OrderEntity order) {
    final isAccepting = controller.isAcceptingOrder[order.id] ?? false;
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: const Color(0xFF00FFB8).withOpacity(0.5), width: 1),
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
              onPressed: isAccepting ? null : () => _handleAcceptOrder(controller, order),
              icon: isAccepting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
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

  /// Maneja la lógica de la UI para aceptar un pedido.
  void _handleAcceptOrder(CookHomeController controller, OrderEntity order) async {
    final success = await controller.acceptOrder(order);

    // Usamos 'context.mounted' para asegurarnos de que el widget todavía está en el árbol
    // antes de mostrar un SnackBar. Es una buena práctica en métodos async.
    if (!context.mounted) return;

    if (success) {
      Get.snackbar(
        '¡Pedido Aceptado!',
        'Prepara "${order.recipe?.name ?? 'receta desconocida'}" para el cliente.',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } else {
      Get.snackbar(
        'Error al aceptar',
        'El pedido no pudo ser aceptado. Es posible que ya haya sido tomado por otra cocina.',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  Widget _buildActionButton({
    required AgreementStatus? status,
    required bool isRequesting,
    required VoidCallback onPressed,
  }) {
    if (isRequesting) {
      return const ElevatedButton(
        onPressed: null,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (status) {
      case AgreementStatus.approved:
        return const ElevatedButton(
          onPressed: null,
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.green),
          ),
          child: Text('Aprobado'),
        );
      case AgreementStatus.requested:
        return const ElevatedButton(
          onPressed: null,
          child: Text('Pendiente'),
        );
      case AgreementStatus.rejected:
        return const ElevatedButton(
          onPressed: null,
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.red),
          ),
          child: Text('Rechazado'),
        );
      default:
        return ElevatedButton(
          onPressed: onPressed,
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Color(0xFF00FFB8)),
          ),
          child: const Text('Solicitar Permiso'),
        );
    }
  }
}
