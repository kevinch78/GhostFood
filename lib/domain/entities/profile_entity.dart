enum UserRole { cliente, cocinero, creador }

class ProfileEntity {
  final String id;
  final UserRole role;
  final String? fullName;
  final String? kitchenName;
  final String? kitchenDescription;
  final String? photoUrl;
  
  // Campos para personalización de IA
  final String? locationCity;
  final List<String>? dislikes;
  final List<String>? allergies;

  const ProfileEntity({
    required this.id,
    required this.role,
    this.fullName,
    this.kitchenName,
    this.kitchenDescription,
    this.photoUrl,
    this.locationCity,
    this.dislikes,
    this.allergies,
  });

  ProfileEntity copyWith({
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
    return ProfileEntity(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfileEntity &&
        other.id == id &&
        other.role == role &&
        other.fullName == fullName &&
        other.kitchenName == kitchenName &&
        other.kitchenDescription == kitchenDescription &&
        other.photoUrl == photoUrl &&
        other.locationCity == locationCity &&
        _listEquals(other.dislikes, dislikes) &&
        _listEquals(other.allergies, allergies);
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        role.hashCode ^
        fullName.hashCode ^
        kitchenName.hashCode ^
        kitchenDescription.hashCode ^
        photoUrl.hashCode ^
        locationCity.hashCode ^
        dislikes.hashCode ^
        allergies.hashCode;
  }
}