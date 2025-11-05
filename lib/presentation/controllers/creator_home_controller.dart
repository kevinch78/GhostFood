import 'dart:async';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/agreement_entity.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/domain/repositories/agreement_repository.dart';
import 'package:ghost_food/domain/repositories/recipe_repository.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:flutter/material.dart';

class CreatorHomeController extends GetxController {
  final RecipeRepository _recipeRepository = Get.find();
  final AgreementRepository _agreementRepository = Get.find();
  final SessionController _sessionController = Get.find();

  StreamSubscription? _agreementsSubscription;

  // --- STATE ---
  final isLoading = true.obs;
  final recipes = <RecipeEntity>[].obs;
  final agreements = <AgreementEntity>[].obs;

  final isUpdatingAgreement = <int, bool>{}.obs; // Para el estado de carga por solicitud

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    // Es crucial cancelar la suscripción para evitar fugas de memoria.
    _agreementsSubscription?.cancel();
    super.onClose();
  }

  // --- ACTIONS ---

  /// Carga todos los datos necesarios para el panel del creador.
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _loadRecipes(), // Mantenemos la carga de recetas como una acción única.
      ]);
      // Iniciamos la escucha de las solicitudes en tiempo real.
      _listenForAgreements();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadRecipes() async {
    try {
      final creatorId = _sessionController.userProfile.value?.id;

      if (creatorId == null) {
        throw Exception("No se pudo obtener el ID del creador.");
      }

      final result = await _recipeRepository.getRecipesByCreator(creatorId);
      recipes.assignAll(result);
    } catch (e) {
      _showErrorSnackbar('No se pudieron cargar tus recetas', e);
    }
  }

  void _listenForAgreements() {
    _agreementsSubscription?.cancel();
    final creatorId = _sessionController.userProfile.value?.id;
    if (creatorId == null) {
      isLoading.value = false;
      return;
    }
    
    _agreementsSubscription = _agreementRepository.getAgreementsStreamByCreator(creatorId).listen((newAgreements) {
      agreements.assignAll(newAgreements);
      // Si estábamos cargando, ya terminamos.
      if (isLoading.value) isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      _showErrorSnackbar('No se pudieron cargar las solicitudes en tiempo real', e);
    });
  }

  Future<void> updateAgreementStatus(int agreementId, AgreementStatus newStatus) async {
    isUpdatingAgreement[agreementId] = true;
    try {
      await _agreementRepository.updateAgreementStatus(agreementId: agreementId, status: newStatus);
      // Recargamos los convenios para reflejar el cambio en la UI
      // No es necesario recargar, el stream lo hará automáticamente.
      Get.snackbar(
        '¡Actualizado!',
        'La solicitud ha sido ${newStatus == AgreementStatus.approved ? 'aprobada' : 'rechazada'}.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _showErrorSnackbar('No se pudo actualizar la solicitud', e);
    } finally {
      isUpdatingAgreement[agreementId] = false;
    }
  }

  void _showErrorSnackbar(String title, dynamic error) {
    Get.snackbar(
      title, '$error',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}