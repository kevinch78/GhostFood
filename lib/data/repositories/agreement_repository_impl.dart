import 'dart:async';
import 'package:ghost_food/data/models/agreement_model.dart';
import 'package:ghost_food/data/repositories/exceptions.dart';
import 'package:ghost_food/domain/entities/agreement_entity.dart';
import 'package:ghost_food/domain/repositories/agreement_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgreementRepositoryImpl implements AgreementRepository {
  final SupabaseClient _client;
  static const String _tableName = 'agreements';

  AgreementRepositoryImpl(this._client);

  @override
  Future<void> createAgreement({required String recipeId, required String creatorId, required String kitchenId}) async {
    try {
      await _client.from(_tableName).insert({
        'recipe_id': recipeId,
        'creator_id': creatorId,
        'kitchen_id': kitchenId,
        'status': 'REQUESTED',
      });
    } catch (e) {
      throw ServerException('Error al crear la solicitud de convenio: $e');
    }
  }

  @override
  Stream<List<AgreementEntity>> getAgreementsStreamByCreator(String creatorId) {
    try {
      final controller = StreamController<List<AgreementEntity>>();
      final channel = _client.channel('agreements_creator_$creatorId');

      Future<void> fetchAndEmit() async {
        try {
          final response = await _client
              .from(_tableName)
              .select('''
                *,
                recipe:recipes(*),
                kitchen:kitchen_id(*)
              ''')
              .eq('creator_id', creatorId)
              .order('requested_at', ascending: false);
          
          final agreements = (response as List)
              .map((json) => AgreementModel.fromJson(json))
              .toList();
          
          if (!controller.isClosed) {
            controller.add(agreements);
          }
        } catch (e) {
          if (!controller.isClosed) {
            controller.addError(ServerException('Error al obtener convenios: $e'));
          }
        }
      }

      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: _tableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'creator_id',
              value: creatorId,
            ),
            callback: (payload) {
              fetchAndEmit();
            },
          )
          .subscribe((status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              fetchAndEmit();
            } else if (status == RealtimeSubscribeStatus.channelError) {
              if (!controller.isClosed) {
                controller.addError(ServerException('Error en el canal: $error'));
              }
            }
          });

      controller.onCancel = () {
        _client.removeChannel(channel);
      };

      return controller.stream;
    } catch (e) {
      throw ServerException('Error al crear el stream de convenios: $e');
    }
  }
  
  @override
  Stream<List<AgreementEntity>> getAgreementsStreamByKitchen(String kitchenId) {
    try {
      final controller = StreamController<List<AgreementEntity>>();
      final channel = _client.channel('agreements_kitchen_$kitchenId');

      Future<void> fetchAndEmit() async {
        try {
          final response = await _client
              .from(_tableName)
              .select('''
                *,
                recipe:recipes(*),
                creator:creator_id(*)
              ''')
              .eq('kitchen_id', kitchenId)
              .order('requested_at', ascending: false);
          
          final agreements = (response as List)
              .map((json) => AgreementModel.fromJson(json))
              .toList();
          
          if (!controller.isClosed) {
            controller.add(agreements);
          }
        } catch (e) {
          if (!controller.isClosed) {
            controller.addError(ServerException('Error al obtener convenios: $e'));
          }
        }
      }

      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: _tableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'kitchen_id',
              value: kitchenId,
            ),
            callback: (payload) {
              fetchAndEmit();
            },
          )
          .subscribe((status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              fetchAndEmit();
            } else if (status == RealtimeSubscribeStatus.channelError) {
              if (!controller.isClosed) {
                controller.addError(ServerException('Error en el canal: $error'));
              }
            }
          });

      controller.onCancel = () {
        _client.removeChannel(channel);
      };

      return controller.stream;
    } catch (e) {
      throw ServerException('Error al crear el stream de convenios de la cocina: $e');
    }
  }

  @override
  Future<void> updateAgreementStatus({required int agreementId, required AgreementStatus status}) async {
    try {
      final updateData = {'status': AgreementModel.statusToString(status)};
      if (status == AgreementStatus.approved) {
        updateData['approved_at'] = DateTime.now().toIso8601String();
      }

      await _client.from(_tableName).update(updateData).eq('id', agreementId);
    } catch (e) {
      throw ServerException('Error al actualizar el estado del convenio: $e');
    }
  }

  @override
  Future<List<AgreementEntity>> getAllApprovedAgreements() async {
    try {
      final response = await _client
          .from(_tableName)
          .select('''
            *,
            recipe:recipes(*),
            kitchen:kitchen_id(*),
            creator:creator_id(*)
          ''')
          .eq('status', 'APPROVED')
          .order('approved_at', ascending: false);
      
      return (response as List)
          .map((json) => AgreementModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener convenios aprobados: $e');
    }
  }
}