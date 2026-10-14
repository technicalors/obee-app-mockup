import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:obee_mobile/src/core/widgets/tree_select.dart';
import 'package:obee_mobile/src/features/auth/data/organization_ref.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';

List<TreeSelectGroup> buildScheduleUserTree({
  required List<UserTreeSelectionUser> users,
  required User currentUser,
}) {
  final rootOrganizationId = currentUser.rootOrganizationId;
  if (rootOrganizationId == null) {
    return const <TreeSelectGroup>[];
  }

  final groups = <String, _MutableScheduleUserTreeGroup>{};
  final organizations = <String, OrganizationRef>{};
  final roots = <String>{};
  for (final user in users) {
    OrganizationRef? cursor = user.organization;
    final visited = <String>{};
    while (cursor != null) {
      final organization = cursor;
      if (!visited.add(organization.id)) {
        throw const FormatException('Organization parent cycle.');
      }
      final existing = organizations[organization.id];
      if (existing != null &&
          (existing.parentId != organization.parentId ||
              existing.name != organization.name)) {
        throw const FormatException('Conflicting organization hierarchy.');
      }
      organizations[organization.id] = organization;
      final group = groups.putIfAbsent(
        organization.id,
        () => _MutableScheduleUserTreeGroup(
          id: organization.id,
          label: organization.name,
        ),
      );
      final parent = organization.parent;
      if (parent == null) {
        roots.add(organization.id);
      } else {
        final parentGroup = groups.putIfAbsent(
          parent.id,
          () =>
              _MutableScheduleUserTreeGroup(id: parent.id, label: parent.name),
        );
        parentGroup.children[organization.id] = group;
      }
      cursor = parent;
    }
    groups[user.organizationId]!.add(user);
  }
  return roots
      .where((id) => id == rootOrganizationId)
      .map((id) => groups[id]!.build())
      .toList(growable: false);
}

Set<String> buildVisibleScheduleUserIds({
  required List<UserTreeSelectionUser> users,
  required User? currentUser,
}) {
  if (currentUser == null) {
    return const <String>{};
  }
  return buildScheduleUserTree(
    users: users,
    currentUser: currentUser,
  ).expand(_collectScheduleUserItemIds).toSet();
}

bool hasScheduleOrganization(User? user) => user?.rootOrganizationId != null;

final class _MutableScheduleUserTreeGroup {
  _MutableScheduleUserTreeGroup({required this.id, required this.label});

  final String id;
  final String label;
  final children = <String, _MutableScheduleUserTreeGroup>{};
  final Map<String, UserTreeSelectionUser> _usersById =
      <String, UserTreeSelectionUser>{};

  void add(UserTreeSelectionUser user) {
    _usersById[user.id] = user;
  }

  TreeSelectGroup build() {
    final items =
        _usersById.values
            .map(
              (user) => TreeSelectItem(
                id: user.id,
                label: user.name,
                subtitle: user.username,
              ),
            )
            .toList(growable: false)
          ..sort((left, right) => left.label.compareTo(right.label));

    final childGroups = children.values.map((child) => child.build()).toList()
      ..sort((left, right) => left.label.compareTo(right.label));
    return TreeSelectGroup(
      id: id,
      label: label,
      items: items,
      childGroups: childGroups,
    );
  }
}

Iterable<String> _collectScheduleUserItemIds(TreeSelectGroup group) sync* {
  for (final item in group.items) {
    yield item.id;
  }

  for (final childGroup in group.childGroups) {
    yield* _collectScheduleUserItemIds(childGroup);
  }
}
