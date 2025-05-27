import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  @JsonKey(name: 'photoURL')
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> workspaceIds;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    required this.workspaceIds,
    this.fcmToken,
  });

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Firestore serialization
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      lastLoginAt: data['lastLoginAt'] != null
          ? DateTime.parse(data['lastLoginAt'])
          : DateTime.now(),
      workspaceIds: List<String>.from(data['workspaceIds'] ?? []),
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'workspaceIds': workspaceIds,
      'fcmToken': fcmToken,
    };
  }

  // Copy with method for immutability
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? workspaceIds,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      workspaceIds: workspaceIds ?? this.workspaceIds,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel(displayName: $displayName, email: $email)';
  }
}
