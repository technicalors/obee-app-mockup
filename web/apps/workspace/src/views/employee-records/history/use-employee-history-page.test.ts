import { createApp, defineComponent, h } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { useEmployeeHistoryPage } from './use-employee-history-page';

const usersResourceMock = vi.hoisted(() => ({
  getById: vi.fn(),
}));

vi.mock('#/api', () => ({
  usersResource: usersResourceMock,
}));

describe('useEmployeeHistoryPage', () => {
  let app: null | ReturnType<typeof createApp> = null;
  let target: HTMLDivElement | null = null;

  beforeEach(() => {
    usersResourceMock.getById.mockReset();
    target = document.createElement('div');
    document.body.append(target);
  });

  afterEach(() => {
    app?.unmount();
    target?.remove();
    app = null;
    target = null;
  });

  function mountPage() {
    let page!: ReturnType<typeof useEmployeeHistoryPage>;

    const host = defineComponent({
      setup() {
        page = useEmployeeHistoryPage();
        return () => h('div');
      },
    });

    app = createApp(host);
    app.mount(target as HTMLDivElement);

    return page;
  }

  it('keeps the loading state active until the selected employee is loaded', async () => {
    let resolveRequest: (value: unknown) => void = () => {
      throw new Error('The employee request resolver was not initialized.');
    };
    const request = new Promise((resolve) => {
      resolveRequest = resolve;
    });
    const selectedUser = { id: 'user-1', name: 'Nguyen Van An' };
    usersResourceMock.getById.mockReturnValue(request);

    const page = mountPage();
    const selection = page.selectUser('user-1');

    expect(page.isLoading.value).toBe(true);
    expect(page.selectedUser.value).toBeNull();
    expect(usersResourceMock.getById).toHaveBeenCalledWith('user-1');

    resolveRequest(selectedUser);
    await selection;

    expect(page.isLoading.value).toBe(false);
    expect(page.selectedUser.value).toEqual(selectedUser);
  });

  it('clears the selected employee', async () => {
    const selectedUser = { id: 'user-1', name: 'Nguyen Van An' };
    usersResourceMock.getById.mockResolvedValue(selectedUser);

    const page = mountPage();
    await page.selectUser('user-1');
    page.clearUser();

    expect(page.selectedUser.value).toBeNull();
    expect(page.isLoading.value).toBe(false);
  });
});
