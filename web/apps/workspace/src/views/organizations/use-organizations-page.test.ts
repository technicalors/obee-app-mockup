import type { Organization } from '#/api';

import { createApp, nextTick } from 'vue';

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { useOrganizationsPage } from './use-organizations-page';

type OrganizationPageActions = {
  onAction: (
    action: 'create-child' | 'delete' | 'edit' | 'view',
    organization: Organization,
  ) => void;
  parentOrganizationName: (parentId: null | string) => string;
};

const pageState = vi.hoisted(() => ({
  actions: null as null | OrganizationPageActions,
  api: {
    getAllRows: vi.fn(),
    organizations: [] as Organization[],
  },
  modal: {
    create: { open: vi.fn(), setData: vi.fn() },
    detail: { open: vi.fn(), setData: vi.fn() },
    nextModal: 0,
  },
  table: {
    reload: vi.fn(),
    remove: vi.fn(),
  },
}));

const uiState = vi.hoisted(() => ({
  confirm: vi.fn(),
  error: vi.fn(),
  success: vi.fn(),
}));

vi.mock('@vben/access', () => ({
  useAccess: () => ({ hasAccessByCodes: () => true }),
}));

vi.mock('@vben/common-ui', () => ({
  setupVbenForm: vi.fn(),
  useVbenForm: vi.fn(),
  useVbenModal: () => {
    const modal =
      pageState.modal.nextModal === 0
        ? pageState.modal.create
        : pageState.modal.detail;
    pageState.modal.nextModal += 1;
    return [{}, modal];
  },
}));

vi.mock('ant-design-vue', () => ({
  App: { useApp: () => ({ notification: uiState }) },
  Button: {},
  Modal: { confirm: uiState.confirm },
  notification: { error: uiState.error, success: uiState.success },
}));

vi.mock('vue-router', () => ({ useRouter: () => ({ push: vi.fn() }) }));

vi.mock('#/api', () => ({
  organizationsResource: {
    getAllRows: pageState.api.getAllRows,
  },
}));

vi.mock('#/locales', () => ({ $t: (key: string) => key }));

vi.mock('#/shared/resource-table', () => ({
  useResourceTable: () => [{}, pageState.table],
}));

vi.mock('#/store', () => ({ useAuthStore: () => ({ hasSession: true }) }));

vi.mock('./form', () => ({
  buildOrganizationCreatePayload: vi.fn(),
  buildOrganizationUpdatePayload: vi.fn(),
  toOrganizationFormValues: vi.fn(),
  useOrganizationFormSchema: () => ({
    createFormSchema: { value: [] },
    editFormSchema: { value: [] },
  }),
}));

vi.mock('./schema', () => ({
  createOrganizationTableColumns: (actions: OrganizationPageActions) => {
    pageState.actions = actions;
    return [];
  },
  createOrganizationTableFilterSchema: () => [],
}));

function createOrganization(name: string): Organization {
  return {
    created_at: '2026-06-11T00:00:00.000000Z',
    id: 'organization-parent',
    name,
    parent_id: null,
    tax_identification_number: null,
    type: 'Công ty',
    updated_at: '2026-06-11T00:00:00.000000Z',
  };
}

async function flushAsync(): Promise<void> {
  await Promise.resolve();
  await Promise.resolve();
  await nextTick();
}

function deferred<T>(): {
  promise: Promise<T>;
  resolve: (value: T) => void;
} {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>((resolvePromise) => {
    resolve = resolvePromise;
  });
  return { promise, resolve };
}

function mountComposable(): {
  app: ReturnType<typeof createApp>;
  page: ReturnType<typeof useOrganizationsPage>;
} {
  let page: null | ReturnType<typeof useOrganizationsPage> = null;
  const app = createApp({
    setup() {
      page = useOrganizationsPage();
      return {};
    },
    template: '<div />',
  });
  app.mount(document.createElement('div'));

  return {
    app,
    get page() {
      if (page === null) {
        throw new Error('Organization page composable did not mount.');
      }
      return page;
    },
  };
}

function getOnSaved(setData: ReturnType<typeof vi.fn>): () => Promise<void> {
  const data = setData.mock.lastCall?.[0] as undefined | { onSaved?: unknown };
  if (typeof data?.onSaved !== 'function') {
    throw new TypeError(
      'Organization modal did not receive its save callback.',
    );
  }
  return data.onSaved as () => Promise<void>;
}

beforeEach(() => {
  pageState.actions = null;
  pageState.api.organizations = [createOrganization('Initial name')];
  pageState.api.getAllRows
    .mockReset()
    .mockImplementation(() => Promise.resolve(pageState.api.organizations));
  pageState.modal.create.open.mockReset();
  pageState.modal.create.setData.mockReset();
  pageState.modal.detail.open.mockReset();
  pageState.modal.detail.setData.mockReset();
  pageState.modal.nextModal = 0;
  pageState.table.reload.mockReset().mockResolvedValue(undefined);
  pageState.table.remove.mockReset().mockResolvedValue(true);
  uiState.confirm.mockReset();
  uiState.error.mockReset();
  uiState.success.mockReset();
});

describe('useOrganizationsPage', () => {
  it('reloads parent names after create, edit, and delete', async () => {
    const mounted = mountComposable();
    await flushAsync();
    expect(pageState.api.getAllRows).toHaveBeenCalledOnce();

    mounted.page.openCreate();
    pageState.api.organizations = [createOrganization('Created name')];
    await getOnSaved(pageState.modal.create.setData)();
    expect(pageState.table.reload).toHaveBeenCalledOnce();
    expect(
      pageState.actions?.parentOrganizationName('organization-parent'),
    ).toBe('Created name');

    pageState.actions?.onAction('edit', createOrganization('Created name'));
    pageState.api.organizations = [createOrganization('Renamed parent')];
    await getOnSaved(pageState.modal.detail.setData)();
    expect(pageState.table.reload).toHaveBeenCalledTimes(2);
    expect(
      pageState.actions?.parentOrganizationName('organization-parent'),
    ).toBe('Renamed parent');

    pageState.actions?.onAction('delete', createOrganization('Renamed parent'));
    const confirmation = uiState.confirm.mock.lastCall?.[0] as
      | undefined
      | { onOk?: () => Promise<void> };
    if (confirmation?.onOk === undefined) {
      throw new Error('Organization delete confirmation was not configured.');
    }
    pageState.api.organizations = [];
    await confirmation.onOk();

    expect(pageState.table.remove).toHaveBeenCalledWith('organization-parent');
    expect(pageState.api.getAllRows).toHaveBeenCalledTimes(4);
    expect(() =>
      pageState.actions?.parentOrganizationName('organization-parent'),
    ).toThrow('Organization parent organization-parent is unavailable.');

    mounted.app.unmount();
  });

  it('keeps the newest parent collection when the initial load finishes late', async () => {
    const initialLoad = deferred<Organization[]>();
    const saveReload = deferred<Organization[]>();
    pageState.api.getAllRows
      .mockReset()
      .mockReturnValueOnce(initialLoad.promise)
      .mockReturnValueOnce(saveReload.promise);

    const mounted = mountComposable();
    mounted.page.openCreate();
    const saved = getOnSaved(pageState.modal.create.setData)();
    saveReload.resolve([createOrganization('Created parent')]);
    await saved;

    initialLoad.resolve([createOrganization('Initial parent')]);
    await flushAsync();

    expect(
      pageState.actions?.parentOrganizationName('organization-parent'),
    ).toBe('Created parent');
    expect(pageState.api.getAllRows).toHaveBeenCalledTimes(2);

    mounted.app.unmount();
  });
});
