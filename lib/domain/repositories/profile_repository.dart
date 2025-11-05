import 'package:ghost_food/domain/entities/profile_entity.dart';


abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile(String userId);
  Future<void> createProfile(ProfileEntity profile);
  Future<void> updateProfile(ProfileEntity profile);
}