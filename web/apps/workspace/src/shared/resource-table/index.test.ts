import { createApp, defineComponent, h } from 'vue';

import { describe, expect, it, vi } from 'vitest';

import { ResourceListPage, useResourceTable } from './index';

const gridState = vi.hoisted(() => ({
  api: {
    grid: {
      getProxyInfo: vi.fn(),
      setCurrentPage: vi.fn(),
    },
    query: vi.fn(),
  },
  options: null as null | ResourceTableGridOptions,
  useVbenVxeGrid: vi.fn((options: ResourceTableGridOptions) => {
    gridState.options = options;

    return [
      defineComponent({
        name: 'GridStub',
        template: '<div data-testid="grid-stub"></div>',
      }),
      gridState.api,
    ] as const;
  }),
}));

interface ResourceTableGridOptions {
  class?: unknown;
  formOptions?: unknown;
  gridClass?: unknown;
  gridOptions?: {
    autoResize?: boolean;
    height?: string;
    pagerConfig?: {
      pageSizes?: unknown;
    };
    proxyConfig?: {
      ajax?: {
        query?: unknown;
      };
      seq?: boolean;
    };
    toolbarConfig?: {
      custom?: boolean;
      export?: boolean;
      refresh?: boolean;
      search?: boolean;
      zoom?: boolean;
    };
  };
  showSearchForm?: boolean;
}

interface Row {
  id: number;
}

interface Query {
  page: number;
  per_page: number;
  search?: string;
}

interface Filters {
  search?: string;
}

vi.mock('@vben/common-ui', () => ({
  Page: {
    props: {
      autoContentHeight: Boolean,
      contentClass: String,
    },
    template:
      '<section data-testid="resource-page" :data-auto-content-height="String(autoContentHeight)" :data-content-class="contentClass"><slot /></section>',
  },
}));

vi.mock('#/adapter/vxe-table', () => ({
  useVbenVxeGrid: gridState.useVbenVxeGrid,
}));

vi.mock('#/shared/request-feedback', () => ({
  showRequestError: vi.fn(),
}));

describe('resource list page', () => {
  it('renders a full-height flex content shell inside the Vben page', () => {
    const target = document.createElement('div');
    document.body.append(target);

    const app = createApp({
      render: () =>
        h(ResourceListPage, null, {
          default: () => h('div', { 'data-testid': 'content' }),
        }),
    });
    app.mount(target);

    const pageElement = target.querySelector<HTMLElement>(
      '[data-testid="resource-page"]',
    );

    expect(pageElement?.dataset.autoContentHeight).toBe('true');
    expect(pageElement?.dataset.contentClass).toBe('overflow-hidden');
    expect(
      target.querySelector('.flex.h-full.min-h-0.flex-col'),
    ).not.toBeNull();
    expect(target.querySelector('[data-testid="content"]')).not.toBeNull();

    app.unmount();
    target.remove();
  });
});

describe('useResourceTable', () => {
  it('applies reusable full-height resource table defaults', () => {
    useResourceTable<Row, Query, Filters>({
      buildQuery: (pagination) => ({
        ...pagination,
      }),
      class: 'caller-class',
      errorMessage: 'Unable to load rows.',
      formOptions: {
        schema: [],
      },
      gridClass: 'caller-grid-class',
      gridOptions: {
        border: true,
        columns: [],
        toolbarConfig: {
          zoom: false,
        },
      },
      resource: {
        delete: vi.fn(),
        getAll: vi.fn(),
      },
    });

    expect(gridState.options).not.toBeNull();
    expect(gridState.options?.class).toEqual([
      'min-h-0 flex-1 overflow-hidden rounded border border-border bg-background shadow-none',
      'caller-class',
    ]);
    expect(gridState.options?.gridClass).toEqual([
      'h-full p-4',
      'caller-grid-class',
    ]);
    expect(gridState.options?.showSearchForm).toBe(false);
    expect(gridState.options?.gridOptions).toMatchObject({
      autoResize: true,
      border: true,
      height: 'auto',
      pagerConfig: {
        pageSizes: [
          { label: '10', value: 10 },
          { label: '20', value: 20 },
          { label: '30', value: 30 },
          { label: '50', value: 50 },
          { label: '100', value: 100 },
        ],
      },
      toolbarConfig: {
        custom: true,
        export: false,
        refresh: true,
        search: true,
        zoom: false,
      },
    });
    expect(gridState.options?.gridOptions?.proxyConfig?.ajax?.query).toBeTypeOf(
      'function',
    );
  });

  it('allows callers to open the filter panel by default', () => {
    useResourceTable<Row, Query, Filters>({
      buildQuery: (pagination) => ({
        ...pagination,
      }),
      errorMessage: 'Unable to load rows.',
      formOptions: {
        schema: [],
      },
      gridOptions: {
        columns: [],
      },
      resource: {
        delete: vi.fn(),
        getAll: vi.fn(),
      },
      showSearchForm: true,
    });

    expect(gridState.options?.showSearchForm).toBe(true);
  });

  it('keeps sequence numbering continuous across server-side pages', () => {
    useResourceTable<Row, Query, Filters>({
      buildQuery: (pagination) => ({
        ...pagination,
      }),
      errorMessage: 'Unable to load rows.',
      gridOptions: {
        columns: [],
      },
      resource: {
        delete: vi.fn(),
        getAll: vi.fn(),
      },
    });

    expect(gridState.options?.gridOptions?.proxyConfig?.seq).toBe(true);
  });

  it('supports paginated read-only resources', () => {
    expect(() =>
      useResourceTable<Row, Query, Filters>({
        buildQuery: (pagination) => ({
          ...pagination,
        }),
        errorMessage: 'Unable to load rows.',
        formOptions: {
          schema: [],
        },
        gridOptions: {
          columns: [],
        },
        resource: {
          getAll: vi.fn(),
        },
      }),
    ).not.toThrow();
  });
});
