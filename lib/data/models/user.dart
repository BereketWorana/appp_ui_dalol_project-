class User {
  final int id;
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String role;
  final String profileImage;
  final String coverImage;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
    required this.profileImage,
    required this.coverImage,
  });

  // Convert JSON response from backend to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,

      fullName: json['fullName'] ?? '',

      phone: json['phone'] ?? '',

      email: json['email'] ?? '',

      password: json['password'] ?? '',

      role: json['role'] ?? 'consumer',

      profileImage: json['profileImage'] ?? 'assets/images/default_profile.jpg',

      coverImage: json['coverImage'] ?? 'assets/images/default_cover.jpg',
    );
  }

  // Convert User object to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      "id": id,

      "fullName": fullName,

      "phone": phone,

      "email": email,

      "password": password,

      "role": role,

      "profileImage": profileImage,

      "coverImage": coverImage,
    };
  }

  // Create a copy of user with updated fields
  User copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? email,
    String? password,
    String? role,
    String? profileImage,
    String? coverImage,
  }) {
    return User(
      id: id ?? this.id,

      fullName: fullName ?? this.fullName,

      phone: phone ?? this.phone,

      email: email ?? this.email,

      password: password ?? this.password,

      role: role ?? this.role,

      profileImage: profileImage ?? this.profileImage,

      coverImage: coverImage ?? this.coverImage,
    );
  }
}
