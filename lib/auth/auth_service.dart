
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ghost_food/presentation/controllers/client_home_controller.dart';
import 'package:ghost_food/presentation/controllers/cook_home_controller.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService{
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  //Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async{
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword(String email, String password) async{
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async{
    await _supabase.auth.signOut();
  }
  Future<void> signOutAndClean() async {
    // 1. Limpiamos los controladores que puedan tener datos de la sesión anterior.
    // Usamos `isRegistered` para evitar errores si el controlador nunca se creó.
    if (Get.isRegistered<CookHomeController>()) {
      Get.delete<CookHomeController>(force: true);
    }
    if (Get.isRegistered<ClientHomeController>()) {
      Get.delete<ClientHomeController>(force: true);
    }
    if (Get.isRegistered<SessionController>()) {
      Get.find<SessionController>().clearUserProfile();
    }

    // 2. Cerramos la sesión en Supabase.
    await _supabase.auth.signOut();
  }
    /// Refresca la sesión del usuario actual.
  /// Esto es útil después de crear un perfil para forzar la re-evaluación del AuthGate.
  Future<void> refreshUserSession() async {
    try {
      await Supabase.instance.client.auth.refreshSession();
    } catch (e) {
      print('Error al refrescar la sesión: $e');
    }
  }

  // Get user email
  String? getCurrentUserEmail(){
    final Session = _supabase.auth.currentSession;
    final user = Session?.user;
    return user?.email;
  }





  
}