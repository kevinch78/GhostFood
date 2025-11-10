import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';
import 'package:ghost_food/presentation/controllers/order_controller.dart';
import 'package:ghost_food/presentation/pages/my_orders_page.dart';
import 'package:ghost_food/presentation/widgets/cart_item_card.dart';

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Get.find() porque el controlador ya fue inyectado como singleton.
    final controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1612),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, controller),
              Expanded(
                child: Obx(() {
                  if (controller.cartItems.isEmpty) {
                    return _buildEmptyCart();
                  }
                  return _buildCartContent(controller);
                }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.cartItems.isEmpty) return const SizedBox.shrink();
        return _buildCheckoutButton(context, controller);
      }),
    );
  }

  Widget _buildHeader(BuildContext context, CartController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFF00FFB8)],
                  ).createShader(bounds),
                  child: const Text(
                    'Mi Carrito',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                Obx(() => Text(
                      '${controller.itemCount} ${controller.itemCount == 1 ? 'producto' : 'productos'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    )),
              ],
            ),
          ),
          Obx(() {
            if (controller.cartItems.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
              onPressed: () => _showClearCartDialog(context, controller),
              tooltip: 'Vaciar carrito',
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              'Agrega productos para comenzar tu pedido',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartController controller) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.cartItems.length,
            itemBuilder: (context, index) {
              return CartItemCard(item: controller.cartItems[index]);
            },
          ),
        ),
        _buildOrderSummary(controller),
      ],
    );
  }

  Widget _buildOrderSummary(CartController controller) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00FFAA).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Obx(() => Column(
        children: [
          _buildSummaryRow('Subtotal', controller.subtotal),
          const SizedBox(height: 12),
          _buildSummaryRow('Envío', controller.deliveryFee),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow('Total', controller.total, isTotal: true),
        ],
      )),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: isTotal ? const Color(0xFF00FFAA) : Colors.white,
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context, CartController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        child: ElevatedButton(
          onPressed: controller.isProcessing.value ? null : () => _processCheckout(context, controller),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            disabledBackgroundColor: Colors.grey.withOpacity(0.5),
          ),
          child: Obx(() => Ink(
              decoration: BoxDecoration(
                gradient: controller.isProcessing.value
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                      ),
                color: controller.isProcessing.value ? Colors.grey.withOpacity(0.5) : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 60,
                alignment: Alignment.center,
                child: controller.isProcessing.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Realizar Pedido · \$${controller.total.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
              ),
            )),
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
            SizedBox(width: 8),
            Text(
              '¿Vaciar carrito?',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar todos los productos del carrito?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Vaciar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processCheckout(BuildContext context, CartController cartController) async {
    final orderController = Get.find<OrderController>();

    cartController.isProcessing.value = true;

    final success = await orderController.createOrdersFromCart(cartController.cartItems.toList());

    cartController.isProcessing.value = false;

    if (success) {
      cartController.clear(); // Vaciamos el carrito
      Get.back(); // Volvemos a la página anterior para que el snackbar se muestre sobre la home.
      Get.snackbar(
        '¡Pedido Realizado!',
        'Tus recetas están buscando una cocina. Revísalas en "Mis Pedidos".',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back(); // Volvemos a la página anterior
      Get.snackbar(
        '¡Pedido Realizado!',
        'Tus recetas ya están buscando una cocina. Sigue su estado aquí.',
        backgroundColor: const Color(0xFF2E7D32), // Un verde más oscuro
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => Get.to(() => const MyOrdersPage()),
          child: const Text('VER PEDIDOS', style: TextStyle(color: Color(0xFF00FFB8), fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      Get.snackbar(
        'Error',
        'No se pudieron crear tus pedidos. Inténtalo de nuevo.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}