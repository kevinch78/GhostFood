import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/repositories/ai_recipe_repository.dart';
import 'package:ghost_food/presentation/controllers/ai_chef_controller.dart';

class AiChefPage extends StatelessWidget {
  const AiChefPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiChefController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
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
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageBubble(message);
                  },
                )),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
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
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          _buildInputArea(controller),
        ],
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