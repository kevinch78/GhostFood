import 'dart:typed_data';

import 'package:ghost_food/domain/entities/recipe_entity.dart';

/// La interfaz (contrato) para manejar las operaciones de las recetas.
/// Define QUÉ se puede hacer, pero no CÓMO.
abstract class RecipeRepository {
  Future<List<RecipeEntity>> getRecipesByCreator(String creatorId);
  
  Future<List<RecipeEntity>> getAllRecipes();

  Future<RecipeEntity> createRecipe(RecipeEntity recipe);

  Future<RecipeEntity> updateRecipe(RecipeEntity recipe);

  Future<void> deleteRecipe(String recipeId);

  Future<String> uploadRecipeImage({required Uint8List imageBytes, required String fileName, required String creatorId});
}