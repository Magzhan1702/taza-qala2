import 'package:cloud_firestore/cloud_firestore.dart';

enum UserLevel { beginner, ecoHero, citySavior }

class UserModel {
  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.points,
    required this.level,
    required this.totalReports,
    required this.resolvedReports,
    required this.role,
  });

  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final int points;
  final UserLevel level;
  final int totalReports;
  final int resolvedReports;
  final String role;

  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    int? points,
    UserLevel? level,
    int? totalReports,
    int? resolvedReports,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      level: level ?? this.level,
      totalReports: totalReports ?? this.totalReports,
      resolvedReports: resolvedReports ?? this.resolvedReports,
      role: role ?? this.role,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      points: data['points'] as int? ?? 0,
      level: _levelFromString(data['level'] as String?),
      totalReports: data['totalReports'] as int? ?? 0,
      resolvedReports: data['resolvedReports'] as int? ?? 0,
      role: data['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'points': points,
      'level': level.name,
      'totalReports': totalReports,
      'resolvedReports': resolvedReports,
      'role': role,
    };
  }

  static UserLevel _levelFromString(String? value) {
    return UserLevel.values.firstWhere(
      (item) => item.name == value,
      orElse: () => UserLevel.beginner,
    );
  }
}
