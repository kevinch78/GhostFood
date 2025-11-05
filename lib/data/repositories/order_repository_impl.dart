import 'dart:async';
import 'package:ghost_food/data/models/order_model.dart';
import 'package:ghost_food/data/repositories/exceptions.dart';
import 'package:ghost_food/domain/entities/order_entity.dart';
import 'package:get/get.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:ghost_food/domain/repositories/order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class OrderRepositoryImpl implements OrderRepository {
  final SupabaseClient _client;
  final SessionController _sessionController = Get.find();
  static const String _tableName = 'orders';

  OrderRepositoryImpl(this._client);

  @override
  Future<OrderEntity> createOrderFromCartItem(CartItem item) async {
    try {
      final clientId = _sessionController.userProfile.value?.id;
      if (clientId == null) {
        throw AuthException('No hay un usuario autenticado para crear el pedido.');
      }

      final dataToInsert = OrderModel.toJsonForInsert(
        clientId: clientId,
        recipeId: item.recipeId,
        totalPrice: item.subtotal,
      );

      final response = await _client.from(_tableName).insert(dataToInsert).select().single();
      return OrderModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al crear el pedido: $e');
    }
  }

  @override
  Stream<List<OrderEntity>> getPendingOrdersStream(List<String> licensedRecipeIds) {
    print('🔍 REPO DEBUG: getPendingOrdersStream called with: $licensedRecipeIds');
    
    if (licensedRecipeIds.isEmpty) {
      print('⚠️ REPO DEBUG: licensedRecipeIds is empty, returning empty stream');
      return Stream.value([]);
    }

    final controller = StreamController<List<OrderEntity>>();
    final channel = _client.channel('pending_orders');

    Future<void> fetchAndEmit() async {
      try {
        print('🔍 REPO DEBUG: Fetching pending orders...');
        
        // ← Construir el query sin filtros encadenados problemáticos
        var query = _client
            .from(_tableName)
            .select('*, recipes(*)')
            .eq('status', 'PENDING_ACCEPTANCE');
        
        // Filtrar por kitchen_id NULL usando filter()
        query = query.filter('kitchen_id', 'is', null);
        
        // Filtrar por recipe_ids usando filter() con 'in'
        final response = await query.filter('recipe_id', 'in', '(${licensedRecipeIds.join(',')})');
        
        print('🔍 REPO DEBUG: Raw response: $response');
        
        final orders = (response as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();
        
        print('🔍 REPO DEBUG: Parsed ${orders.length} orders');
        orders.forEach((order) {
          print('   - Order: ${order.id}, Recipe: ${order.recipeId}, Kitchen: ${order.kitchenId}');
        });
        
        if (!controller.isClosed) {
          controller.add(orders);
        }
      } catch (e) {
        print('❌ REPO DEBUG: Error in fetchAndEmit: $e');
        if (!controller.isClosed) {
          controller.addError(ServerException('Error al obtener pedidos pendientes: $e'));
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
            column: 'status',
            value: 'PENDING_ACCEPTANCE',
          ),
          callback: (payload) {
            print('🔔 REPO DEBUG: Realtime event received: ${payload.eventType}');
            fetchAndEmit();
          },
        )
        .subscribe((status, [error]) {
          print('🔔 REPO DEBUG: Channel subscription status: $status');
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('✅ REPO DEBUG: Channel subscribed, fetching initial data');
            fetchAndEmit();
          } else if (status == RealtimeSubscribeStatus.channelError) {
            print('❌ REPO DEBUG: Channel error: $error');
            if (!controller.isClosed) {
              controller.addError(ServerException('Error en el canal: $error'));
            }
          }
        });

    controller.onCancel = () {
      print('🔌 REPO DEBUG: Stream cancelled, removing channel');
      _client.removeChannel(channel);
    };

    return controller.stream;
  }
  
  @override
  Future<void> acceptOrder({required int orderId, required String kitchenId}) async {
    try {
      final response = await _client.rpc('accept_order_atomically', params: {
        'p_order_id': orderId,
        'p_kitchen_id': kitchenId,
      });
      
      final result = response as Map<String, dynamic>;
      
      if (result['success'] != true) {
        throw ServerException(result['message'] ?? 'No se pudo aceptar el pedido');
      }
    } catch (e) {
      throw ServerException('Error al aceptar el pedido: $e');
    }
  }

  @override
  Stream<List<OrderEntity>> getKitchenOrdersStream(String kitchenId) {
    // ← CORREGIDO: Usar Realtime Channels
    final controller = StreamController<List<OrderEntity>>();
    final channel = _client.channel('kitchen_orders_$kitchenId');

    Future<void> fetchAndEmit() async {
      try {
        final response = await _client
            .from(_tableName)
            .select('*, recipes(*)')
            .eq('kitchen_id', kitchenId)
            .order('created_at', ascending: false);
        
        final orders = (response as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();
        
        if (!controller.isClosed) {
          controller.add(orders);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(ServerException('Error al obtener pedidos de la cocina: $e'));
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
  }

  @override
  Future<void> updateOrderStatus({required int orderId, required OrderStatus status}) async {
    try {
      await _client
          .from(_tableName)
          .update({
            'status': OrderModel.statusToString(status),
          })
          .eq('id', orderId);
    } catch (e) {
      throw ServerException('Error al actualizar el estado del pedido: $e');
    }
  }

  @override
  Stream<List<OrderEntity>> getClientOrdersStream(String clientId) {
    // ← CORREGIDO: Usar Realtime Channels
    final controller = StreamController<List<OrderEntity>>();
    final channel = _client.channel('client_orders_$clientId');

    Future<void> fetchAndEmit() async {
      try {
        final response = await _client
            .from(_tableName)
            .select('*, recipes(*)')
            .eq('client_id', clientId)
            .order('created_at', ascending: false);
        
        final orders = (response as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();
        
        if (!controller.isClosed) {
          controller.add(orders);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(ServerException('Error al obtener pedidos del cliente: $e'));
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
            column: 'client_id',
            value: clientId,
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
  }
}