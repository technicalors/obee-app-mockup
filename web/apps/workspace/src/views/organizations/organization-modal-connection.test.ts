import type { App as VueApp } from 'vue';

import type { Organization } from '#/api';

import { createApp, defineComponent, h } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { useOrganizationsPage } from './use-organizations-page';

type OrganizationPageActions = {
  onAction: (
    action: 'create-child' | 'delete' | 'edit' | 'view',
    organization: Organization,
  ) => void;
};

const state = vi.hoisted(() => ({
  actions: null as null | OrganizationPageActions,
  api: {
    getAllRows: vi.fn(),
  },
  errors: [] as unknown[],
}));

vi.mock('@vben/access', () => ({
  useAccess: () => ({ hasAccessByCodes: () => true }),
}));

vi.mock('vue-router', () => ({ useRouter: () => ({ push: vi.fn() }) }));

vi.mock('#/api', () => ({
  organizationsResource: { getAllRows: state.api.getAllRows },
}));

vi.mock('#/locales', () => ({ $t: (key: string) => key }));

vi.mock('#/shared/resource-table', async () => {
  const { defineComponent } = await import('vue');

  return {
    useResourceTable: () => [defineComponent({ render: () => null }), {}],
  };
});

vi.mock('#/store', () => ({ useAuthStore: () => ({ hasSession: true }) }));

vi.mock('./schema', () => ({
  createOrganizationTableColumns: (actions: OrganizationPageActions) => {
    state.actions = actions;
    return [];
  },
  createOrganizationTableFilterSchema: () => [],
}));

function createOrganization(
  id: string,
  name: string,
  parent_id: null | string,
  type: Organization['type'],
): Organization {
  return {
    created_at: '2026-06-11T00:00:00.000000Z',
    id,
    name,
    parent_id,
    tax_identification_number: null,
    type,
    updated_at: '2026-06-11T00:00:00.000000Z',
  };
}

const parentOrganization = createOrganization(
  'root-1',
  'Parent',
  null,
  'Công ty',
);
const childOrganization = createOrganization(
  'child-1',
  'Operations',
  parentOrganization.id,
  'Nhóm',
);

vi.mock('./create-organization-modal.vue', async () => {
  const { defineComponent, h } = await import('vue');
  const { useVbenModal } = await import('@vben/common-ui');

  return {
    default: defineComponent({
      setup() {
        const [, modalApi] = useVbenModal();
        const isOpen = modalApi.useStore((modal) => modal.isOpen);
        return () =>
          h('div', {
            'data-open': String(isOpen.value),
            'data-testid': 'create-modal',
          });
      },
    }),
  };
});

vi.mock('./organization-detail-modal.vue', async () => {
  const { defineComponent, h } = await import('vue');
  const { useVbenModal } = await import('@vben/common-ui');

  return {
    default: defineComponent({
      setup() {
        const [, modalApi] = useVbenModal();
        const isOpen = modalApi.useStore((modal) => modal.isOpen);
        return () =>
          h('div', {
            'data-open': String(isOpen.value),
            'data-testid': 'detail-modal',
          });
      },
    }),
  };
});

const mountedApps: VueApp[] = [];
const mountedTargets: HTMLElement[] = [];

beforeEach(() => {
  state.actions = null;
  state.api.getAllRows
    .mockReset()
    .mockResolvedValue([parentOrganization, childOrganization]);
  state.errors = [];
});

afterEach(() => {
  mountedApps.splice(0).forEach((app) => app.unmount());
  mountedTargets.splice(0).forEach((target) => target.remove());
});

describe('organization page modal actions', () => {
  it('opens Create and View immediately through the real Vben modal connection', async () => {
    const Host = defineComponent({
      setup() {
        const page = useOrganizationsPage();
        return () =>
          h('main', [
            h('button', { onClick: () => page.openCreate() }, 'Create root'),
            h(
              'button',
              {
                onClick: () =>
                  state.actions?.onAction('view', childOrganization),
              },
              'View organization',
            ),
            h(page.CreateOrganizationModal),
            h(page.OrganizationDetailModal),
          ]);
      },
    });
    const target = document.createElement('div');
    const app = createApp(Host);
    app.config.errorHandler = (error) => state.errors.push(error);
    app.mount(target);
    mountedApps.push(app);
    mountedTargets.push(target);

    target.querySelectorAll('button')[0]?.click();
    await vi.waitFor(() =>
      expect(
        target.querySelector<HTMLElement>('[data-testid="create-modal"]')
          ?.dataset.open,
      ).toBe('true'),
    );

    await vi.waitFor(() => expect(state.actions).not.toBeNull());
    target.querySelectorAll('button')[1]?.click();
    await vi.waitFor(() =>
      expect(
        target.querySelector<HTMLElement>('[data-testid="detail-modal"]')
          ?.dataset.open,
      ).toBe('true'),
    );

    expect(state.errors).toEqual([]);
    expect(state.api.getAllRows).toHaveBeenCalledOnce();
  });
});
