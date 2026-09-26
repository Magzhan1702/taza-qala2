import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportCategory { trash, road, water, other }

enum ReportStatus { newReport, inProgress, resolved }

class ReportModel {
  const ReportModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.status,
    required this.createdAt,
    required this.resolvedAt,
    required this.isFake,
  });

  final String id;
  final String userId;
  final ReportCategory category;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final bool isFake;

  bool get isHotZoneCandidate => status != ReportStatus.resolved;

  ReportModel copyWith({
    String? id,
    String? userId,
    ReportCategory? category,
    String? description,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? address,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    bool? isFake,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      isFake: isFake ?? this.isFake,
    );
  }

  factory ReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ReportModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      category: _categoryFromString(data['category'] as String?),
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      address: data['address'] as String? ?? '',
      status: _statusFromString(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      isFake: data['isFake'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category.name,
      'description': description,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt == null ? null : Timestamp.fromDate(resolvedAt!),
      'isFake': isFake,
    };
  }

  static ReportCategory _categoryFromString(String? value) {
    return ReportCategory.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ReportCategory.other,
    );
  }

  static ReportStatus _statusFromString(String? value) {
    return ReportStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ReportStatus.newReport,
    );
  }
}
