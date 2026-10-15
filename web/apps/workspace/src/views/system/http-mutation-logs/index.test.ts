/* eslint-disable vue/one-component-per-file */

import { createApp, nextTick } from 'vue';

import { afterEach, describe, expect, it, vi } from 'vitest';

import MutationLogsPage from './index.vue';

vi.mock('ant-design-vue', async () => {
  const { defineComponent, h } = await import('vue');
  const passthrough = defineComponent({
    setup(_, { slots }) {
      return () => h('div', slots.default?.());
    },
  });
  const Drawer = defineComponent({
    props: { open: Boolean },
    setup(props, { slots }) {
      return () => (props.open ? h('div', slots.default?.()) : null);
    },
  });
  return {
    Button: passthrough,
    Descriptions: passthrough,
    DescriptionsItem: passthrough,
    DatePicker: passthrough,
    Drawer,
    Input: passthrough,
    InputNumber: passthrough,
    Select: passthrough,
    Spin: passthrough,
  };
});

vi.mock('#/locales', () => ({ $t: (key: string) => key }));
vi.mock('#/shared/resource-table', async () => {
  const { defineComponent, h } = await import('vue');
  return {
    ResourceListPage: defineComponent({
      setup(_, { slots }) {
        return () => h('div', slots.default?.());
      },
    }),
  };
});
vi.mock('./use-http-mutation-logs-page', async () => {
  const { defineComponent, h, ref } = await import('vue');
  return {
    useHttpMutationLogsPage: () => ({
      actionOptions: ref([]),
      applyFilters: vi.fn(),
      clearFilters: vi.fn(),
      closeDetail: vi.fn(),
      copyMarkdown: vi.fn(),
      detail: ref({
        action: 'UpdateUserAction',
        app_url: 'https://obee.local',
        code: 'ABC1234',
        code_snippet: 'throw new Error()',
        git_sha_1: 'unknown',
        id: '019e2444-4fa6-716d-a1fe-58fd4e9c602d',
        instance_id: null,
        is_error: true,
        logged_at: '2026-05-15T08:30:00Z',
        payload: '{"body":{"title":"Updated"}}',
        requested_by: '019e2444-4fa6-716d-a1fe-58fd4e9c602e',
        requested_by_user: null,
        response: '[json-response]',
        response_status: 500,
        trace: [{ file: 'app/Actions/User/UpdateUserAction.php', line: 20 }],
        uri: '/api/users',
      }),
      detailLoading: ref(false),
      detailOpen: ref(true),
      draft: ref({}),
      filtersOpen: ref(false),
      Grid: defineComponent({
        setup() {
          return () => h('div', 'grid');
        },
      }),
      loadActionSuggestions: vi.fn(),
      loadUserSuggestions: vi.fn(),
      userOptions: ref([]),
    }),
  };
});

let container: HTMLDivElement | null = null;

afterEach(() => {
  container?.remove();
  container = null;
});

describe('mutation logs detail screen', () => {
  it('renders the recorded response marker, source snippet, and trace as text', async () => {
    container = document.createElement('div');
    document.body.append(container);
    const app = createApp(MutationLogsPage);
    app.mount(container);
    await nextTick();

    expect(container.textContent).toContain('[json-response]');
    expect(container.textContent).toContain('throw new Error()');
    expect(container.textContent).toContain(
      'app/Actions/User/UpdateUserAction.php',
    );
    expect(container.textContent).toContain('ABC1234');
    expect(container.textContent).not.toContain(
      '019e2444-4fa6-716d-a1fe-58fd4e9c602e',
    );
    app.unmount();
  });
});
