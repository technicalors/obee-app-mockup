import type { UserTreeSelectionUser } from '#/api/contracts';

type UserTreeOrganization = UserTreeSelectionUser['organization'];

export interface UserTreeOption {
  children?: UserTreeOption[];
  key: string;
  label: string;
  searchText: string;
  selectable?: boolean;
  value: string;
}

export function buildUserTreeOptions(
  users: UserTreeSelectionUser[],
): UserTreeOption[] {
  const organizationsById = new Map<string, UserTreeOrganization>();
  const usersByOrganizationId = new Map<string, UserTreeSelectionUser[]>();

  for (const user of users) {
    const organizationUsers = usersByOrganizationId.get(user.organization_id);
    if (organizationUsers === undefined) {
      usersByOrganizationId.set(user.organization_id, [user]);
    } else {
      organizationUsers.push(user);
    }

    let organization: null | UserTreeOrganization = user.organization;
    while (organization !== null) {
      const existing = organizationsById.get(organization.id);
      if (
        existing !== undefined &&
        existing.parent_id !== organization.parent_id
      ) {
        throw new Error(
          `Organization ${organization.id} has conflicting parents.`,
        );
      }
      organizationsById.set(organization.id, organization);
      organization = organization.parent;
    }
  }

  const organizationsByParentId = new Map<
    null | string,
    UserTreeOrganization[]
  >();
  for (const organization of organizationsById.values()) {
    const siblings = organizationsByParentId.get(organization.parent_id);

    if (siblings === undefined) {
      organizationsByParentId.set(organization.parent_id, [organization]);
    } else {
      siblings.push(organization);
    }
  }

  return buildOrganizationOptions(
    null,
    organizationsByParentId,
    usersByOrganizationId,
  );
}

function buildOrganizationOptions(
  parentOrganizationId: null | string,
  organizationsByParentId: Map<null | string, UserTreeOrganization[]>,
  usersByOrganizationId: Map<string, UserTreeSelectionUser[]>,
): UserTreeOption[] {
  return (organizationsByParentId.get(parentOrganizationId) ?? [])
    .toSorted((left, right) => left.name.localeCompare(right.name))
    .map((organization) => {
      return {
        children: [
          ...buildOrganizationOptions(
            organization.id,
            organizationsByParentId,
            usersByOrganizationId,
          ),
          ...buildUserOptions(usersByOrganizationId.get(organization.id) ?? []),
        ],
        key: `organization-${organization.id}`,
        label: organization.name,
        searchText: organization.name,
        selectable: false,
        value: `organization-${organization.id}`,
      };
    });
}

function buildUserOptions(users: UserTreeSelectionUser[]): UserTreeOption[] {
  return [...users]
    .toSorted((left, right) => left.name.localeCompare(right.name))
    .map((user) => ({
      key: user.id,
      label: user.name,
      searchText:
        user.profile === null
          ? `${user.name} ${user.username}`
          : `${user.name} ${user.username} ${user.profile.code}`,
      value: user.id,
    }));
}
