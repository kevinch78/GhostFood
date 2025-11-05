import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/presentation/controllers/client_home_controller.dart';
import 'package:ghost_food/presentation/controllers/cook_home_controller.dart';

class CategoryFilterList extends StatelessWidget {
  const CategoryFilterList({super.key});

  @override
  Widget build(BuildContext context) {
    // Hacemos el widget más inteligente: detecta qué controlador está disponible.
    final isCookView = Get.isRegistered<CookHomeController>();
    final dynamic controller = isCookView
        ? Get.find<CookHomeController>()
        : Get.find<ClientHomeController>();

    final RxList<String> categories = isCookView ? controller.categoriesRx : controller.categories;
    final RxString selectedCategory = isCookView ? controller.selectedCategoryRx : controller.selectedCategory;

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory.value == category;

            return InkWell(
              onTap: () => controller.changeCategory(category), // Ambos controladores tienen este método
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFF1A1A1A),
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
                      color: Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
