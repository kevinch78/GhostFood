import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/domain/repositories/recipe_repository.dart';

class ClientHomeController extends GetxController {
  // Cambiamos el repositorio de productos por el de recetas
  final RecipeRepository _recipeRepository = Get.find<RecipeRepository>();

  // --- STATE VARIABLES ---
  final RxBool isLoading = true.obs;
  // Ahora manejamos listas de RecipeEntity
  final RxList<RecipeEntity> _allRecipes = <RecipeEntity>[].obs;
  final RxList<RecipeEntity> filteredRecipes = <RecipeEntity>[].obs;
  final RxList<String> categories = <String>['Todos'].obs;
  final RxString selectedCategory = 'Todos'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();

    // Cambia everAll por ever solo en selectedCategory
    ever(selectedCategory, (_) {
      _updateFilteredProducts();
    });
  }

  // --- ACTIONS ---

  /// Carga todos los productos disponibles de todos los cocineros.
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      // Obtenemos todas las recetas de la plataforma.
      final recipes = await _recipeRepository.getAllRecipes();
      _allRecipes.assignAll(recipes);

      // Extraemos las categorías únicas de los productos cargados.
      final recipeCategories = recipes
          .map((r) => r.category)
          .whereType<String>()
          .where((c) => c.isNotEmpty)
          .toSet();
      categories.assignAll(['Todos', ...recipeCategories]);

      // Actualiza los productos filtrados después de cargar
      _updateFilteredProducts();

    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las recetas: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cambia la categoría seleccionada.
  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  /// Actualiza la lista de productos filtrados según la categoría seleccionada.
  void _updateFilteredProducts() {
    if (selectedCategory.value == 'Todos') {
      filteredRecipes.assignAll(_allRecipes);
    } else {
      filteredRecipes.assignAll(
        _allRecipes.where((p) => p.category == selectedCategory.value).toList(),
      );
    }
  }
}