import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/repositories/ai_recipe_repository.dart';
import 'package:ghost_food/presentation/controllers/ai_chef_controller.dart';

class AiChefPage extends StatefulWidget {
  const AiChefPage({super.key});

  @override
  State<AiChefPage> createState() => _AiChefPageState();
}

class _AiChefPageState extends State<AiChefPage> {
  final controller = Get.put(AiChefController());

  @override
  void initState() {
    super.initState();
    // Escuchamos los cambios en la receta actual para mostrar el diálogo.
    // Usamos 'ever' de GetX para reaccionar a los cambios en el observable.
    ever(controller.currentRecipe, _handleRecipeDialog);
  }

  void _handleRecipeDialog(RecipeData? recipe) {
    // Si hay una receta y no hay un diálogo abierto, lo mostramos.
    if (recipe != null && Get.isDialogOpen != true) {      
      Get.dialog(
        _RecipeDialog(
          recipe: recipe,
          onOrder: () async {
            Get.back(); // Cierra el diálogo
            final success = await controller.createOrderFromRecipe(recipe);
            if (success && mounted) {
              Get.snackbar(
                '¡Pedido Creado! 🎉',
                'Tu receta "${recipe.nombre}" está esperando a que una cocina la haga realidad.',
                backgroundColor: const Color(0xFF4CAF50),
                colorText: Colors.white,
                icon: const Icon(Icons.check_circle, color: Colors.white),
              );
            }
            // El controlador se encarga de mostrar el snackbar de error.
          },
        ),
        barrierDismissible: false,
      ).whenComplete(() {
        // Esta es la forma correcta de ejecutar código cuando el diálogo se cierra.
        // Limpiamos la receta para que el diálogo no se vuelva a abrir.
        controller.currentRecipe.value = null;
      }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FFB8), Color(0xFF00D9A3)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.black),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GhostChef AI',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Tu asistente culinario',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => _showClearChatDialog(context, controller),
            tooltip: 'Nueva conversación',
          ),
        ],
      ),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
                if (controller.isLoading.value)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF00FFB8),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'GhostChef está pensando...',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                _buildInputArea(controller),
              ],
            ),
            // Overlay de carga para la creación del pedido
            if (controller.isCreatingOrder.value)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF00FFB8)),
                      SizedBox(height: 16),
                      Text('Creando tu pedido...', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF00FFB8), Color(0xFF00D9A3)],
                )
              : null,
          color: isUser ? null : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(AiChefController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Describe tu receta ideal...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF0D0D0D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.sendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                    backgroundColor: const Color(0xFF00FFB8),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade700,
                  ),
                  child: const Icon(Icons.send),
                )),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog(BuildContext context, AiChefController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Nueva conversación?', style: TextStyle(color: Colors.white)),
        content: const Text('Esto borrará el historial actual del chat.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearChat();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFB8), foregroundColor: Colors.black),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

/// Un widget de diálogo para mostrar la receta generada por la IA.
class _RecipeDialog extends StatelessWidget {
  final RecipeData recipe;
  final VoidCallback onOrder;

  const _RecipeDialog({required this.recipe, required this.onOrder});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
          onPressed: onOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FFB8),
            foregroundColor: Colors.black,
          ),
          icon: const Icon(Icons.outdoor_grill_outlined),
          label: const Text('Hacer Pedido'),
        ),
      ],
    );
  }

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
}