import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';
import 'package:google_fonts/google_fonts.dart';

/// Un diálogo que muestra una vista simplificada de una receta para el cliente.
///
/// Muestra el nombre, descripción, precio y un botón para añadir al carrito.
class CustomerRecipeDetailDialog extends StatelessWidget {
  final RecipeEntity recipe;

  const CustomerRecipeDetailDialog({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    // Encontramos el CartController para poder añadir items.
    final CartController cartController = Get.find();

    return Dialog(
      backgroundColor: const Color(0xFF1C1C1C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      clipBehavior: Clip.antiAlias, // Importante para que la imagen respete los bordes redondeados
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Sección de Imagen (si existe) ---
          if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
            SizedBox(
              height: 180,
              child: Image.network(
                recipe.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white24,
                  size: 60,
                ),
              ),
            ),

          // --- Contenido de Texto ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Título de la Receta ---
                Text(
                  recipe.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // --- Descripción ---
                Text(
                  recipe.description ?? 'Sin descripción disponible.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // --- Precio y Botón ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${recipe.basePrice.toStringAsFixed(2)}',
                      style: GoogleFonts.lato(
                        color: const Color(0xFF00FFB8),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // 1. Añadir al carrito
                        cartController.addItem(recipe);
                        // 2. Cerrar el diálogo
                        Get.back();
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                      label: const Text('Añadir'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: const Color(0xFF00FFB8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}