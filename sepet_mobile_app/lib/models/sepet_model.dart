import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'sepet_item_model.dart';

part 'sepet_model.g.dart';

@JsonSerializable()
class SepetModel {
  final String id;
  final String name;
  final String description;
  final String workspaceId; // Hangi workspace'e ait
  final List<String> members;
  final List<String> memberIds; // Firebase User UIDs
  final String joinCode; // 6 haneli benzersiz davet kodu (ABC123)
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color color;
  @JsonKey(fromJson: _iconFromJson, toJson: _iconToJson)
  final IconData icon;
  final List<SepetItemModel> items; // UrunModel → SepetItemModel
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SepetModel({
    required this.id,
    required this.name,
    required this.description,
    required this.workspaceId,
    required this.members,
    required this.memberIds,
    required this.joinCode,
    required this.color,
    required this.icon,
    required this.items, // urunler → items
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON serialization
  factory SepetModel.fromJson(Map<String, dynamic> json) =>
      _$SepetModelFromJson(json);
  Map<String, dynamic> toJson() => _$SepetModelToJson(this);

  // Firestore serialization with backward compatibility
  factory SepetModel.fromFirestore(Map<String, dynamic> data) {
    // Güvenli parsing için helper fonksiyon
    List<SepetItemModel> parseItems(dynamic itemsData) {
      if (itemsData == null) return [];

      try {
        final itemsList = itemsData as List;
        return itemsList.map((itemData) {
          try {
            // Önce SepetItemModel olarak parse etmeye çalış
            return SepetItemModel.fromJson(itemData as Map<String, dynamic>);
          } catch (e) {
            // Eğer başarısızsa, eski UrunModel formatından convert et
            print('Converting old UrunModel to SepetItemModel: $e');
            return _convertUrunModelToSepetItem(
                itemData as Map<String, dynamic>);
          }
        }).toList();
      } catch (e) {
        print('Error parsing items: $e');
        return [];
      }
    }

    try {
      return SepetModel(
        id: data['id'] ?? '',
        name: data['name'] ?? 'Untitled',
        description: data['description'] ?? '',
        workspaceId: data['workspaceId'] ?? 'default_ev', // Default workspace
        members: List<String>.from(data['members'] ?? []),
        memberIds: List<String>.from(data['memberIds'] ?? []),
        joinCode: data['joinCode'] ?? _generateJoinCode(),
        color: Color(data['colorValue'] ?? 0xFF2196F3), // Default blue
        icon: IconData(data['iconCode'] ?? Icons.shopping_basket.codePoint,
            fontFamily: 'MaterialIcons'),
        // Önce 'items' field'ını kontrol et, yoksa 'urunler' field'ını kullan
        items: parseItems(data['items'] ?? data['urunler']),
        createdBy: data['createdBy'] ?? '',
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'])
            : DateTime.now(),
        updatedAt: data['updatedAt'] != null
            ? DateTime.parse(data['updatedAt'])
            : DateTime.now(),
      );
    } catch (e) {
      print('Error creating SepetModel from Firestore: $e');
      // Fallback - minimal sepet oluştur
      return SepetModel(
        id: data['id'] ?? '',
        name: data['name'] ?? 'Hatalı Sepet',
        description: 'Bu sepet yüklenirken hata oluştu',
        workspaceId: 'default_ev',
        members: [],
        memberIds: [],
        joinCode: _generateJoinCode(),
        color: Colors.grey,
        icon: Icons.error,
        items: [],
        createdBy: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // UrunModel'den SepetItemModel'e converter
  static SepetItemModel _convertUrunModelToSepetItem(
      Map<String, dynamic> urunData) {
    try {
      return SepetItemModel(
        id: urunData['id'] ?? '',
        name: urunData['name'] ?? 'Untitled Item',
        description: null, // UrunModel'de description yok
        quantity: int.tryParse(urunData['quantity']?.toString() ?? '1') ?? 1,
        category: null, // UrunModel'de category yok
        unit: 'adet', // Default unit
        note: null, // UrunModel'de note yok
        isCompleted: urunData['isChecked'] ?? false, // isChecked -> isCompleted
        addedBy: urunData['addedByUserId'] ?? '',
        addedByName: urunData['addedBy'] ?? 'Unknown',
        checkedBy: urunData['checkedBy'],
        checkedByUserId: urunData['checkedByUserId'],
        checkedAt: urunData['checkedAt'] != null
            ? DateTime.parse(urunData['checkedAt'])
            : null,
        createdAt: urunData['createdAt'] != null
            ? DateTime.parse(urunData['createdAt'])
            : DateTime.now(),
        updatedAt: urunData['updatedAt'] != null
            ? DateTime.parse(urunData['updatedAt'])
            : DateTime.now(),
      );
    } catch (e) {
      print('Error converting UrunModel to SepetItemModel: $e');
      // Fallback item
      return SepetItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Hatalı Ürün',
        quantity: 1,
        isCompleted: false,
        addedBy: '',
        addedByName: 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'workspaceId': workspaceId,
      'members': members,
      'memberIds': memberIds,
      'joinCode': joinCode,
      'colorValue': color.value,
      'iconCode': icon.codePoint,
      'items':
          items.map((item) => item.toJson()).toList(), // Yeni items field'ı
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods for JSON serialization
  static Color _colorFromJson(int value) => Color(value);
  static int _colorToJson(Color color) => color.value;

  static IconData _iconFromJson(int codePoint) =>
      IconData(codePoint, fontFamily: 'MaterialIcons');
  static int _iconToJson(IconData icon) => icon.codePoint;

  // Join code generator - 6 haneli benzersiz kod üretir (ABC123)
  static String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }

  // Public method for generating new join codes
  static String generateJoinCode() => _generateJoinCode();

  // Getter'lar
  int get itemCount => items.length;
  int get checkedItemCount => items.where((item) => item.isCompleted).length;

  /// Progress (tamamlanma yüzdesi)
  double get progress {
    if (items.isEmpty) return 0.0;
    return checkedItemCount / itemCount;
  }

  /// Backward compatibility için eski alan adları
  List<SepetItemModel> get urunler => items;

  // Kategori bazında gruplama
  Map<String, List<SepetItemModel>> get itemsByCategory {
    final Map<String, List<SepetItemModel>> grouped = {};
    for (final item in items) {
      final category = item.category ?? 'Diğer';
      grouped.putIfAbsent(category, () => []).add(item);
    }
    return grouped;
  }

  // Tamamlanmamış ürünler
  List<SepetItemModel> get pendingItems =>
      items.where((item) => !item.isCompleted).toList();

  // Tamamlanmış ürünler
  List<SepetItemModel> get completedItems =>
      items.where((item) => item.isCompleted).toList();

  // Copy with method for immutability
  SepetModel copyWith({
    String? id,
    String? name,
    String? description,
    String? workspaceId,
    List<String>? members,
    List<String>? memberIds,
    String? joinCode,
    Color? color,
    IconData? icon,
    List<SepetItemModel>? items,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SepetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      workspaceId: workspaceId ?? this.workspaceId,
      members: members ?? this.members,
      memberIds: memberIds ?? this.memberIds,
      joinCode: joinCode ?? this.joinCode,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      items: items ?? this.items,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SepetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SepetModel(id: $id, name: $name, members: ${members.length})';
  }
}
