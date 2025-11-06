import 'package:ghost_food/data/repositories/exceptions.dart';
import 'package:ghost_food/domain/repositories/ai_recipe_repository.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException; // Ocultamos AuthException de Supabase

class AiRecipeRepositoryImpl implements AiRecipeRepository {
  final SupabaseClient _client;
  final SessionController _sessionController = Get.find();

  AiRecipeRepositoryImpl(this._client);

  @override
  Future<AiChatResponse> sendMessage({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
  }) async {
    try {
      final userId = _sessionController.userProfile.value?.id;
      if (userId == null) {
        throw AuthException('No hay usuario autenticado');
      }

      final response = await _client.functions.invoke(
        'generate-recipe',
        body: {
          'userId': userId,
          'userMessage': userMessage,
          'conversationHistory': conversationHistory.map((m) => m.toJson()).toList(),
        },
      );

      if (response.status != 200) {
        throw ServerException('Error en la función: ${response.status} ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;

      RecipeData? recipeData;
      if (data['recipe'] != null) {
        recipeData = RecipeData.fromJson(data['recipe']);
      }

      return AiChatResponse(
        success: true,
        message: data['message'],
        recipe: recipeData,
      );
    } catch (e) {
      throw ServerException('Error al comunicarse con la IA: $e');
    }
  }
}