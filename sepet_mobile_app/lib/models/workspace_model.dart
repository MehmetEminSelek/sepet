import 'package:flutter/material.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final List<String> memberIds;
  final List<String> members;
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
      'colorValue': color.value,
      'iconCode': icon.codePoint,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  WorkspaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    List<String>? memberIds,
    List<String>? members,
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
