import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/data/repositories/exceptions.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/domain/repositories/ai_recipe_repository.dart';
import 'package:ghost_food/domain/repositories/order_repository.dart';
import 'package:ghost_food/domain/repositories/recipe_repository.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';

class AiChefController extends GetxController {
  final AiRecipeRepository _aiRepository = Get.find();
  final RecipeRepository _recipeRepository = Get.find();
  final OrderRepository _orderRepository = Get.find();
  final SessionController _sessionController = Get.find();

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Estado
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final currentRecipe = Rx<RecipeData?>(null);
  final isCreatingOrder = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Mensaje de bienvenida
    _addMessage(ChatMessage(
      role: 'assistant',
      content: '¡Hola! 👋 Soy GhostChef, tu asistente culinario personal. '
          'Describe tu antojo o el tipo de comida que te gustaría explorar hoy.',
    ));
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    // Agregar mensaje del usuario
    _addMessage(ChatMessage(role: 'user', content: text));
    messageController.clear();

    isLoading.value = true;

    // Construir el contexto del usuario desde el perfil de sesión
    final profile = _sessionController.userProfile.value;
    final userContext = StringBuffer();
    if (profile != null) {
      if (profile.fullName != null && profile.fullName!.isNotEmpty) userContext.writeln('- Nombre: ${profile.fullName}');
      if (profile.locationCity != null && profile.locationCity!.isNotEmpty) userContext.writeln('- Ubicación: ${profile.locationCity}');
      if (profile.allergies != null && profile.allergies!.isNotEmpty) userContext.writeln('- Alergias: ${profile.allergies!.join(', ')}');
      if (profile.dislikes != null && profile.dislikes!.isNotEmpty) userContext.writeln('- Disgustos: ${profile.dislikes!.join(', ')}');
    }

    // Si el contexto está vacío, usamos un mensaje genérico.
    final finalContext = userContext.toString().isEmpty ? 'No hay información adicional del usuario.' : userContext.toString();

    try {
      // Enviar a la IA
      final response = await _aiRepository.sendMessage(
        userMessage: '$text\n\n--- Contexto del Usuario ---\n$finalContext',
        conversationHistory: messages.toList(),
      );

      // Agregar respuesta de la IA
      _addMessage(ChatMessage(
        role: 'assistant',
        content: response.message,
      ));

      // Si la IA generó una receta completa, la mostramos
      if (response.recipe != null) {
        currentRecipe.value = response.recipe;
        // La UI ahora reaccionará a este cambio y mostrará el diálogo.
      }
    } on ServerException catch (e) {
      _showErrorSnackbar('Error de GhostChef', e.message);
    } catch (e) {
      _showErrorSnackbar('Error de Conexión', 'No se pudo conectar con GhostChef: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _addMessage(ChatMessage message) {
    messages.add(message);
    // Scroll al final para que el último mensaje siempre sea visible
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Intenta crear un pedido a partir de una receta de la IA.
  ///
  /// Devuelve `true` si el pedido se creó con éxito, `false` en caso contrario.
  /// La UI es responsable de mostrar feedback (loading, snackbars) basado en
  /// el estado `isCreatingOrder` y el resultado de este Future.
  Future<bool> createOrderFromRecipe(RecipeData recipeData) async {
    isCreatingOrder.value = true;

    try {
      final userId = _sessionController.userProfile.value?.id;
      if (userId == null) throw AuthException('No hay usuario autenticado');

      // 1. Guardar la receta en la BD
      final recipeToSave = RecipeEntity(
        id: '', // Se generará automáticamente
        creatorId: userId, // El usuario que la creó con IA es el "creador"
        name: recipeData.nombre,
        description: recipeData.descripcion,
        ingredients: recipeData.ingredientes,
        steps: recipeData.pasos,
        imageUrl: null, // Sin imagen por ahora
        category: recipeData.categoria,
        basePrice: recipeData.precioSugerido.toDouble(), // ← USAR PRECIO DE LA IA
        type: RecipeType.aiGenerated,
        createdAt: DateTime.now(),
      );

      final savedRecipe = await _recipeRepository.createRecipe(recipeToSave);

      // 2. Crear el pedido a partir de la receta guardada
      await _orderRepository.createOrderFromCartItem(
        CartItem.fromRecipe(savedRecipe),
      );

      return true; // Éxito
    } on ServerException catch (e) {
      _showErrorSnackbar('Error al crear pedido', e.message);
      return false; // Fallo
    } catch (e) {
      _showErrorSnackbar('Error inesperado', 'No se pudo crear el pedido: $e');
      return false; // Fallo
    } finally {
      isCreatingOrder.value = false;
    }
  }

  void clearChat() {
    // Al limpiar el chat, también nos aseguramos de ocultar cualquier diálogo de receta.
    messages.clear();
    currentRecipe.value = null;
    _addMessage(ChatMessage(
      role: 'assistant',
      content: '¡Empecemos de nuevo! ¿Qué te gustaría cocinar hoy?',
    ));
  }  

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(title, message, backgroundColor: Colors.redAccent, colorText: Colors.white);
  }
}