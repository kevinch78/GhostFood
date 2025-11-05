import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/auth/auth_service.dart';
import 'package:ghost_food/domain/entities/agreement_entity.dart';
import 'package:ghost_food/presentation/controllers/creator_home_controller.dart';
import 'package:ghost_food/presentation/widgets/empty_state.dart';
import 'package:ghost_food/presentation/widgets/custom_app_bar.dart';
import 'package:ghost_food/presentation/pages/create_recipe_page.dart';

class CreatorHomePage extends StatefulWidget {
  const CreatorHomePage({super.key});

  @override
  State<CreatorHomePage> createState() => _CreatorHomePageState();
}

class _CreatorHomePageState extends State<CreatorHomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inyectamos el controlador para esta vista.
    final controller = Get.put(CreatorHomeController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: CustomAppBar(
          title: 'Panel del Creador',
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
                  _buildRecipesView(controller),
                  _buildAgreementsView(controller),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Ya no necesitamos recargar los datos con .then()
            // El controlador de creación/edición se encargará de actualizar la lista localmente o el stream lo detectará.
            Get.to(() => const CreateRecipePage(), transition: Transition.downToUp);
          },
          backgroundColor: const Color(0xFF00FFB8),
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text('Nueva Receta', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildTabBar(CreatorHomeController controller) {
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
        unselectedLabelColor: Colors.white54,
        tabs: [
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book),
                SizedBox(width: 8),
                Text('Mis Recetas'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  final pendingCount = controller.agreements.where((a) => a.status == AgreementStatus.requested).length;
                  return Badge(
                    label: Text('$pendingCount'),
                    isLabelVisible: pendingCount > 0,
                    child: const Icon(Icons.handshake_outlined),
                  );
                }),
                const SizedBox(width: 8),
                const Text('Solicitudes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesView(CreatorHomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
      }
      if (controller.recipes.isEmpty) {
        return const EmptyState(
          icon: Icons.lightbulb_outline,
          title: 'Aún no tienes recetas',
          subtitle: 'Toca el botón "+" para crear tu primera obra maestra.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadData,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: controller.recipes.length,
          itemBuilder: (context, index) {
            final recipe = controller.recipes[index];
            return GestureDetector(
              // Eliminamos el .then() aquí también por la misma razón.
              onTap: () => Get.to(() => CreateRecipePage(recipe: recipe)),
              child: Card(
                clipBehavior: Clip.antiAlias,
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, color: Colors.white30, size: 40);
                          },
                        ),
                      ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Text(
                        recipe.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        'Precio Sugerido: \$${recipe.basePrice.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
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

  Widget _buildAgreementsView(CreatorHomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
      }
      if (controller.agreements.isEmpty) {
        return const EmptyState(
          icon: Icons.notifications_none,
          title: 'Sin solicitudes',
          subtitle: 'Aquí verás las solicitudes de las cocinas para preparar tus recetas.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadData,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: controller.agreements.length,
          itemBuilder: (context, index) {
            final agreement = controller.agreements[index];
            return _buildAgreementCard(controller, agreement);
          },
        ),
      );
    });
  }

  Widget _buildAgreementCard(CreatorHomeController controller, AgreementEntity agreement) {
    final isUpdating = controller.isUpdatingAgreement[agreement.id] ?? false;

    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: agreement.status == AgreementStatus.requested ? const Color(0xFF00FFB8).withOpacity(0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                children: [
                  TextSpan(
                    text: agreement.kitchen?.fullName ?? 'Una cocina',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' quiere cocinar tu receta '),
                  TextSpan(
                    text: agreement.recipe?.name ?? 'desconocida',
                    style: const TextStyle(color: Color(0xFF00FFB8), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (agreement.status == AgreementStatus.requested)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isUpdating ? null : () => controller.updateAgreementStatus(agreement.id, AgreementStatus.approved),
                      icon: const Icon(Icons.check),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isUpdating ? null : () => controller.updateAgreementStatus(agreement.id, AgreementStatus.rejected),
                      icon: const Icon(Icons.close),
                      label: const Text('Rechazar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: agreement.status == AgreementStatus.approved ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  agreement.status == AgreementStatus.approved ? 'APROBADO' : 'RECHAZADO',
                  style: TextStyle(
                    color: agreement.status == AgreementStatus.approved ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}