import type { PaginatedList, ResourcePaginationQuery } from '#/api';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import { showRequestError } from '#/shared/request-feedback';

export { default as ResourceListPage } from './resource-list-page.vue';

type ResourceId = number | string;

const RESOURCE_TABLE_PAGE_SIZES = [
  { label: '10', value: 10 },
  { label: '20', value: 20 },
  { label: '30', value: 30 },
  { label: '50', value: 50 },
  { label: '100', value: 100 },
];

interface ResourceTableResource<
  Row extends object,
  Query extends ResourcePaginationQuery,
> {
  delete?: (id: ResourceId) => Promise<void>;
  getAll: (params: Query) => Promise<PaginatedList<Row>>;
}

interface ResourceTableQueryParams {
  page: {
    currentPage: number;
    pageSize: number;
  };
}

type VbenGridOptions<Row extends object> = NonNullable<
  Parameters<typeof useVbenVxeGrid<Row>>[0]
>;

type ResourceTableOptions<
  Row extends object,
  Query extends ResourcePaginationQuery,
  Filters extends object,
> = Omit<VbenGridOptions<Row>, 'formOptions' | 'gridOptions'> & {
  buildQuery: (pagination: ResourcePaginationQuery, filters: Filters) => Query;
  enabled?: () => boolean;
  errorMessage: string;
  formOptions?: VbenGridOptions<Row>['formOptions'];
  gridOptions: Omit<
    NonNullable<VbenGridOptions<Row>['gridOptions']>,
    'proxyConfig'
  >;
  resource: ResourceTableResource<Row, Query>;
};

export function useResourceTable<
  Row extends object,
  Query extends ResourcePaginationQuery,
  Filters extends object = Record<string, never>,
>(options: ResourceTableOptions<Row, Query, Filters>) {
  const {
    buildQuery,
    enabled,
    errorMessage,
    formOptions,
    resource,
    ...tableOptions
  } = options;
  const [Grid, gridApi] = useVbenVxeGrid<Row>({
    ...tableOptions,
    class: [
      'min-h-0 flex-1 overflow-hidden rounded border border-border bg-background shadow-none',
      options.class,
    ],
    formOptions,
    gridClass: ['h-full p-4', options.gridClass],
    showSearchForm:
      options.showSearchForm === undefined ? false : options.showSearchForm,
    gridOptions: {
      autoResize: true,
      height: 'auto',
      ...options.gridOptions,
      pagerConfig: {
        ...options.gridOptions.pagerConfig,
        pageSizes: RESOURCE_TABLE_PAGE_SIZES,
      },
      proxyConfig: {
        seq: true,
        ajax: {
          query: async (
            { page }: ResourceTableQueryParams,
            filters: Filters,
          ) => {
            const canLoad = enabled === undefined || enabled();
            if (!canLoad) {
              return { items: [], total: 0 };
            }

            try {
              const result = await resource.getAll(
                buildQuery(
                  {
                    page: page.currentPage,
                    per_page: page.pageSize,
                  },
                  filters,
                ),
              );

              return {
                items: result.items,
                total: result.pagination.total,
              };
            } catch (error) {
              showRequestError(
                error,
                errorMessage,
                'Unexpected resource table query error:',
              );
              throw error;
            }
          },
        },
      },
      toolbarConfig: {
        custom: true,
        export: false,
        refresh: true,
        search: formOptions !== undefined,
        zoom: true,
        ...options.gridOptions.toolbarConfig,
      },
    },
  });

  async function reload(): Promise<void> {
    await gridApi.query();
  }

  async function remove(id: ResourceId): Promise<boolean> {
    try {
      if (resource.delete === undefined) {
        throw new Error('This resource does not support deletion.');
      }

      const proxyInfo = gridApi.grid.getProxyInfo();
      if (proxyInfo === null) {
        throw new Error('Resource table proxy information is unavailable.');
      }

      await resource.delete(id);

      const lastPage = Math.max(
        1,
        Math.ceil(
          Math.max(0, proxyInfo.pager.total - 1) / proxyInfo.pager.pageSize,
        ),
      );

      if (proxyInfo.pager.currentPage > lastPage) {
        await gridApi.grid.setCurrentPage(lastPage);
      }

      await reload();
      return true;
    } catch (error) {
      showRequestError(
        error,
        errorMessage,
        'Unexpected resource table delete error:',
      );
      return false;
    }
  }

  return [Grid, { reload, remove }] as const;
}
