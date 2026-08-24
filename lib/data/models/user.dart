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

  // ============================================================
  // CONVERT JSON RESPONSE FROM BACKEND TO USER OBJECT
  // 
  // Supports both:
  // - API response: { "full_name": "...", "avatar": "..." }
  // - Local storage: { "fullName": "...", "profileImage": "..." }
  // ============================================================

  factory User.fromJson(Map<String, dynamic> json) {
    // Try to get values from both naming conventions
    final String fullName = 
        json['full_name']?.toString() ?? 
        json['fullName']?.toString() ?? 
        '';
    
    final String phone = 
        json['phone']?.toString() ?? 
        '';
    
    final String email = 
        json['email']?.toString() ?? 
        '';
    
    final String password = 
        json['password']?.toString() ?? 
        '';
    
    final String role = 
        json['role']?.toString() ?? 
        json['user_type']?.toString() ?? 
        'consumer';
    
    final String profileImage = 
        json['avatar']?.toString() ?? 
        json['profile_image']?.toString() ?? 
        json['profileImage']?.toString() ?? 
        'assets/images/default_profile.jpg';
    
    final String coverImage = 
        json['cover_image']?.toString() ?? 
        json['coverImage']?.toString() ?? 
        'assets/images/default_cover.jpg';

    return User(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      role: _normalizeRole(role),
      profileImage: profileImage,
      coverImage: coverImage,
    );
  }

  // ============================================================
  // CONVERT USER OBJECT TO JSON FOR API REQUESTS
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "phone": phone,
      "email": email,
      "password": password,
      "user_type": _roleToUserType(role),
      "avatar": profileImage,
      "cover_image": coverImage,
    };
  }

  // ============================================================
  // CREATE A COPY OF USER WITH UPDATED FIELDS
  // ============================================================

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

  // ============================================================
  // HELPER METHODS
  // ============================================================

  // Normalize role to match app's role system
  static String _normalizeRole(String role) {
    final String lowerRole = role.toLowerCase();
    switch (lowerRole) {
      case 'merchant':
      case 'hotel_admin':
        return 'merchant';
      case 'influencer':
      case 'creator':
        return 'creator';
      case 'admin':
        return 'admin';
      default:
        return 'consumer';
    }
  }

  // Convert app role to API user_type
  static String _roleToUserType(String role) {
    switch (role) {
      case 'merchant':
        return 'merchant';
      case 'creator':
        return 'influencer';
      case 'admin':
        return 'admin';
      default:
        return 'customer';
    }
  }

  // ============================================================
  // CONVENIENCE GETTERS
  // ============================================================

  bool get isMerchant => role == 'merchant';
  bool get isCreator => role == 'creator';
  bool get isConsumer => role == 'consumer';
  bool get isAdmin => role == 'admin';

  String get displayName => fullName.isNotEmpty ? fullName : 'User';

  String get initials {
    if (fullName.isEmpty) return 'U';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 1).toUpperCase();
  }
}