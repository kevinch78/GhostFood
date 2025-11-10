import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/profile_entity.dart';
import 'package:ghost_food/presentation/controllers/edit_profile_controller.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:ghost_food/presentation/widgets/animated_flame_button.dart';

class EditProfileForm extends StatelessWidget {
  const EditProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Get.put() para crear una instancia del controlador para este formulario.
    // Se eliminará automáticamente cuando el widget se destruya.
    final controller = Get.put(EditProfileController());
    final userRole = Get.find<SessionController>().userProfile.value?.role;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Editar Perfil',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // --- SECCIÓN DE INFORMACIÓN PERSONAL ---
          _buildSectionTitle('Información Personal'),
          _buildTextField(controller.nameController, 'Nombre Completo'),

          
          const SizedBox(height: 24),

          // --- SECCIÓN DE COCINERO (si aplica) ---
          if (userRole == UserRole.cocinero) ...[
            _buildSectionTitle('Información de Cocina'),
            _buildTextField(controller.kitchenNameController, 'Nombre de la Cocina'),
            _buildTextField(controller.kitchenDescController, 'Descripción de la Cocina', maxLines: 3),
            const SizedBox(height: 24),
          ],

          // --- SECCIÓN DE PREFERENCIAS (para la IA) ---
          _buildSectionTitle('Preferencias Culinarias (para GhostChef AI)'),
          _buildTextField(controller.cityController, 'Tu Ciudad', hint: 'Ej: Bogotá, Colombia'),
          if (userRole == UserRole.cliente) ...[
            const SizedBox(height: 16),
            _buildTextField(controller.allergiesController, 'Alergias', hint: 'Separadas por comas. Ej: maní, mariscos'),
            _buildTextField(controller.dislikesController, 'Disgustos', hint: 'Separados por comas. Ej: cilantro, cebolla'),
          ],

          const SizedBox(height: 32),

          Obx(() => AnimatedFlameButton(
                text: 'Guardar Cambios',
                onTap: controller.saveProfile,
                isLoading: controller.isLoading.value,
              )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF00FFB8),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00FFB8), width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }
}