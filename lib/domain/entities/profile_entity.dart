enum UserRole { cliente, cocinero, creador }

class ProfileEntity {
  final String id;
  final UserRole role;
  final String? fullName;
  final String? deliveryAddress;
  final String? kitchenName;
  final String? kitchenDescription;
  final String? photoUrl;

  const ProfileEntity({
    required this.id,
    required this.role,
    this.fullName,
    this.deliveryAddress,
    this.kitchenName,
    this.kitchenDescription,
    this.photoUrl,
  });

  ProfileEntity copyWith({
    String? id,
    UserRole? role,
    String? fullName,
    String? deliveryAddress,
    String? kitchenName,
    String? kitchenDescription,
    String? photoUrl,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      kitchenName: kitchenName ?? this.kitchenName,
      kitchenDescription: kitchenDescription ?? this.kitchenDescription,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfileEntity &&
        other.id == id &&
        other.role == role &&
        other.fullName == fullName &&
        other.deliveryAddress == deliveryAddress &&
        other.kitchenName == kitchenName &&
        other.kitchenDescription == kitchenDescription &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        role.hashCode ^
        fullName.hashCode ^
        deliveryAddress.hashCode ^
        kitchenName.hashCode ^
        kitchenDescription.hashCode ^
        photoUrl.hashCode;
  }
}