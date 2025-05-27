import 'package:flutter/material.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final List<String> memberIds;
  final List<String> members;
  final String joinCode; // 12 haneli benzersiz davet kodu (WS1234ABCDEF)
  final Color color;
  final IconData icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkspaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.memberIds,
    required this.members,
    required this.joinCode,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  // Firestore conversion
  factory WorkspaceModel.fromFirestore(Map<String, dynamic> data) {
    return WorkspaceModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      members: List<String>.from(data['members'] ?? []),
      joinCode:
          data['joinCode'] ?? generateWorkspaceJoinCode(data['createdBy']),
      color: Color(data['colorValue'] ?? Colors.blue.value),
      icon: IconData(
        data['iconCode'] ?? Icons.folder.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'memberIds': memberIds,
      'members': members,
      'joinCode': joinCode,
      'colorValue': color.value,
      'iconCode': icon.codePoint,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Workspace join code generator - 12 haneli workspace kodu
  // Format: [2 hane prefix][4 hane user ID][6 hane random]
  static String generateWorkspaceJoinCode([String? userId]) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;

    // 1. Prefix (2 hane) - Workspace türü belirteci
    String prefix = 'WS'; // Workspace için WS

    // 2. User ID son 4 hanesi (4 hane)
    String userPart = '';
    if (userId != null && userId.length >= 4) {
      final lastFour = userId.substring(userId.length - 4).toUpperCase();
      userPart = lastFour.replaceAll(RegExp(r'[^A-Z0-9]'), '');

      while (userPart.length < 4) {
        userPart += chars[(random + userPart.length) % chars.length];
      }

      if (userPart.length > 4) {
        userPart = userPart.substring(0, 4);
      }
    } else {
      for (int i = 0; i < 4; i++) {
        userPart += chars[(random + i) % chars.length];
      }
    }

    // 3. Random kısım (6 hane) - Daha güvenli
    String randomPart = '';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final microTime = DateTime.now().microsecondsSinceEpoch;
    for (int i = 0; i < 6; i++) {
      randomPart += chars[(timestamp + microTime + i * 17) % chars.length];
    }

    return prefix + userPart + randomPart;
  }

  // Copy with method
  WorkspaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    List<String>? memberIds,
    List<String>? members,
    String? joinCode,
    Color? color,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      memberIds: memberIds ?? this.memberIds,
      members: members ?? this.members,
      joinCode: joinCode ?? this.joinCode,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Varsayılan workspace'ler
  static List<WorkspaceModel> getDefaultWorkspaces(
      String userId, String userName) {
    final now = DateTime.now();

    return [
      WorkspaceModel(
        id: 'default_ev',
        name: 'Ev',
        description: 'Ev ile ilgili sepetler',
        createdBy: userId,
        memberIds: [userId],
        members: [userName],
        joinCode: generateWorkspaceJoinCode(userId),
        color: const Color(0xFFFFB5BA), // Pastel pembe
        icon: Icons.home,
        createdAt: now,
        updatedAt: now,
      ),
      WorkspaceModel(
        id: 'default_is',
        name: 'İş',
        description: 'İş yeri ile ilgili sepetler',
        createdBy: userId,
        memberIds: [userId],
        members: [userName],
        joinCode: generateWorkspaceJoinCode(userId),
        color: const Color(0xFFB5EAEA), // Pastel turkuaz
        icon: Icons.business,
        createdAt: now,
        updatedAt: now,
      ),
      WorkspaceModel(
        id: 'default_sosyal',
        name: 'Sosyal',
        description: 'Etkinlik ve sosyal sepetler',
        createdBy: userId,
        memberIds: [userId],
        members: [userName],
        joinCode: generateWorkspaceJoinCode(userId),
        color: const Color(0xFFFFF8B5), // Pastel sarı
        icon: Icons.celebration,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  String toString() {
    return 'WorkspaceModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkspaceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
