import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/presentation/controllers/client_home_controller.dart';

class CategoryFilterListClient extends StatelessWidget {
  const CategoryFilterListClient({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientHomeController>();

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Obx(
        () {
          // Forzamos la reconstrucción accediendo a las variables observables
          final selected = controller.selectedCategory.value;
          final categoriesList = controller.categories.toList();
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categoriesList.length,
            itemBuilder: (context, index) {
              final category = categoriesList[index];
              final isSelected = selected == category;

              return InkWell(
                onTap: () {
                  print('📱 Categoría seleccionada: $category');
                  controller.changeCategory(category);
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00FFB8) : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}