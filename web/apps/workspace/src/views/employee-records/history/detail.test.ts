import { createApp, defineComponent, h } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import DetailView from './detail.vue';

const usersResourceMock = vi.hoisted(() => ({
  getById: vi.fn(),
}));
const routeMock = vi.hoisted(() => ({
  params: { user: 'user-123' },
}));
const routerMock = vi.hoisted(() => ({
  push: vi.fn(),
}));

vi.mock('#/api', () => ({
  usersResource: usersResourceMock,
}));

vi.mock('vue-router', () => ({
  useRoute: () => routeMock,
  useRouter: () => routerMock,
}));

vi.mock('#/locales', () => ({
  $t: (key: string) => key,
}));

vi.mock('@vben/common-ui', () => ({
  Page: {
    template:
      '<div data-testid="page"><slot name="title" /><slot /><slot name="extra" /></div>',
  },
}));

vi.mock('@vben/icons', () => ({
  IconifyIcon: {
    template: '<span class="iconify" />',
  },
}));

vi.mock('./employee-record-card.vue', () => ({
  default: {
    template: '<div data-testid="employee-record-card" />',
  },
}));

vi.mock('./employee-summary-card.vue', () => ({
  default: {
    template: '<div data-testid="employee-summary-card" />',
  },
}));

describe('employee history detail view', () => {
  let app: null | ReturnType<typeof createApp> = null;
  let target: HTMLDivElement | null = null;

  beforeEach(() => {
    usersResourceMock.getById.mockReset();
    routerMock.push.mockReset();
    routeMock.params.user = 'user-123';
    target = document.createElement('div');
    document.body.append(target);
  });

  afterEach(() => {
    app?.unmount();
    target?.remove();
    app = null;
    target = null;
  });

  it('loads the user on mount using the route param', async () => {
    const user = { id: 'user-123', name: 'Nguyen Van Test' };
    usersResourceMock.getById.mockResolvedValue(user);

    const host = defineComponent({
      setup() {
        return () => h(DetailView);
      },
    });

    app = createApp(host);
    app.mount(target as HTMLDivElement);

    await Promise.resolve();
    await Promise.resolve();

    expect(usersResourceMock.getById).toHaveBeenCalledWith('user-123');
  });
});
