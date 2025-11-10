import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/agreement_entity.dart';
import 'package:ghost_food/presentation/controllers/agreement_controller.dart';
import 'package:ghost_food/presentation/controllers/cook_home_controller.dart';
import 'package:ghost_food/presentation/controllers/market_place_controller.dart';
import 'package:ghost_food/presentation/pages/recipe_detail_page.dart';
import 'package:ghost_food/presentation/widgets/empty_state.dart';

class RecipeMarketplaceTab extends StatelessWidget {
  final CookHomeController cookHomeController;
  final MarketPlaceController marketplaceController;
  final AgreementController agreementController;

  const RecipeMarketplaceTab({
    super.key,
    required this.cookHomeController,
    required this.marketplaceController,
    required this.agreementController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (cookHomeController.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
      }

      if (marketplaceController.marketplaceRecipes.isEmpty) {
        return const EmptyState(
          icon: Icons.restaurant_menu_outlined,
          title: 'Sin recetas disponibles',
          subtitle: 'Las recetas de creadores aparecerán aquí.',
        );
      }

      return RefreshIndicator(
        onRefresh: cookHomeController.loadInitialData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: marketplaceController.marketplaceRecipes.length,
          itemBuilder: (context, index) {
            final recipe = marketplaceController.marketplaceRecipes[index];
            final status = agreementController.getAgreementStatusForRecipe(recipe.id);
            final isRequesting = agreementController.isRequesting[recipe.id] ?? false;
            final isApproved = status == AgreementStatus.approved;

            return GestureDetector(
              onTap: isApproved
                  ? () => Get.to(() => RecipeDetailPage(recipe: recipe))
                  : null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                color: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
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
                          if (recipe.creatorId !=
                              agreementController.getCurrentUserId())
                            _buildActionButton(
                              status: status,
                              isRequesting: isRequesting,
                              onPressed: () =>
                                  agreementController.requestAgreement(recipe),
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
