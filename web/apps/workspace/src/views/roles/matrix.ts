import type { Permission } from '#/api';

export const CRUD_ACTIONS = [
  'viewAny',
  'view',
  'create',
  'update',
  'delete',
] as const;

export type CrudAction = (typeof CRUD_ACTIONS)[number];

export interface PermissionMatrixResource {
  displayName: string;
  permissions: Partial<Record<CrudAction, Permission>>;
  resource: string;
}

export function formatPermissionResource(resource: string): string {
  const displayName = resource.replaceAll(/[-.]/g, ' ');
  const [firstCharacter, ...remainingCharacters] = displayName;
  if (firstCharacter === undefined) {
    throw new Error('Permission resource name cannot be empty.');
  }

  return `${firstCharacter.toUpperCase()}${remainingCharacters.join('')}`;
}

export function createPermissionMatrix(
  permissions: readonly Permission[],
): PermissionMatrixResource[] {
  const resources = new Map<string, PermissionMatrixResource>();

  for (const permission of permissions) {
    const separator = permission.name.lastIndexOf('.');
    const action = permission.name.slice(separator + 1);
    if (!CRUD_ACTIONS.includes(action as CrudAction)) {
      continue;
    }

    const resourceName = permission.name.slice(0, separator);
    const resource = resources.get(resourceName);
    if (resource !== undefined) {
      resource.permissions[action as CrudAction] = permission;
      continue;
    }

    resources.set(resourceName, {
      displayName: formatPermissionResource(resourceName),
      permissions: { [action]: permission },
      resource: resourceName,
    });
  }

  return [...resources.values()].toSorted((left, right) =>
    left.displayName.localeCompare(right.displayName),
  );
}

export function mergeMatrixPermissionIds(
  existingIds: readonly string[],
  matrix: readonly PermissionMatrixResource[],
  selectedIds: readonly string[],
): string[] {
  const matrixIds = new Set(
    matrix.flatMap((resource) =>
      Object.values(resource.permissions).flatMap((permission) =>
        permission === undefined ? [] : [permission.id],
      ),
    ),
  );

  return [
    ...new Set([
      ...existingIds.filter((id) => !matrixIds.has(id)),
      ...selectedIds,
    ]),
  ];
}

export function hasSamePermissionIds(
  leftIds: readonly string[],
  rightIds: readonly string[],
): boolean {
  if (leftIds.length !== rightIds.length) {
    return false;
  }

  const rightIdSet = new Set(rightIds);

  return leftIds.every((id) => rightIdSet.has(id));
}
