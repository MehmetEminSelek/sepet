// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sepet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SepetModel _$SepetModelFromJson(Map<String, dynamic> json) => SepetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      workspaceId: json['workspaceId'] as String,
      members:
          (json['members'] as List<dynamic>).map((e) => e as String).toList(),
      memberIds:
          (json['memberIds'] as List<dynamic>).map((e) => e as String).toList(),
      joinCode: json['joinCode'] as String,
      color: SepetModel._colorFromJson((json['color'] as num).toInt()),
      icon: SepetModel._iconFromJson((json['icon'] as num).toInt()),
      items: (json['items'] as List<dynamic>)
          .map((e) => SepetItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SepetModelToJson(SepetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'workspaceId': instance.workspaceId,
      'members': instance.members,
      'memberIds': instance.memberIds,
      'joinCode': instance.joinCode,
      'color': SepetModel._colorToJson(instance.color),
      'icon': SepetModel._iconToJson(instance.icon),
      'items': instance.items,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
