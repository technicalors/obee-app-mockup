import type { Organization, OrganizationHierarchy } from '#/api/contracts';

export function getOrganizationRootId(
  organization: OrganizationHierarchy,
): string {
  let root = organization;
  while (root.parent !== null) {
    root = root.parent;
  }
  return root.id;
}

export function filterOrganizationsByRoot(
  organizations: Organization[],
  rootOrganizationId: string,
): Organization[] {
  const organizationsById = new Map(
    organizations.map((organization) => [organization.id, organization]),
  );

  return organizations.filter((organization) => {
    let current = organization;
    const visitedIds = new Set<string>();
    while (current.parent_id !== null) {
      if (visitedIds.has(current.id)) {
        throw new Error(`Organization ${current.id} has a hierarchy cycle.`);
      }
      visitedIds.add(current.id);
      const parent = organizationsById.get(current.parent_id);
      if (parent === undefined) {
        throw new Error(
          `Organization ${current.id} references unavailable parent ${current.parent_id}.`,
        );
      }
      current = parent;
    }
    return current.id === rootOrganizationId;
  });
}
