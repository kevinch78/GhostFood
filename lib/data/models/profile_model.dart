
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.role,
    super.fullName,
    super.kitchenName,
    super.kitchenDescription,
    super.photoUrl,
    super.locationCity,
    super.dislikes,
    super.allergies,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      role: (json['role'] as String).toUserRole(),
      fullName: json['full_name'],
      kitchenName: json['kitchen_name'],
      kitchenDescription: json['kitchen_description'],
      photoUrl: json['photo_url'],
      locationCity: json['location_city'],
      dislikes: json['dislikes'] != null 
          ? List<String>.from(json['dislikes']) 
          : null,
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'full_name': fullName,
      'kitchen_name': kitchenName,
      'kitchen_description': kitchenDescription,
      'photo_url': photoUrl,
      'location_city': locationCity,
      'dislikes': dislikes,
      'allergies': allergies,
    };
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      role: entity.role,
      fullName: entity.fullName,
      kitchenName: entity.kitchenName,
      kitchenDescription: entity.kitchenDescription,
      photoUrl: entity.photoUrl,
      locationCity: entity.locationCity,
      dislikes: entity.dislikes,
      allergies: entity.allergies,
    );
  }

  @override
  ProfileModel copyWith({
    String? id,
    UserRole? role,
    String? fullName,
    String? kitchenName,
    String? kitchenDescription,
    String? photoUrl,
    String? locationCity,
    List<String>? dislikes,
    List<String>? allergies,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      kitchenName: kitchenName ?? this.kitchenName,
      kitchenDescription: kitchenDescription ?? this.kitchenDescription,
      photoUrl: photoUrl ?? this.photoUrl,
      locationCity: locationCity ?? this.locationCity,
      dislikes: dislikes ?? this.dislikes,
      allergies: allergies ?? this.allergies,
    );
  }
}

extension on String {
  UserRole toUserRole() {
    switch (this) {
      case 'cliente':
        return UserRole.cliente;
      case 'cocinero':
        return UserRole.cocinero;
      case 'creador':
        return UserRole.creador;
      default:
        throw Exception('Unknown role: $this');
    }
  }
}