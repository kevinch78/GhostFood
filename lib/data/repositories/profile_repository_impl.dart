import 'package:ghost_food/data/models/profile_model.dart';
import 'package:ghost_food/domain/entities/profile_entity.dart';
import 'package:ghost_food/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepositoryImpl(this._supabase);

  @override
  Future<ProfileEntity?> getProfile(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();

      return _fromMap(response);
    } catch (e) {
      // Si no se encuentra el perfil (error PostgrestException), devolvemos null.
      // Para otros errores, los relanzamos para que el controlador los maneje.
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null;
      }
      // Relanzamos el error para que sea capturado en el SessionController
      throw Exception('Error al obtener el perfil: $e');
    }
  }

  @override
  Future<void> createProfile(ProfileEntity profile) async {
    // ✅ CAMBIO: Usar upsert() en lugar de insert()
    // Esto actualiza si existe o crea si no existe
    await _supabase.from('profiles').upsert({
      'id': profile.id,
      'full_name': profile.fullName,
      'role': profile.role.name,
    });
  }

  // --- HELPERS ---

  ProfileEntity _fromMap(Map<String, dynamic> map) {
    return ProfileEntity(
      id: map['id'],
      fullName: map['full_name'],
      role: _roleFromString(map['role']),
      kitchenName: map['kitchen_name'],
      kitchenDescription: map['kitchen_description'],
      photoUrl: map['photo_url'],
      locationCity: map['location_city'],
      dislikes: map['dislikes'] != null 
          ? List<String>.from(map['dislikes']) 
          : null,
      allergies: map['allergies'] != null 
          ? List<String>.from(map['allergies']) 
          : null,
    );
  }

  UserRole _roleFromString(String? role) {
    // ✅ Manejar caso donde role es null
    if (role == null) {
      throw Exception('Role is null in database');
    }
    
    switch (role) {
      case 'cliente':
        return UserRole.cliente;
      case 'cocinero':
        return UserRole.cocinero;
      case 'creador':
        return UserRole.creador;
      default:
        throw Exception('Unknown role: $role');
    }
  }
  
  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    try {
      final profileModel = ProfileModel.fromEntity(profile);
      final dataToUpdate = profileModel.toJson();
      dataToUpdate.remove('id'); // No actualizar el ID
      
      await _supabase
          .from('profiles')
          .update(dataToUpdate)
          .eq('id', profile.id);
    } catch (e) {
      throw Exception('Error al actualizar el perfil: $e');
    }
  }
}