import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildImage(),
          Expanded(child: _buildInfo()),
          _buildQuantityControls(controller),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: Container(
        width: 100,
        height: 100,
        color: const Color(0xFF2A2A2A),
        child: item.imageUrl != null && item.imageUrl!.isNotEmpty
            ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.restaurant,
      size: 40,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '\$${item.price.toStringAsFixed(0)} c/u',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
            'Subtotal: \$${item.subtotal.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Color(0xFFFFA726),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(CartController controller) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF00FFAA)),
            onPressed: () => controller.updateQuantity(item.recipeId, item.quantity.value + 1),
            iconSize: 28,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(() => Text(
              '${item.quantity.value}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
          IconButton(
            icon: Obx(() => Icon(
              item.quantity.value > 1 ? Icons.remove_circle : Icons.delete,
              color: const Color(0xFFFF6B6B),
            )),
            onPressed: () => controller.updateQuantity(item.recipeId, item.quantity.value - 1),
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}