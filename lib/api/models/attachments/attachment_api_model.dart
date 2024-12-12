import 'package:json_annotation/json_annotation.dart';

part 'attachment_api_model.g.dart';

@JsonSerializable()
class AttachmentApiModel {
  int? id;
  int? publication_id;
  String? file;
  String? description;

  AttachmentApiModel(this.id, this.publication_id, this.file, this.description);

  factory AttachmentApiModel.fromJson(Map<String, dynamic> json) =>
      _$AttachmentApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentApiModelToJson(this);
}
