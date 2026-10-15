import type { Organization } from '#/api';

export interface OrganizationTreeNode {
  children: OrganizationTreeNode[];
  organization: Organization;
}

export interface OrganizationGraphDatum {
  childCount: number;
  id: string;
  label: string;
  level: number;
  organization: Organization;
  parentId: null | string;
  type: string;
}

export function buildOrganizationTree(
  organizations: Organization[],
): OrganizationTreeNode[] {
  const nodes = new Map<string, OrganizationTreeNode>();
  for (const organization of organizations) {
    nodes.set(organization.id, { children: [], organization });
  }

  const roots: OrganizationTreeNode[] = [];
  for (const node of nodes.values()) {
    const parentId = node.organization.parent_id;
    if (parentId === null) {
      roots.push(node);
      continue;
    }

    const parent = nodes.get(parentId);
    if (parent === undefined) {
      throw new Error(
        `Organization ${node.organization.id} has an unavailable parent.`,
      );
    }
    parent.children.push(node);
  }

  const visited = new Set<string>();
  const visit = (node: OrganizationTreeNode): void => {
    if (visited.has(node.organization.id)) {
      throw new Error(`Organization ${node.organization.id} has a cycle.`);
    }
    visited.add(node.organization.id);
    for (const child of node.children) {
      visit(child);
    }
  };
  for (const root of roots) {
    visit(root);
  }
  if (visited.size !== organizations.length) {
    throw new Error('The organization hierarchy has an unreachable cycle.');
  }

  return roots;
}

export function buildOrganizationGraphData(
  roots: OrganizationTreeNode[],
): OrganizationGraphDatum[] {
  const result: OrganizationGraphDatum[] = [];

  function appendNode(
    node: OrganizationTreeNode,
    parentId: null | string,
    level: number,
  ): void {
    result.push({
      childCount: node.children.length,
      id: node.organization.id,
      label: node.organization.name,
      level,
      organization: node.organization,
      parentId,
      type: node.organization.type,
    });

    for (const child of node.children) {
      appendNode(child, node.organization.id, level + 1);
    }
  }

  for (const root of roots) {
    appendNode(root, null, 0);
  }

  return result;
}

export function escapeOrganizationChartHtml(value: string): string {
  const entities: Record<string, string> = {
    '"': '&quot;',
    '&': '&amp;',
    "'": '&#039;',
    '<': '&lt;',
    '>': '&gt;',
  };

  return value.replaceAll(
    /[&<>"']/g,
    (character) => entities[character] ?? character,
  );
}
