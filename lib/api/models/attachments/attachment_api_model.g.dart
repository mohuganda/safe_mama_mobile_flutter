// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttachmentApiModel _$AttachmentApiModelFromJson(Map<String, dynamic> json) =>
    AttachmentApiModel(
      (json['id'] as num?)?.toInt(),
      (json['publication_id'] as num?)?.toInt(),
      json['file'] as String?,
      json['description'] as String?,
    );

Map<String, dynamic> _$AttachmentApiModelToJson(AttachmentApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publication_id': instance.publication_id,
      'file': instance.file,
      'description': instance.description,
    };
