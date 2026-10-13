import type { Department } from '#/api';

export interface DepartmentTreeNode {
  children: DepartmentTreeNode[];
  department: Department;
}

export function buildDepartmentTree(
  departments: Department[],
): DepartmentTreeNode[] {
  const nodes = new Map<string, DepartmentTreeNode>();

  for (const department of departments) {
    nodes.set(department.id, { children: [], department });
  }

  const roots: DepartmentTreeNode[] = [];

  for (const node of nodes.values()) {
    if (node.department.parent_id === null) {
      roots.push(node);
      continue;
    }

    const parent = nodes.get(node.department.parent_id);

    if (parent === undefined) {
      throw new Error(
        `Department ${node.department.id} has an unavailable parent.`,
      );
    }

    parent.children.push(node);
  }

  return roots;
}
