import { createApp, defineComponent, h } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { useEmployeeHistoryList } from './use-employee-history-list';

const routerMock = vi.hoisted(() => ({
  push: vi.fn(),
}));

let capturedOptions: any = null;

const modalMock = vi.hoisted(() => ({
  open: vi.fn(),
  setData: vi.fn(),
}));

const antdModalMock = vi.hoisted(() => ({
  confirm: vi.fn(),
}));

const notificationMock = vi.hoisted(() => ({
  success: vi.fn(),
}));

const tableRemoveMock = vi.fn();
const tableReloadMock = vi.fn();

vi.mock('vue-router', () => ({
  useRouter: () => routerMock,
}));

vi.mock('#/api', () => ({
  usersResource: {},
}));

vi.mock('#/locales', () => ({
  $t: (key: string) => key,
}));

vi.mock('@vben/access', () => ({
  useAccess: () => ({
    hasAccessByCodes: vi.fn().mockReturnValue(true),
  }),
}));

vi.mock('@vben/common-ui', () => ({
  useVbenModal: () => [
    defineComponent({ setup: () => () => h('div') }),
    modalMock,
  ],
}));

vi.mock('ant-design-vue', () => ({
  Modal: antdModalMock,
  notification: notificationMock,
}));

vi.mock('#/store', () => ({
  useAuthStore: () => ({
    hasSession: true,
  }),
}));

vi.mock('#/shared/resource-table', () => ({
  useResourceTable: (options: unknown) => {
    capturedOptions = options;
    return [
      defineComponent({ setup: () => () => h('div') }),
      { reload: tableReloadMock, remove: tableRemoveMock },
    ];
  },
}));

describe('useEmployeeHistoryList', () => {
  let app: null | ReturnType<typeof createApp> = null;
  let target: HTMLDivElement | null = null;

  beforeEach(() => {
    routerMock.push.mockReset();
    modalMock.open.mockReset();
    modalMock.setData.mockReset();
    antdModalMock.confirm.mockReset();
    notificationMock.success.mockReset();
    tableRemoveMock.mockReset();
    tableReloadMock.mockReset();
    capturedOptions = null;
    target = document.createElement('div');
    document.body.append(target);
  });

  afterEach(() => {
    app?.unmount();
    target?.remove();
    app = null;
    target = null;
  });

  it('navigates to detail route when detail action is dispatched', () => {
    const host = defineComponent({
      setup() {
        useEmployeeHistoryList();
        return () => h('div');
      },
    });

    app = createApp(host);
    app.mount(target as HTMLDivElement);

    expect(capturedOptions).toBeDefined();

    const columns = capturedOptions.gridOptions.columns;
    const actionsCol = columns.find((col: any) => col.field === 'actions');
    const mockUser = { id: 'user-abc', name: 'Le Thi C' };

    actionsCol.cellRender.attrs.onClick('detail', mockUser);

    expect(routerMock.push).toHaveBeenCalledWith(
      '/employee-records/history/user-abc',
    );
  });

  it('opens edit modal with user data when edit action is dispatched', () => {
    const host = defineComponent({
      setup() {
        useEmployeeHistoryList();
        return () => h('div');
      },
    });

    app = createApp(host);
    app.mount(target as HTMLDivElement);

    const columns = capturedOptions.gridOptions.columns;
    const actionsCol = columns.find((col: any) => col.field === 'actions');
    const mockUser = { id: 'user-xyz', name: 'Tran Van D' };

    actionsCol.cellRender.attrs.onClick('edit', mockUser);

    expect(modalMock.setData).toHaveBeenCalledWith(
      expect.objectContaining({
        mode: 'edit',
        userId: mockUser.id,
      }),
    );
    expect(modalMock.open).toHaveBeenCalled();
  });

  it('shows delete confirmation and removes user when delete action is confirmed', async () => {
    tableRemoveMock.mockResolvedValue(true);

    const host = defineComponent({
      setup() {
        useEmployeeHistoryList();
        return () => h('div');
      },
    });

    app = createApp(host);
    app.mount(target as HTMLDivElement);

    const columns = capturedOptions.gridOptions.columns;
    const actionsCol = columns.find((col: any) => col.field === 'actions');
    const mockUser = { id: 'user-del', name: 'Nguyen Van E' };

    actionsCol.cellRender.attrs.onClick('delete', mockUser);

    expect(antdModalMock.confirm).toHaveBeenCalled();

    const confirmOptions = antdModalMock.confirm.mock.calls[0]?.[0];
    expect(confirmOptions?.title).toBe('users.delete.title');

    await confirmOptions?.onOk();

    expect(tableRemoveMock).toHaveBeenCalledWith('user-del');
    expect(notificationMock.success).toHaveBeenCalledWith({
      message: 'users.messages.deleted',
    });
  });
});
