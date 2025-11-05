import 'package:get/get.dart';
import 'package:ghost_food/auth/auth_service.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';
import 'package:ghost_food/core/config/supabase_config.dart';
import 'package:ghost_food/data/repositories/profile_repository_impl.dart';
import 'package:ghost_food/domain/repositories/agreement_repository.dart';
import 'package:ghost_food/data/repositories/recipe_repository_impl.dart';
import 'package:ghost_food/domain/repositories/recipe_repository.dart';
import 'package:ghost_food/domain/repositories/profile_repository.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:ghost_food/presentation/controllers/order_controller.dart';
import 'package:ghost_food/domain/repositories/order_repository.dart';
import 'package:ghost_food/data/repositories/order_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/agreement_repository_impl.dart';
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // --- CORE ---
    // Registramos la instancia de SupabaseClient para que esté disponible en toda la app.
    Get.lazyPut<SupabaseClient>(() => SupabaseConfig.client, fenix: true);

    // --- SERVICES ---
    // Registramos AuthService, que ahora depende de SupabaseClient.
    Get.lazyPut<AuthService>(() => AuthService(Get.find()), fenix: true);

    // --- REPOSITORIES ---
    Get.lazyPut<ProfileRepository>(() => ProfileRepositoryImpl(Get.find()), fenix: true);
    Get.lazyPut<RecipeRepository>(() => RecipeRepositoryImpl(Get.find()), fenix: true);
    Get.lazyPut<AgreementRepository>(() => AgreementRepositoryImpl(Get.find()), fenix: true);
    Get.lazyPut<OrderRepository>(() => OrderRepositoryImpl(Get.find()), fenix: true);

    // --- CONTROLLERS (Singleton) ---
    // El carrito debe ser un singleton para mantener su estado en toda la app.
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<SessionController>(() => SessionController(), fenix: true);
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
  }
}