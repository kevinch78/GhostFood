import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/presentation/controllers/create_recipe_controller.dart';

class CreateRecipePage extends StatelessWidget {
  final RecipeEntity? recipe;
  const CreateRecipePage({super.key, this.recipe});

  @override
  Widget build(BuildContext context) {
    // Pasamos la receta (si existe) al controlador al inyectarlo.
    final controller = Get.put(CreateRecipeController(recipe: recipe));

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1612),
        // El título ahora es dinámico
        title: Text(
          controller.isEditMode.value ? 'Editar Receta' : 'Crear Nueva Receta',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(controller),
              const SizedBox(height: 24),
              _buildTextField(
                controller: controller.nameController,
                label: 'Nombre de la Receta',
                icon: Icons.restaurant_menu,
              ),
              _buildTextField(
                controller: controller.descriptionController,
                label: 'Descripción Corta',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              _buildTextField(
                controller: controller.priceController,
                label: 'Precio Sugerido',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'El precio es requerido.';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Ingresa un precio válido.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: controller.categoryController,
                label: 'Categoría (ej. Italiana, Postres)',
                icon: Icons.category_outlined,
              ),
              _buildTextField(
                controller: controller.ingredientsController,
                label: 'Ingredientes (separados por coma)',
                icon: Icons.local_grocery_store_outlined,
                maxLines: 4,
              ),
              _buildTextField(
                controller: controller.stepsController,
                label: 'Pasos de Preparación (separados por punto)',
                icon: Icons.format_list_numbered,
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton.icon(
                    onPressed: controller.isSaving.value ? null : controller.saveRecipe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFB8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: controller.isSaving.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.save),
                    label: Obx(() => Text(
                      controller.isSaving.value
                          ? 'Guardando...'
                          : (controller.isEditMode.value ? 'Actualizar Receta' : 'Guardar Receta'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )),
                  )),
              // Mostramos el botón de eliminar solo en modo edición
              if (controller.isEditMode.value) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(context, controller),
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                  label: const Text(
                    'Eliminar Receta',
                    style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold),
                    ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(CreateRecipeController controller) {
    return GestureDetector(
      onTap: controller.pickImage,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Obx(() {
            if (controller.imageBytes.value != null) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(controller.imageBytes.value!, fit: BoxFit.cover),
              );
            } else if (controller.existingImageUrl.value != null) {
              // Si estamos editando y hay una imagen existente, la mostramos.
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(controller.existingImageUrl.value!, fit: BoxFit.cover),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.white.withOpacity(0.5), size: 40),
                  const SizedBox(height: 8),
                  Text('Añadir imagen', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                ],
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: const Color(0xFF00FFB8)),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00FFB8), width: 2),
          ),
        ),
        validator: validator ?? (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Este campo es requerido.';
          }
          return null;
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CreateRecipeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
            SizedBox(width: 8),
            Text('¿Eliminar Receta?', style: TextStyle(color: Color(0xFFFF6B6B))),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar esta receta? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton.icon(
            onPressed: controller.deleteRecipe,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}