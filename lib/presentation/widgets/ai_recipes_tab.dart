import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/presentation/controllers/cook_home_controller.dart';
import 'package:ghost_food/presentation/controllers/market_place_controller.dart';
import 'package:ghost_food/presentation/pages/recipe_detail_page.dart';
import 'package:ghost_food/presentation/widgets/empty_state.dart';

class AiRecipesTab extends StatelessWidget {
  final CookHomeController cookHomeController;
  final MarketPlaceController marketplaceController;

  const AiRecipesTab({
    super.key,
    required this.cookHomeController,
    required this.marketplaceController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (cookHomeController.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
      }

      final aiRecipes = marketplaceController.allRecipes
          .where((r) => r.type == RecipeType.aiGenerated)
          .toList();

      if (aiRecipes.isEmpty) {
        return const EmptyState(
          icon: Icons.auto_awesome_outlined,
          title: 'Sin recetas de IA aún',
          subtitle: 'Las recetas generadas por GhostChef aparecerán aquí.',
        );
      }

      return RefreshIndicator(
        onRefresh: cookHomeController.loadInitialData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: aiRecipes.length,
          itemBuilder: (context, index) {
            final recipe = aiRecipes[index];
            return GestureDetector(
              onTap: () => Get.to(() => RecipeDetailPage(recipe: recipe)),
              child: Card(
                clipBehavior: Clip.antiAlias,
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF00FFB8).withOpacity(0.3),
                    width: 2,
                  ),
                ),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00FFB8).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.auto_awesome,
                                        size: 14,
                                        color: Color(0xFF00FFB8)),
                                    SizedBox(width: 4),
                                    Text(
                                      'IA',
                                      style: TextStyle(
                                        color: Color(0xFF00FFB8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  recipe.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (recipe.description != null)
                            Text(
                              recipe.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Precio Sugerido: \$${recipe.basePrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFF00FFB8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FFB8).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Color(0xFF00FFB8),
                                    size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Uso libre • Sin permisos necesarios',
                                    style: TextStyle(
                                      color: Color(0xFF00FFB8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}
