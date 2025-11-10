import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/profile_entity.dart';
import 'package:ghost_food/domain/repositories/profile_repository.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';

class EditProfileController extends GetxController {
  final ProfileRepository _profileRepository = Get.find();
  final SessionController _sessionController = Get.find();

  // Controladores para los campos del formulario
  late final TextEditingController nameController;
  late final TextEditingController kitchenNameController;
  late final TextEditingController kitchenDescController;
  late final TextEditingController cityController;
  late final TextEditingController allergiesController;
  late final TextEditingController dislikesController;

  final isLoading = false.obs;

  // Getter para acceder fácilmente al perfil actual
  ProfileEntity? get _profile => _sessionController.userProfile.value;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: _profile?.fullName ?? '');
    kitchenNameController = TextEditingController(text: _profile?.kitchenName ?? '');
    kitchenDescController = TextEditingController(text: _profile?.kitchenDescription ?? '');
    cityController = TextEditingController(text: _profile?.locationCity ?? '');

    // Convertimos las listas a un string separado por comas para el TextField
    allergiesController = TextEditingController(text: _profile?.allergies?.join(', ') ?? '');
    dislikesController = TextEditingController(text: _profile?.dislikes?.join(', ') ?? '');
  }

  Future<void> saveProfile() async {
    if (_profile == null) return;

    isLoading.value = true;

    try {
      // Convertimos los strings de vuelta a listas, limpiando espacios y elementos vacíos
      final allergiesList = allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final dislikesList = dislikesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      // Creamos una copia actualizada del perfil
      final updatedProfile = _profile!.copyWith(
        fullName: nameController.text.trim(),
        kitchenName: kitchenNameController.text.trim(),
        kitchenDescription: kitchenDescController.text.trim(),
        locationCity: cityController.text.trim(),
        allergies: allergiesList,
        dislikes: dislikesList,
      );

      await _profileRepository.updateProfile(updatedProfile);

      // Actualizamos el perfil en la sesión para que toda la app lo vea
      _sessionController.setUserProfile(updatedProfile);

      Get.back(); // Cierra la pantalla o diálogo de edición
      Get.snackbar(
        '¡Éxito!',
        'Tu perfil ha sido actualizado.',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar el perfil: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Liberamos todos los controladores
    nameController.dispose();
    kitchenNameController.dispose();
    kitchenDescController.dispose();
    cityController.dispose();
    allergiesController.dispose();
    dislikesController.dispose();
    super.onClose();
  }
}