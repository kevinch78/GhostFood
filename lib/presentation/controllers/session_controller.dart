import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/profile_entity.dart';
import 'package:ghost_food/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Este controlador es el ÚNICO responsable de mantener el estado del perfil del usuario actual.
/// Es un singleton que vive durante toda la sesión del usuario.
class SessionController extends GetxController {
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();

  final Rx<ProfileEntity?> userProfile = Rx(null);
  final RxBool isLoading = true.obs;

  /// Carga el perfil del usuario desde la base de datos al iniciar.
  Future<void> loadUserProfile() async {
    isLoading.value = true;
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        userProfile.value = await _profileRepository.getProfile(user.id);
      } catch (e) {
        print("Error al cargar el perfil en SessionController: $e");
        userProfile.value = null;
      }
    } else {
      userProfile.value = null;
    }
    isLoading.value = false;
  }

  /// Establece el perfil del usuario manualmente.
  /// Esto se usa después de crear el perfil para evitar race conditions.
  void setUserProfile(ProfileEntity profile) {
    userProfile.value = profile;
  }

  /// Actualiza el perfil del usuario en la sesión actual.
  /// Útil después de que el usuario edita su perfil.
  void updateProfile(ProfileEntity updatedProfile) {
    userProfile.value = updatedProfile;
    update(); // Notifica a los listeners que el objeto ha cambiado internamente.
  }

  void clearUserProfile() {
    userProfile.value = null;
  }
}