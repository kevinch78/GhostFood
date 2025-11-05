import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/domain/repositories/recipe_repository.dart';
import 'package:ghost_food/presentation/controllers/creator_home_controller.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:image_picker/image_picker.dart';

class CreateRecipeController extends GetxController {
  final RecipeRepository _recipeRepository = Get.find();
  final SessionController _sessionController = Get.find();

  // Receta opcional para el modo de edición
  final RecipeEntity? recipe;

  // --- FORM STATE ---
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  // Por ahora, ingredientes y pasos como texto simple. Más adelante se puede mejorar.
  final ingredientsController = TextEditingController();
  final stepsController = TextEditingController();

  // --- IMAGE STATE ---
  final _picker = ImagePicker();
  final imageBytes = Rx<Uint8List?>(null);
  final imageFileName = Rx<String?>(null);
  final existingImageUrl = Rx<String?>(null); // Para la imagen actual en modo edición

  // --- UI STATE ---
  final isSaving = false.obs;
  final isEditMode = false.obs;

  CreateRecipeController({this.recipe});

  @override
  void onInit() {
    super.onInit();
    if (recipe != null) {
      isEditMode.value = true;
      _populateFieldsForEdit();
    }
  }

  void _populateFieldsForEdit() {
    nameController.text = recipe!.name;
    descriptionController.text = recipe!.description ?? '';
    priceController.text = recipe!.basePrice.toString();
    categoryController.text = recipe!.category ?? '';
    ingredientsController.text = (recipe!.ingredients ?? []).join(', ');
    stepsController.text = (recipe!.steps ?? []).join('. ');
    if (recipe!.imageUrl != null && recipe!.imageUrl!.isNotEmpty) {
      existingImageUrl.value = recipe!.imageUrl;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    categoryController.dispose();
    ingredientsController.dispose();
    stepsController.dispose();
    super.onClose();
  }

  // --- ACTIONS ---

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        imageBytes.value = await pickedFile.readAsBytes();
        imageFileName.value = pickedFile.name;
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo seleccionar la imagen: $e', backgroundColor: Colors.redAccent);
    }
  }

  Future<void> saveRecipe() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSaving.value = true;
      if (isEditMode.value) {
        await _updateRecipe();
      } else {
        await _createRecipe();
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo guardar la receta: $e', backgroundColor: Colors.redAccent);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _createRecipe() async {
      final creatorId = _sessionController.userProfile.value!.id;
      String? imageUrl;

      if (imageBytes.value != null && imageFileName.value != null) {
        imageUrl = await _recipeRepository.uploadRecipeImage(
          imageBytes: imageBytes.value!,
          fileName: imageFileName.value!,
          creatorId: creatorId,
        );
      }

      final newRecipe = RecipeEntity(
        id: '', // La DB lo genera
        creatorId: creatorId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        basePrice: double.parse(priceController.text),
        category: categoryController.text.trim().isEmpty ? null : categoryController.text.trim(),
        imageUrl: imageUrl,
        // Convertimos el texto en una lista real, eliminando elementos vacíos.
        ingredients: ingredientsController.text.split(',')
            .map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        steps: stepsController.text.split('.')
            .map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        type: RecipeType.userCreated,
        createdAt: DateTime.now(),
      );

      await _recipeRepository.createRecipe(newRecipe);

      // Actualizamos la lista en la página anterior
      Get.find<CreatorHomeController>().loadData();

      Get.back(); // Cerramos la página de creación
      Get.snackbar(
        '¡Éxito!',
        'Receta "${newRecipe.name}" creada correctamente.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );    
  }

  Future<void> _updateRecipe() async {
    final creatorId = _sessionController.userProfile.value!.id;
    String? imageUrl = existingImageUrl.value; // Empezamos con la imagen que ya tenía

    // Si el usuario seleccionó una nueva imagen, la subimos.
    if (imageBytes.value != null && imageFileName.value != null) {
      imageUrl = await _recipeRepository.uploadRecipeImage(
        imageBytes: imageBytes.value!,
        fileName: imageFileName.value!,
        creatorId: creatorId,
      );
    }

    final updatedRecipe = RecipeEntity(
      id: recipe!.id, // Usamos el ID de la receta existente
      creatorId: creatorId,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      basePrice: double.parse(priceController.text),
      category: categoryController.text.trim().isEmpty ? null : categoryController.text.trim(),
      imageUrl: imageUrl,
      ingredients: ingredientsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      steps: stepsController.text.split('.').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      type: recipe!.type,
      createdAt: recipe!.createdAt, // Mantenemos la fecha de creación original
    );

    await _recipeRepository.updateRecipe(updatedRecipe);

    // Actualizamos la lista en la página anterior
    Get.find<CreatorHomeController>().loadData();

    Get.back(); // Cerramos la página de edición
    Get.snackbar(
      '¡Éxito!',
      'Receta "${updatedRecipe.name}" actualizada correctamente.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> deleteRecipe() async {
    if (!isEditMode.value) return;

    try {
      await _recipeRepository.deleteRecipe(recipe!.id);
      Get.find<CreatorHomeController>().loadData();
      Get.back(); // Cierra el diálogo de confirmación
      Get.back(); // Cierra la página de edición
      Get.snackbar('Receta Eliminada', 'La receta "${recipe!.name}" ha sido eliminada.', backgroundColor: Colors.orange);
    } catch (e) {
      Get.back(); // Cierra el diálogo de confirmación
      Get.snackbar('Error', 'No se pudo eliminar la receta: $e', backgroundColor: Colors.redAccent);
    }
  }
}