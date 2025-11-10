import 'package:ghost_food/domain/entities/agreement_entity.dart';

abstract class AgreementRepository {
  Future<void> createAgreement({required String recipeId, required String creatorId, required String kitchenId});

  Future<void> updateAgreementStatus({required int agreementId, required AgreementStatus status});

  Stream<List<AgreementEntity>> getAgreementsStreamByCreator(String creatorId);

  Stream<List<AgreementEntity>> getAgreementsStreamByKitchen(String kitchenId);
  
  Future<List<AgreementEntity>> getAllApprovedAgreements();
}