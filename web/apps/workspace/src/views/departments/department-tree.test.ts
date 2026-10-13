import type { Department } from '#/api';

import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { describe, expect, it } from 'vitest';

import { buildDepartmentTree } from './department-tree';

const treeViewSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/departments/department-tree.vue',
  ),
  'utf8',
);
const organizationGraphSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/departments/department-organization-graph.vue',
  ),
  'utf8',
);
const treeDrawerSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/departments/department-tree-drawer.vue',
  ),
  'utf8',
);
const departmentFormSource = readFileSync(
  resolve(process.cwd(), 'apps/workspace/src/views/departments/form.ts'),
  'utf8',
);
const appSource = readFileSync(
  resolve(process.cwd(), 'apps/workspace/src/app.vue'),
  'utf8',
);
const createDepartmentModalSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/departments/create-department-modal.vue',
  ),
  'utf8',
);
const departmentDetailModalSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/departments/department-detail-modal.vue',
  ),
  'utf8',
);
const departmentDetailContentSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/departments/department-detail-content.vue',
  ),
  'utf8',
);
const departmentSchemaSource = readFileSync(
  resolve(process.cwd(), 'apps/workspace/src/views/departments/schema.tsx'),
  'utf8',
);

function makeDepartment(overrides: Partial<Department> = {}): Department {
  return {
    company_id: 'company-1',
    created_at: null,
    id: 'department-1',
    name: 'Department',
    parent_id: null,
    updated_at: null,
    ...overrides,
  };
}

describe('buildDepartmentTree', () => {
  it('nests departments below their parent', () => {
    const tree = buildDepartmentTree([
      makeDepartment({ id: 'child', name: 'Support', parent_id: 'root' }),
      makeDepartment({ id: 'root', name: 'Operations' }),
      makeDepartment({ id: 'other-root', name: 'Sales' }),
    ]);

    expect(tree).toMatchObject([
      {
        children: [
          {
            children: [],
            department: { id: 'child', name: 'Support' },
          },
        ],
        department: { id: 'root', name: 'Operations' },
      },
      {
        children: [],
        department: { id: 'other-root', name: 'Sales' },
      },
    ]);
  });

  it('rejects a department with an unavailable parent', () => {
    expect(() =>
      buildDepartmentTree([
        makeDepartment({ id: 'child', parent_id: 'missing' }),
      ]),
    ).toThrow('Department child has an unavailable parent.');
  });

  it('renders the organization tree with a non-overlapping tree layout', () => {
    expect(treeViewSource).toContain('<DepartmentOrganizationGraph');
    expect(organizationGraphSource).toContain(".layout('top')");
    expect(organizationGraphSource).toContain('.siblingsMargin(() => 42)');
    expect(organizationGraphSource).toContain('.childrenMargin(() => 94)');
    expect(organizationGraphSource).toContain('scheduleFit(260);');
    expect(organizationGraphSource).toContain('ref="container"');
  });

  it('localizes organization-chart labels', () => {
    expect(organizationGraphSource).toContain(
      "$t('page.departments.tree.chart.companyNode')",
    );
    expect(organizationGraphSource).toContain(
      "$t('page.departments.tree.chart.departmentLevel'",
    );
    expect(organizationGraphSource).not.toContain('Công ty');
    expect(organizationGraphSource).not.toContain('Phòng ban trực thuộc');
  });

  it('highlights hovered nodes and edges without lowering the drawer stack', () => {
    expect(organizationGraphSource).toContain('setRelatedLinksActive(');
    expect(organizationGraphSource).toContain('path.department-org-link');
    expect(organizationGraphSource).toContain('stroke: hsl(var(--primary));');
    expect(organizationGraphSource).toContain(
      'nodeHoverControllers.get(this)?.abort();',
    );
    expect(organizationGraphSource).toContain(
      "this.addEventListener(\n        'mouseenter'",
    );
    expect(treeDrawerSource).not.toContain(':z-index=');
  });

  it('keeps department dropdowns above forms opened from the drawer', () => {
    expect(treeViewSource).toContain('const DRAWER_FORM_MODAL_Z_INDEX = 2100;');
    expect(treeViewSource).toContain('zIndex: DRAWER_FORM_MODAL_Z_INDEX');
    expect(
      departmentFormSource.match(/dropdownStyle: \{ zIndex: 2200 \}/g),
    ).toHaveLength(2);
  });

  it('keeps department modal notifications above forms opened from the drawer', () => {
    expect(appSource).toContain('zIndexPopup: 2200');
    expect(createDepartmentModalSource).toContain('App.useApp()');
    expect(createDepartmentModalSource).toContain('notification,');
    expect(departmentDetailModalSource).toContain('App.useApp()');
    expect(departmentDetailModalSource).toContain('notification,');
  });

  it('truncates long department names in the tree and drawer title', () => {
    expect(organizationGraphSource).toContain('text-overflow: ellipsis;');
    expect(organizationGraphSource).toContain('white-space: nowrap;');
    expect(treeDrawerSource).toContain('<template #title>');
    expect(treeDrawerSource).toContain('class="block max-w-72 truncate"');
  });

  it('uses the drawer detail layout in the modal without action controls', () => {
    expect(treeDrawerSource).toContain('<DepartmentDetailContent');
    expect(departmentDetailModalSource).toContain('<DepartmentDetailContent');
    expect(treeDrawerSource).toContain('<template #extra>');
    expect(departmentDetailModalSource).not.toContain('<template #extra>');
    expect(departmentDetailModalSource).toContain(
      "$t('page.departments.detail.title')",
    );
    expect(departmentDetailModalSource).toContain(
      "$t('page.departments.fields.department')",
    );
    expect(departmentDetailModalSource).toContain('{{ department.name }}');
  });

  it('localizes the cancel action in department form modals', () => {
    expect(createDepartmentModalSource).toContain(
      "cancelText: $t('page.departments.actions.cancel')",
    );
    expect(departmentDetailModalSource).toContain(
      "cancelText: $t('page.departments.actions.cancel')",
    );
  });

  it('loads and displays five department members per page', () => {
    expect(departmentDetailContentSource).toContain(
      'const MEMBER_PAGE_SIZE = 5;',
    );
    expect(departmentDetailContentSource).toContain(
      'per_page: MEMBER_PAGE_SIZE',
    );
    expect(departmentDetailContentSource).toContain(
      ':page-size="MEMBER_PAGE_SIZE"',
    );
    expect(departmentDetailContentSource).toContain(
      'class="w-full rounded border"',
    );
    expect(departmentDetailContentSource).not.toContain('overflow-x-auto');
    expect(departmentDetailContentSource).not.toContain('min-w-[620px]');
  });

  it('mutes departments without a parent in the table', () => {
    expect(departmentSchemaSource).toContain(
      "row.parent === null ? 'text-muted-foreground' : ''",
    );
  });
});
