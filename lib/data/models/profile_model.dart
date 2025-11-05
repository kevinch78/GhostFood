import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.role,
    super.fullName,
    super.deliveryAddress,
    super.kitchenName,
    super.kitchenDescription,
    super.photoUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      role: (json['role'] as String).toUserRole(),
      fullName: json['full_name'],
      deliveryAddress: json['delivery_address'],
      kitchenName: json['kitchen_name'],
      kitchenDescription: json['kitchen_description'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'full_name': fullName,
      'delivery_address': deliveryAddress,
      'kitchen_name': kitchenName,
      'kitchen_description': kitchenDescription,
      'photo_url': photoUrl,
    };
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      role: entity.role,
      fullName: entity.fullName,
      deliveryAddress: entity.deliveryAddress,
      kitchenName: entity.kitchenName,
      kitchenDescription: entity.kitchenDescription,
      photoUrl: entity.photoUrl,
    );
  }

  // Método para convertir a la entidad base
  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      role: role,
      fullName: fullName,
      deliveryAddress: deliveryAddress,
      kitchenName: kitchenName,
      kitchenDescription: kitchenDescription,
      photoUrl: photoUrl,
    );
  }

  @override
  ProfileModel copyWith({
    String? id,
    UserRole? role,
    String? fullName,
    String? deliveryAddress,
    String? kitchenName,
    String? kitchenDescription,
    String? photoUrl,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      kitchenName: kitchenName ?? this.kitchenName,
      kitchenDescription: kitchenDescription ?? this.kitchenDescription,
      photoUrl: photoUrl ?? this.photoUrl,
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