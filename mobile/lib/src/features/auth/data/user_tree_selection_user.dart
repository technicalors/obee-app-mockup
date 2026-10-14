// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:obee_mobile/src/features/auth/data/organization_ref.dart';
part 'user_tree_selection_user.freezed.dart';
part 'user_tree_selection_user.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class UserTreeSelectionUser with _$UserTreeSelectionUser {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory UserTreeSelectionUser({
    required String id,
    required String name,
    required String username,
    @JsonKey(name: 'organization_id') required String organizationId,
    required OrganizationRef organization,
    @JsonKey(required: true) required UserTreeProfile? profile,
  }) = _UserTreeSelectionUser;
  factory UserTreeSelectionUser.fromJson(Map<String, dynamic> json) {
    Object? cursor = json['organization'];
    if (cursor is! Map<String, dynamic> ||
        cursor['id'] != json['organization_id']) {
      throw const FormatException(
        'User tree requires its assigned organization.',
      );
    }
    final visited = <String>{};
    while (cursor != null) {
      if (cursor is! Map<String, dynamic> ||
          !cursor.containsKey('parent') ||
          cursor['id'] is! String ||
          !visited.add(cursor['id'] as String)) {
        throw const FormatException(
          'Invalid user tree organization hierarchy.',
        );
      }
      final parent = cursor['parent'];
      if ((parent == null && cursor['parent_id'] != null) ||
          (parent != null &&
              (parent is! Map<String, dynamic> ||
                  parent['id'] != cursor['parent_id']))) {
        throw const FormatException('Invalid user tree organization parent.');
      }
      cursor = cursor['parent'];
    }
    if (!json.containsKey('profile')) {
      throw const FormatException('User tree profile is required, nullable.');
    }
    return _$UserTreeSelectionUserFromJson(json);
  }
}

@Freezed(fromJson: true, toJson: true)
abstract class UserTreeProfile with _$UserTreeProfile {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory UserTreeProfile({required String code}) = _UserTreeProfile;
  factory UserTreeProfile.fromJson(Map<String, dynamic> json) =>
      _$UserTreeProfileFromJson(json);
}
