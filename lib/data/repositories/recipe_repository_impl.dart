import 'dart:typed_data';

import 'package:ghost_food/data/models/recipe_model.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/domain/repositories/recipe_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'exceptions.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final SupabaseClient _client;
  static const String _tableName = 'recipes';
  static const String _storageBucket = 'recipe_images';

  RecipeRepositoryImpl(this._client);

  @override
  Future<RecipeEntity> createRecipe(RecipeEntity recipe) async {
    try {
      final recipeModel = RecipeModel.fromEntity(recipe);
      final dataToInsert = recipeModel.toJson()..remove('id'); // Quitamos el ID para la inserción

      final response = await _client
          .from(_tableName)
          .insert(dataToInsert)
          .select()
          .single();

      return RecipeModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al crear la receta: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _client.from(_tableName).delete().eq('id', recipeId);
    } catch (e) {
      throw ServerException('Error al eliminar la receta: $e');
    }
  }

  @override
  Future<List<RecipeEntity>> getRecipesByCreator(String creatorId) async {
    try {
      final response = await _client.from(_tableName).select().eq('creator_id', creatorId).order('created_at', ascending: false);
      return response.map((json) => RecipeModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Error al obtener las recetas: $e');
    }
  }

  @override
  Future<List<RecipeEntity>> getAllRecipes() async {
    try {
      final response = await _client.from(_tableName).select().order('created_at', ascending: false);
      return response.map((json) => RecipeModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Error al obtener todas las recetas: $e');
    }
  }

  @override
  Future<RecipeEntity> updateRecipe(RecipeEntity recipe) async {
    try {
      final recipeModel = RecipeModel.fromEntity(recipe);
      final response = await _client
          .from(_tableName)
          .update(recipeModel.toJson())
          .eq('id', recipe.id)
          .select()
          .single();
      return RecipeModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al actualizar la receta: $e');
    }
  }

  @override
  Future<String> uploadRecipeImage({required Uint8List imageBytes, required String fileName, required String creatorId}) async {
    try {
      final imagePath = '$creatorId/$fileName';

      await _client.storage.from(_storageBucket).uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _client.storage.from(_storageBucket).getPublicUrl(imagePath);
    } catch (e) {
      throw ServerException('Error al subir la imagen de la receta: $e');
    }
  }
}