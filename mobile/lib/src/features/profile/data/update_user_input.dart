// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
part 'update_user_input.freezed.dart';
part 'update_user_input.g.dart';

@freezed
abstract class UpdateUserInput with _$UpdateUserInput {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory UpdateUserInput({
    required String name,
    @JsonKey(includeIfNull: false) EditableUserProfile? profile,
  }) = _UpdateUserInput;
  factory UpdateUserInput.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserInputFromJson(json);
}

@freezed
abstract class EditableUserProfile with _$EditableUserProfile {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory EditableUserProfile({
    @JsonKey(name: 'phone_number') required String? phoneNumber,
    required String? address,
    required String? sex,
    required String? birthday,
  }) = _EditableUserProfile;
  factory EditableUserProfile.fromJson(Map<String, dynamic> json) =>
      _$EditableUserProfileFromJson(json);
}
