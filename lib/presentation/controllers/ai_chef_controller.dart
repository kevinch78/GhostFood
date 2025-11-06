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

    try {
      // Enviar a la IA
      final response = await _aiRepository.sendMessage(
        userMessage: text,
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
        _showRecipeDialog(response.recipe!);
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

  void _showRecipeDialog(RecipeData recipe) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.restaurant_menu, color: Color(0xFF00FFB8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                recipe.nombre,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                recipe.descripcion,
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Categoría'),
              Text(
                recipe.categoria,
                style: const TextStyle(color: Color(0xFF00FFB8)),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Ingredientes'),
              ...recipe.ingredientes.map((ing) => _buildListItem(ing)),
              const SizedBox(height: 16),
              _buildSectionTitle('Pasos'),
              ...recipe.pasos.asMap().entries.map((entry) => _buildStepItem(entry.key + 1, entry.value)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Seguir chateando', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back(); // Cierra el diálogo
              createOrderFromRecipe(recipe);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFB8),
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.outdoor_grill_outlined),
            label: const Text('Hacer Pedido'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> createOrderFromRecipe(RecipeData recipeData) async {
    isCreatingOrder.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB8))),
      barrierDismissible: false,
    );

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
        basePrice: 15000.0, // Precio base sugerido para recetas de IA
        type: RecipeType.aiGenerated,
        createdAt: DateTime.now(),
      );

      final savedRecipe = await _recipeRepository.createRecipe(recipeToSave);

      // 2. Crear el pedido a partir de la receta guardada
      await _orderRepository.createOrderFromCartItem(
        CartItem.fromRecipe(savedRecipe),
      );

      if (Get.isDialogOpen!) Get.back(); // Cierra el diálogo de carga

      Get.snackbar(
        '¡Pedido Creado! 🎉',
        'Tu receta "${recipeData.nombre}" está esperando a que una cocina la haga realidad.',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

    } on ServerException catch (e) {
      if (Get.isDialogOpen!) Get.back();
      _showErrorSnackbar('Error al crear pedido', e.message);
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      _showErrorSnackbar('Error inesperado', 'No se pudo crear el pedido: $e');
    } finally {
      isCreatingOrder.value = false;
    }
  }

  void clearChat() {
    messages.clear();
    currentRecipe.value = null;
    _addMessage(ChatMessage(
      role: 'assistant',
      content: '¡Empecemos de nuevo! ¿Qué te gustaría cocinar hoy?',
    ));
  }

  // --- Widgets y Helpers privados ---

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: const TextStyle(color: Color(0xFF00FFB8), fontWeight: FontWeight.bold, fontSize: 16)),
      );

  Widget _buildListItem(String text) => Padding(
        padding: const EdgeInsets.only(left: 8, top: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('• ', style: TextStyle(color: Color(0xFF00FFB8))),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.9)))),
        ]),
      );

  Widget _buildStepItem(int number, String text) => Padding(
        padding: const EdgeInsets.only(left: 8, top: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$number. ', style: const TextStyle(color: Color(0xFF00FFB8), fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.9)))),
        ]),
      );

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(title, message, backgroundColor: Colors.redAccent, colorText: Colors.white);
  }
}