import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/agreement_entity.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/domain/repositories/recipe_repository.dart';

class MarketPlaceController extends GetxController {
  final RecipeRepository _recipeRepository = Get.find();

  final isLoading = false.obs;
  final allRecipes = <RecipeEntity>[].obs;
  final marketplaceRecipes = <RecipeEntity>[].obs;

  Future<void> loadAllRecipes() async {
    try {
      isLoading.value = true;
      final recipes = await _recipeRepository.getAllRecipes();
      allRecipes.assignAll(recipes);
    } finally {
      isLoading.value = false;
    }
  }

  void updateMarketplaceRecipes(List<AgreementEntity> myAgreements) {
    final rejectedIds = myAgreements
        .where((a) => a.status == AgreementStatus.rejected)
        .map((a) => a.recipeId)
        .toSet();

    marketplaceRecipes.assignAll(
      allRecipes.where((r) => !rejectedIds.contains(r.id) && r.type != RecipeType.aiGenerated),
    );
  }
}
