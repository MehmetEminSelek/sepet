// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'urun_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UrunModel _$UrunModelFromJson(Map<String, dynamic> json) => UrunModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      addedBy: json['addedBy'] as String,
      addedByUserId: json['addedByUserId'] as String,
      isChecked: json['isChecked'] as bool? ?? false,
      checkedBy: json['checkedBy'] as String?,
      checkedByUserId: json['checkedByUserId'] as String?,
      checkedAt: json['checkedAt'] == null
          ? null
          : DateTime.parse(json['checkedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UrunModelToJson(UrunModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'addedBy': instance.addedBy,
      'addedByUserId': instance.addedByUserId,
      'isChecked': instance.isChecked,
      'checkedBy': instance.checkedBy,
      'checkedByUserId': instance.checkedByUserId,
      'checkedAt': instance.checkedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
