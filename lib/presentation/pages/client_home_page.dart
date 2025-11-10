import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';
import 'package:ghost_food/presentation/widgets/category_filter_list_client.dart';
import 'package:ghost_food/presentation/pages/ai_chef_page.dart';
import 'package:ghost_food/presentation/controllers/client_home_controller.dart';
import 'package:ghost_food/presentation/controllers/my_orders_controller.dart';
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
    // Inyectamos el controlador de "Mis Pedidos" para obtener el contador.
    final myOrdersController = Get.put(MyOrdersController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: CustomAppBar(
        title: 'Explorar Sabores',
        actions: [
          Obx(
            () {
              // Contamos solo los pedidos que no han sido entregados o cancelados.
              final activeOrdersCount = myOrdersController.myOrders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length;
              return IconButton(
                onPressed: () => Get.to(() => const MyOrdersPage()),
                icon: Badge(
                  label: Text('$activeOrdersCount'),
                  isLabelVisible: activeOrdersCount > 0,
                  child: const Icon(Icons.receipt_long_outlined, color: Colors.white),
                ),
                tooltip: 'Mis Pedidos',
              );
            }
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AiChefPage(), transition: Transition.downToUp),
        backgroundColor: const Color(0xFF00FFB8),
        icon: const Icon(Icons.auto_awesome, color: Colors.black),
        label: const Text(
          'Chef IA',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}