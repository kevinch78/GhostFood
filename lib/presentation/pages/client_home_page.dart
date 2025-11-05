import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/auth/auth_service.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';
import 'package:ghost_food/presentation/widgets/category_filter_list_client.dart';
import 'package:ghost_food/presentation/controllers/client_home_controller.dart';
import 'package:ghost_food/presentation/pages/my_orders_page.dart';
import 'package:ghost_food/presentation/widgets/recipe_card_client.dart';
import 'package:ghost_food/presentation/pages/shopping_cart_page.dart';
import 'package:ghost_food/presentation/widgets/empty_state.dart';
import 'package:ghost_food/presentation/widgets/custom_app_bar.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el controlador para la vista del cliente.
    final controller = Get.put(ClientHomeController());
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: CustomAppBar(
        title: 'Explorar Sabores',
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const MyOrdersPage()),
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
            tooltip: 'Mis Pedidos',
          ),
          Obx(
            () => IconButton(
              onPressed: () => Get.to(() => const ShoppingCartPage()),
              icon: Badge(
                label: Text('${cartController.itemCount}'),
                isLabelVisible: cartController.itemCount > 0,
                backgroundColor: const Color(0xFFFF6B6B),
                child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              ),
              tooltip: 'Ver carrito',
            ),
          ),
          IconButton(
            onPressed: () => Get.find<AuthService>().signOutAndClean(),
            icon: const Icon(Icons.logout, color: Color(0xFFFF6B6B)),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1612), Color(0xFF0D0D0D)],
          ),
        ),
        child: Column(
          children: [
            // Usamos un nuevo widget de filtro de categorías para el cliente.
            const CategoryFilterListClient(),

            // Lista de productos
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB8)));
                }

                if (controller.filteredRecipes.isEmpty) {
                  return const EmptyState(
                    title: 'No hay recetas disponibles',
                    subtitle: 'Vuelve más tarde para descubrir nuevos sabores.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.filteredRecipes.length,
                  itemBuilder: (context, index) => RecipeCardClient(recipe: controller.filteredRecipes[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}