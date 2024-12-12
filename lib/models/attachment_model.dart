import 'package:json_annotation/json_annotation.dart';
import 'package:safe_mama/api/models/attachments/attachment_api_model.dart';

part 'attachment_model.g.dart';

@JsonSerializable()
class AttachmentModel {
  int id;
  int publicationId;
  String file;
  String description;

  AttachmentModel(
      {required this.id,
      required this.publicationId,
      required this.file,
      required this.description});

  factory AttachmentModel.fromApiModel(AttachmentApiModel model) {
    return AttachmentModel(
        id: model.id ?? -1,
        description: model.description ?? '',
        file: model.file ?? '',
        publicationId: model.publication_id ?? -1);
  }

  factory AttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$AttachmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentModelToJson(this);
}
