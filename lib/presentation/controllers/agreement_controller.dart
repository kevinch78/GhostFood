import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/agreement_entity.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/domain/repositories/agreement_repository.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';

class AgreementController extends GetxController {
  final AgreementRepository _agreementRepository = Get.find();
  final SessionController _sessionController = Get.find();

  StreamSubscription? _agreementsSubscription;
  final myAgreements = <AgreementEntity>[].obs;
  final isRequesting = <String, bool>{}.obs;

  @override
  void onClose() {
    _agreementsSubscription?.cancel();
    super.onClose();
  }

  void listenForMyAgreements() {
    _agreementsSubscription?.cancel();
    final kitchenId = _sessionController.userProfile.value?.id;
    if (kitchenId == null) return;

    _agreementsSubscription = _agreementRepository
        .getAgreementsStreamByKitchen(kitchenId)
        .listen(myAgreements.assignAll);
  }

  Future<void> requestAgreement(RecipeEntity recipe) async {
    isRequesting[recipe.id] = true;
    try {
      await _agreementRepository.createAgreement(
        recipeId: recipe.id,
        creatorId: recipe.creatorId,
        kitchenId: _sessionController.userProfile.value!.id,
      );
      Get.snackbar('Solicitud Enviada', 'El creador ha sido notificado.',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white));
    } finally {
      isRequesting[recipe.id] = false;
    }
  }

  AgreementStatus? getAgreementStatusForRecipe(String recipeId) {
    return myAgreements.firstWhereOrNull((a) => a.recipeId == recipeId)?.status;
  }

  String? getCurrentUserId() {
    return _sessionController.userProfile.value?.id;
  }
}
