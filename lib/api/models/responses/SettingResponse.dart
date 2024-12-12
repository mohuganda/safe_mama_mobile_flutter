import 'package:json_annotation/json_annotation.dart';
import 'package:safe_mama/api/models/user/user_api_model.dart';

part 'SettingResponse.g.dart';

@JsonSerializable()
class SettingResponse {
  int? status;
  UserSettingsApiModel? data;

  SettingResponse(this.status, this.data);

  factory SettingResponse.fromJson(Map<String, dynamic> json) =>
      _$SettingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SettingResponseToJson(this);
}
