class ProfileData {
  final String fullName;
  final String email;
  final String? photoUrl;
  final String? phone;
  final String? bio;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;

  ProfileData({
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.phone,
    this.bio,
    this.age,
    this.weight,
    this.height,
    this.gender,
  });

  ProfileData copyWith({
    String? fullName,
    String? email,
    String? photoUrl,
    String? phone,
    String? bio,
    int? age,
    double? weight,
    double? height,
    String? gender,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String? relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    this.relationship,
  });
}
