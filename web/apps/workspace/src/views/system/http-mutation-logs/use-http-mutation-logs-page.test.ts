import { beforeEach, describe, expect, it, vi } from 'vitest';

import { useHttpMutationLogsPage } from './use-http-mutation-logs-page';

const access = vi.hoisted(() => ({ allowed: true }));
const api = vi.hoisted(() => ({
  detail: vi.fn(),
  markdown: vi.fn(),
}));
const feedback = vi.hoisted(() => ({ show: vi.fn() }));
const clipboard = vi.hoisted(() => ({ writeText: vi.fn() }));
const notifications = vi.hoisted(() => ({ success: vi.fn() }));
const resourceTable = vi.hoisted(() => ({ capture: vi.fn(), reload: vi.fn() }));

vi.mock('@vben/access', () => ({
  useAccess: () => ({ hasAccessByCodes: () => access.allowed }),
}));
vi.mock('ant-design-vue', () => ({
  notification: notifications,
}));
vi.mock('#/api', () => ({
  getHttpMutationLogApi: api.detail,
  getHttpMutationLogMarkdownApi: api.markdown,
  httpMutationLogsResource: { getAll: vi.fn() },
  suggestHttpMutationLogActionsApi: vi.fn(),
  suggestHttpMutationLogUsersApi: vi.fn(),
}));
vi.mock('#/locales', () => ({ $t: (key: string) => key }));
vi.mock('#/shared/request-feedback', () => ({
  showRequestError: feedback.show,
}));
vi.mock('#/shared/resource-table', () => ({
  useResourceTable: (options: unknown) => {
    resourceTable.capture(options);
    return [{}, { reload: resourceTable.reload }];
  },
}));
vi.mock('#/store', () => ({
  useAuthStore: () => ({ hasSession: true }),
}));

const id = '019e2444-4fa6-716d-a1fe-58fd4e9c602d';
const log = {
  action: 'UpdateUserAction',
  app_url: 'https://obee.local',
  code: 'ABC1234',
  code_snippet: 'throw new Error()',
  git_sha_1: 'unknown',
  id,
  instance_id: null,
  is_error: true,
  logged_at: '2026-05-15T08:30:00.000000Z',
  payload: '{"body":{"title":"Updated"}}',
  requested_by: null,
  requested_by_user: null,
  response: '[json-response]',
  response_status: 500,
  trace: [{ file: 'app/Actions/User/UpdateUserAction.php', line: 20 }],
  uri: '/api/users',
};

describe('mutation log detail', () => {
  beforeEach(() => {
    access.allowed = true;
    api.detail.mockReset();
    api.markdown.mockReset();
    feedback.show.mockReset();
    clipboard.writeText.mockReset();
    notifications.success.mockReset();
    resourceTable.capture.mockReset();
    resourceTable.reload.mockReset();
    vi.stubGlobal('navigator', { clipboard });
  });

  it('accepts a valid time interval across different UTC offsets', async () => {
    const page = useHttpMutationLogsPage();
    page.draft.value.from = '2026-05-15T09:00:00+07:00';
    page.draft.value.to = '2026-05-15T03:30:00+00:00';

    await page.applyFilters();

    expect(resourceTable.reload).toHaveBeenCalledOnce();
    expect(feedback.show).not.toHaveBeenCalled();
  });

  it('uses the Vxe toolbar search icon to toggle filters without mounting a Vben form', () => {
    const page = useHttpMutationLogsPage();
    const options = resourceTable.capture.mock.lastCall?.[0] as {
      formOptions?: unknown;
      gridEvents: {
        toolbarToolClick: (event: { code: string }) => void;
      };
      gridOptions: {
        toolbarConfig: {
          tools: Array<{ code: string; icon: string; status?: string }>;
        };
      };
    };
    expect(options.formOptions).toBeUndefined();
    expect(options.gridOptions.toolbarConfig.tools[0]).toMatchObject({
      code: 'mutation-log-filters',
      icon: 'vxe-icon-search',
    });

    expect(options.gridOptions.toolbarConfig.tools[0]?.status).toBeUndefined();
    options.gridEvents.toolbarToolClick({ code: 'mutation-log-filters' });
    expect(page.filtersOpen.value).toBe(true);
    expect(options.gridOptions.toolbarConfig.tools[0]?.status).toBe('primary');
    options.gridEvents.toolbarToolClick({ code: 'mutation-log-filters' });
    expect(page.filtersOpen.value).toBe(false);
    expect(options.gridOptions.toolbarConfig.tools[0]?.status).toBeUndefined();
  });

  it('loads detail by row UUID and copies server Markdown', async () => {
    api.detail.mockResolvedValue(log);
    api.markdown.mockResolvedValue('# HTTP mutation log ABC1234');
    clipboard.writeText.mockResolvedValue(undefined);
    const page = useHttpMutationLogsPage();

    await page.openDetail(log);
    expect(api.detail).toHaveBeenCalledWith(id);
    expect(page.detail.value).toEqual(log);
    expect(page.detailOpen.value).toBe(true);
    expect(page.detail.value?.response).toBe('[json-response]');

    await page.copyMarkdown();
    expect(api.markdown).toHaveBeenCalledWith(id);
    expect(clipboard.writeText).toHaveBeenCalledWith(
      '# HTTP mutation log ABC1234',
    );
  });

  it('does not open detail without view permission and surfaces API errors', async () => {
    const page = useHttpMutationLogsPage();
    access.allowed = false;
    await page.openDetail(log);
    expect(api.detail).not.toHaveBeenCalled();

    access.allowed = true;
    api.detail.mockRejectedValue(new Error('403 Forbidden'));
    await page.openDetail(log);
    expect(page.detailOpen.value).toBe(false);
    expect(feedback.show).toHaveBeenCalledOnce();
  });
});
