import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/presentation/widgets/customer_recipe_detail_dialog.dart';

class RecipeCardClient extends StatelessWidget {
  final RecipeEntity recipe;

  const RecipeCardClient({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return GestureDetector(
      onTap: () {
        Get.dialog(CustomerRecipeDetailDialog(recipe: recipe));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildInfoSection(context, cartController),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: 180,
        width: double.infinity,
        color: const Color(0xFF2A2A2A),
        child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
            ? Image.network(
                recipe.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, CartController cartController) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  recipe.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${recipe.basePrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF00FFB8),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recipe.description ?? 'Sin descripción.',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => cartController.addItem(recipe),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFB8),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_shopping_cart_outlined, color: Colors.black),
            label: const Text('Añadir al Carrito', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(Icons.menu_book, size: 60, color: Colors.white.withOpacity(0.3)),
    );
  }
}