import 'package:json_annotation/json_annotation.dart';

part 'urun_model.g.dart';

@JsonSerializable()
class UrunModel {
  final String id;
  final String name;
  final String quantity;
  final String addedBy;
  final String addedByUserId; // Firebase User UID
  final bool isChecked;
  final String? checkedBy; // Kimin tarafından alındığı
  final String? checkedByUserId; // Firebase User UID
  final DateTime? checkedAt; // Ne zaman alındığı
  final DateTime createdAt;
  final DateTime updatedAt;

  UrunModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.addedBy,
    required this.addedByUserId,
    this.isChecked = false,
    this.checkedBy,
    this.checkedByUserId,
    this.checkedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON serialization
  factory UrunModel.fromJson(Map<String, dynamic> json) =>
      _$UrunModelFromJson(json);
  Map<String, dynamic> toJson() => _$UrunModelToJson(this);

  // Firestore serialization
  factory UrunModel.fromFirestore(Map<String, dynamic> data) {
    return UrunModel(
      id: data['id'],
      name: data['name'],
      quantity: data['quantity'],
      addedBy: data['addedBy'],
      addedByUserId: data['addedByUserId'],
      isChecked: data['isChecked'] ?? false,
      checkedBy: data['checkedBy'],
      checkedByUserId: data['checkedByUserId'],
      checkedAt:
          data['checkedAt'] != null ? DateTime.parse(data['checkedAt']) : null,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'addedBy': addedBy,
      'addedByUserId': addedByUserId,
      'isChecked': isChecked,
      'checkedBy': checkedBy,
      'checkedByUserId': checkedByUserId,
      'checkedAt': checkedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Factory constructor Map'ten oluşturma için (backward compatibility)
  factory UrunModel.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    return UrunModel(
      id: map['id'] ?? '',
      name: map['name'],
      quantity: map['quantity'],
      addedBy: map['addedBy'],
      addedByUserId: map['addedByUserId'] ?? '',
      isChecked: map['checked'] ?? false,
      checkedBy: map['checkedBy'],
      checkedByUserId: map['checkedByUserId'],
      checkedAt:
          map['checkedAt'] != null ? DateTime.parse(map['checkedAt']) : null,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Copy with method for immutability
  UrunModel copyWith({
    String? id,
    String? name,
    String? quantity,
    String? addedBy,
    String? addedByUserId,
    bool? isChecked,
    String? checkedBy,
    String? checkedByUserId,
    DateTime? checkedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UrunModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      addedBy: addedBy ?? this.addedBy,
      addedByUserId: addedByUserId ?? this.addedByUserId,
      isChecked: isChecked ?? this.isChecked,
      checkedBy: checkedBy ?? this.checkedBy,
      checkedByUserId: checkedByUserId ?? this.checkedByUserId,
      checkedAt: checkedAt ?? this.checkedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Ürünü işaretleme/işaretle kaldırma
  UrunModel toggleCheck(String userWhoChecked, String userWhoCheckedId) {
    final now = DateTime.now();
    if (isChecked) {
      // İşareti kaldır
      return copyWith(
        isChecked: false,
        checkedBy: null,
        checkedByUserId: null,
        checkedAt: null,
        updatedAt: now,
      );
    } else {
      // İşaretle
      return copyWith(
        isChecked: true,
        checkedBy: userWhoChecked,
        checkedByUserId: userWhoCheckedId,
        checkedAt: now,
        updatedAt: now,
      );
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UrunModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UrunModel(id: $id, name: $name, addedBy: $addedBy)';
  }
}
