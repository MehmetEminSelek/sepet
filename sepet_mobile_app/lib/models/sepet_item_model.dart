import 'package:flutter/material.dart';

/// Sepet İçeriği - Basit Ürün Model'i
class SepetItemModel {
  final String id;
  final String name;
  final String? description;
  final int quantity;
  final String? category;
  final String? unit; // kg, adet, litre vs.
  final String? note;
  final bool isCompleted; // Satın alındı mı?
  final String addedBy; // Kim ekledi?
  final String addedByName; // Ekleyen kişinin adı
  final String? checkedBy; // Kim tamamladı?
  final String? checkedByUserId; // Tamamlayan kişinin UID'si
  final DateTime? checkedAt; // Ne zaman tamamlandı?
  final DateTime createdAt;
  final DateTime updatedAt;
  final IconData? icon;
  final Color? color;

  const SepetItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.quantity,
    this.category,
    this.unit,
    this.note,
    this.isCompleted = false,
    required this.addedBy,
    required this.addedByName,
    this.checkedBy,
    this.checkedByUserId,
    this.checkedAt,
    required this.createdAt,
    required this.updatedAt,
    this.icon,
    this.color,
  });

  /// Copy with method - ürün güncelleme için
  SepetItemModel copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    String? category,
    String? unit,
    String? note,
    bool? isCompleted,
    String? addedBy,
    String? addedByName,
    String? checkedBy,
    String? checkedByUserId,
    DateTime? checkedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    IconData? icon,
    Color? color,
  }) {
    return SepetItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      addedBy: addedBy ?? this.addedBy,
      addedByName: addedByName ?? this.addedByName,
      checkedBy: checkedBy ?? this.checkedBy,
      checkedByUserId: checkedByUserId ?? this.checkedByUserId,
      checkedAt: checkedAt ?? this.checkedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'category': category,
      'unit': unit,
      'note': note,
      'isCompleted': isCompleted,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'checkedBy': checkedBy,
      'checkedByUserId': checkedByUserId,
      'checkedAt': checkedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'iconCodePoint': icon?.codePoint,
      'colorValue': color?.value,
    };
  }

  /// Firestore serialization (alias for toJson)
  Map<String, dynamic> toFirestore() => toJson();

  /// JSON deserialization
  factory SepetItemModel.fromJson(Map<String, dynamic> json) {
    return SepetItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      quantity: json['quantity'] as int,
      category: json['category'] as String?,
      unit: json['unit'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      addedBy: json['addedBy'] as String,
      addedByName: json['addedByName'] as String,
      checkedBy: json['checkedBy'] as String?,
      checkedByUserId: json['checkedByUserId'] as String?,
      checkedAt: json['checkedAt'] != null
          ? DateTime.parse(json['checkedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      icon: json['iconCodePoint'] != null
          ? IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons')
          : null,
      color:
          json['colorValue'] != null ? Color(json['colorValue'] as int) : null,
    );
  }

  /// Ürün tamamlanma yüzdesi (grup için)
  static double getCompletionPercentage(List<SepetItemModel> items) {
    if (items.isEmpty) return 0.0;
    final completedCount = items.where((item) => item.isCompleted).length;
    return completedCount / items.length;
  }

  /// Kategori için varsayılan ikon
  static IconData getDefaultIconForCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'meyve':
      case 'sebze':
        return Icons.local_grocery_store;
      case 'et':
      case 'tavuk':
        return Icons.restaurant;
      case 'süt':
      case 'süt ürünleri':
        return Icons.local_drink;
      case 'ekmek':
      case 'unlu mamul':
        return Icons.bakery_dining;
      case 'temizlik':
        return Icons.cleaning_services;
      case 'kişisel bakım':
        return Icons.face_retouching_natural;
      case 'atıştırmalık':
        return Icons.cookie;
      case 'içecek':
        return Icons.local_cafe;
      default:
        return Icons.shopping_basket;
    }
  }

  /// Kategori için varsayılan renk
  static Color getDefaultColorForCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'meyve':
        return Colors.orange;
      case 'sebze':
        return Colors.green;
      case 'et':
      case 'tavuk':
        return Colors.red;
      case 'süt':
      case 'süt ürünleri':
        return Colors.blue;
      case 'ekmek':
      case 'unlu mamul':
        return Colors.brown;
      case 'temizlik':
        return Colors.purple;
      case 'kişisel bakım':
        return Colors.pink;
      case 'atıştırmalık':
        return Colors.amber;
      case 'içecek':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// Ürün tamamlama durumunu değiştir
  SepetItemModel toggleCheck(
      String userWhoCompleted, String userWhoCompletedId) {
    final now = DateTime.now();
    if (isCompleted) {
      // İşareti kaldır
      return copyWith(
        isCompleted: false,
        checkedBy: null,
        checkedByUserId: null,
        checkedAt: null,
        updatedAt: now,
      );
    } else {
      // İşaretle
      return copyWith(
        isCompleted: true,
        checkedBy: userWhoCompleted,
        checkedByUserId: userWhoCompletedId,
        checkedAt: now,
        updatedAt: now,
      );
    }
  }

  /// Backward compatibility alias
  bool get isChecked => isCompleted;

  @override
  String toString() {
    return 'SepetItemModel(id: $id, name: $name, quantity: $quantity, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SepetItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Ürün kategorileri sabit listesi
class ItemCategories {
  static const List<String> categories = [
    'Meyve',
    'Sebze',
    'Et',
    'Tavuk',
    'Balık',
    'Süt Ürünleri',
    'Ekmek',
    'Temizlik',
    'Atıştırmalık',
    'İçecek',
    'Diğer',
  ];

  static const List<String> units = [
    'adet',
    'kg',
    'gram',
    'litre',
    'paket',
    'kutu',
    'şişe',
    'poşet',
  ];
}
