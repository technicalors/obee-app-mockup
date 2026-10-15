/* eslint-disable vue/one-component-per-file */

import type { App } from 'vue';

import { createApp, defineComponent, h, nextTick } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import UserModal from './user-modal.vue';

const modalState = vi.hoisted(() => ({
  data: {} as Record<string, unknown>,
  hooks: null as null | {
    onClosed: () => Promise<void>;
    onConfirm: () => Promise<void>;
    onOpenChange: (open: boolean) => void;
  },
  options: {} as Record<string, unknown>,
  state: {} as Record<string, unknown>,
  close: vi.fn(),
  lock: vi.fn(),
  unlock: vi.fn(),
}));

const formState = vi.hoisted(() => ({
  apis: [] as Array<{
    getValues: ReturnType<typeof vi.fn>;
    resetForm: ReturnType<typeof vi.fn>;
    setFieldValue: ReturnType<typeof vi.fn>;
    validate: ReturnType<typeof vi.fn>;
  }>,
  wrapperClasses: [] as string[],
}));

const apiMocks = vi.hoisted(() => ({
  create: vi.fn(),
  getById: vi.fn(),
  resetPassword: vi.fn(),
  update: vi.fn(),
}));

const formMocks = vi.hoisted(() => ({
  buildUserCreatePayload: vi.fn(),
  buildUserDetail: vi.fn(),
  buildUserPasswordResetPayload: vi.fn(),
  buildUserUpdatePayload: vi.fn(),
  canEditRoles: { value: true },
  createAdditionalFormSchema: { value: [{ fieldName: 'email' }] },
  createBasicFormSchema: { value: [{ fieldName: 'name' }] },
  editAdditionalFormSchema: {
    value: [
      { fieldName: 'email' },
      { fieldName: 'profile.address' },
      { fieldName: 'profile.birthday' },
    ],
  },
  editBasicFormSchema: {
    value: [
      { fieldName: 'name' },
      { fieldName: 'profile.code' },
      { fieldName: 'new_password' },
      { fieldName: 'role_names' },
    ],
  },
  loadOptions: vi.fn(),
  mergeUserFormValues: vi.fn(),
  parse: vi.fn(),
  wait: vi.fn(),
}));

const feedbackMocks = vi.hoisted(() => ({ showRequestError: vi.fn() }));
const notificationMocks = vi.hoisted(() => ({ success: vi.fn() }));
const authMocks = vi.hoisted(() => ({
  fetchUserInfo: vi.fn(),
  user: { id: 'another-user' },
}));

vi.mock('@vben/common-ui', () => ({
  useVbenModal: (options: Record<string, unknown>) => {
    modalState.options = options;
    modalState.hooks = options as typeof modalState.hooks;
    return [
      defineComponent({
        name: 'ModalStub',
        setup(_, { slots }) {
          return () =>
            h('div', { 'data-testid': 'modal' }, [
              slots.default?.(),
              slots['prepend-footer']?.(),
            ]);
        },
      }),
      {
        close: modalState.close,
        getData: () => modalState.data,
        lock: modalState.lock,
        setState: (next: Record<string, unknown>) => {
          modalState.state = { ...modalState.state, ...next };
        },
        unlock: modalState.unlock,
      },
    ] as const;
  },
}));

vi.mock('#/adapter/form', () => ({
  useVbenForm: (config: { wrapperClass: string }) => {
    const index = formState.apis.length + 1;
    const api = {
      getValues: vi.fn().mockResolvedValue({}),
      resetForm: vi.fn().mockResolvedValue(undefined),
      setFieldValue: vi.fn().mockResolvedValue(undefined),
      validate: vi.fn().mockResolvedValue({ valid: true }),
    };
    formState.apis.push(api);
    formState.wrapperClasses.push(config.wrapperClass);
    return [
      defineComponent({
        name: `FormStub${index}`,
        setup() {
          return () => h('div', { 'data-testid': `form-${index}` });
        },
      }),
      api,
    ] as const;
  },
}));

vi.mock('#/api', () => ({
  ValidationProblemError: class ValidationProblemError extends Error {},
  usersResource: {
    create: apiMocks.create,
    getById: apiMocks.getById,
    resetPassword: apiMocks.resetPassword,
    update: apiMocks.update,
  },
}));

vi.mock('#/shared/request-feedback', () => feedbackMocks);
vi.mock('#/store', () => ({ useAuthStore: () => authMocks }));
vi.mock('ant-design-vue', () => {
  const TabPane = defineComponent({
    name: 'TabPaneStub',
    setup(_, { slots }) {
      return () => h('div', slots.default?.());
    },
  });
  return {
    Button: defineComponent({
      name: 'ButtonStub',
      emits: ['click'],
      setup(_, { emit, slots }) {
        return () =>
          h('button', { onClick: () => emit('click') }, slots.default?.());
      },
    }),
    notification: notificationMocks,
    Tabs: Object.assign(
      defineComponent({
        name: 'TabsStub',
        props: { activeKey: { default: 'basic', type: String } },
        setup(props, { slots }) {
          return () =>
            h('div', { 'data-active-key': props.activeKey }, slots.default?.());
        },
      }),
      { TabPane },
    ),
  };
});

vi.mock('./form', () => ({
  buildUserCreatePayload: formMocks.buildUserCreatePayload,
  buildUserDetail: formMocks.buildUserDetail,
  buildUserPasswordResetPayload: formMocks.buildUserPasswordResetPayload,
  buildUserUpdatePayload: formMocks.buildUserUpdatePayload,
  mergeUserFormValues: formMocks.mergeUserFormValues,
  userEditFormValuesSchema: { parse: formMocks.parse },
  useUserFormSchema: () => ({
    canEditRoles: formMocks.canEditRoles,
    createAdditionalFormSchema: formMocks.createAdditionalFormSchema,
    createBasicFormSchema: formMocks.createBasicFormSchema,
    editAdditionalFormSchema: formMocks.editAdditionalFormSchema,
    editBasicFormSchema: formMocks.editBasicFormSchema,
    loadOptions: formMocks.loadOptions,
  }),
  waitForMinimumUserModalLoading: formMocks.wait,
}));

const apps: App[] = [];
const targets: HTMLElement[] = [];

function mountModal() {
  const target = document.createElement('div');
  document.body.append(target);
  const app = createApp(UserModal);
  apps.push(app);
  targets.push(target);
  app.mount(target);
  if (modalState.hooks === null) throw new Error('Modal hooks missing');
  return target;
}

async function settle() {
  for (let index = 0; index < 8; index += 1) {
    await Promise.resolve();
    await nextTick();
  }
}

async function open(mode: 'create' | 'edit' | 'view', userId = 'user-1') {
  modalState.data = { mode, onSaved: vi.fn(), userId };
  modalState.hooks?.onOpenChange(true);
  await settle();
}

beforeEach(() => {
  modalState.data = {};
  modalState.hooks = null;
  modalState.options = {};
  modalState.state = {};
  modalState.close.mockReset();
  modalState.lock.mockReset();
  modalState.unlock.mockReset();
  formState.apis = [];
  formState.wrapperClasses = [];
  for (const mock of Object.values(apiMocks)) mock.mockReset();
  for (const value of Object.values(formMocks)) {
    if (vi.isMockFunction(value)) value.mockReset();
  }
  feedbackMocks.showRequestError.mockReset();
  notificationMocks.success.mockReset();
  authMocks.fetchUserInfo.mockReset();
  authMocks.user.id = 'another-user';
  formMocks.loadOptions.mockResolvedValue(undefined);
  formMocks.wait.mockResolvedValue(undefined);
  apiMocks.getById.mockImplementation(async (id: string) => ({
    id,
    name: `Fresh ${id}`,
  }));
  apiMocks.create.mockResolvedValue({ id: 'created-user' });
  apiMocks.update.mockResolvedValue({ id: 'user-1' });
  formMocks.buildUserDetail.mockImplementation((user: { name: string }) => ({
    sections: [
      {
        key: 'basic',
        rows: [
          { key: 'name', label: 'Name', value: user.name },
          { key: 'code', label: 'Employee code', value: null },
        ],
      },
      {
        key: 'additional',
        rows: [{ key: 'email', label: 'Email', value: 'mail@example.com' }],
      },
    ],
  }));
  formMocks.parse.mockReturnValue({
    basic: {
      name: 'Fresh user',
      new_password: '',
      profile: { code: 'EMP-001' },
      role_names: ['admin', 'editor'],
    },
    additional: {
      email: 'mail@example.com',
      profile: { address: 'Address', birthday: '2020-01-01' },
    },
  });
  formMocks.buildUserPasswordResetPayload.mockReturnValue(null);
  formMocks.buildUserCreatePayload.mockReturnValue({ name: 'Created user' });
  formMocks.buildUserUpdatePayload.mockReturnValue({ name: 'Updated user' });
  formMocks.mergeUserFormValues.mockReturnValue({ name: 'Merged user' });
});

afterEach(() => {
  for (const app of apps.splice(0)) app.unmount();
  for (const target of targets.splice(0)) target.remove();
});

describe('user modal', () => {
  it('loads options, keeps both create forms mounted, and creates a user', async () => {
    const target = mountModal();
    await open('create');

    expect(formMocks.loadOptions).toHaveBeenCalledOnce();
    expect(apiMocks.getById).not.toHaveBeenCalled();
    expect(target.querySelectorAll('[data-testid^="form-"]')).toHaveLength(2);
    expect(formState.wrapperClasses).toEqual([
      'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
      'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
    ]);
    expect(formState.apis[0]?.resetForm).toHaveBeenCalledOnce();
    expect(modalState.state).toMatchObject({
      loading: false,
      confirmDisabled: false,
    });

    await modalState.hooks?.onConfirm();
    expect(apiMocks.create).toHaveBeenCalledWith({ name: 'Created user' });
    expect(notificationMocks.success).toHaveBeenCalledOnce();
    expect(modalState.close).toHaveBeenCalledOnce();
    const onSaved = modalState.data.onSaved as ReturnType<typeof vi.fn>;
    expect(onSaved).not.toHaveBeenCalled();
    await modalState.hooks?.onClosed();
    expect(onSaved).toHaveBeenCalledOnce();
  });

  it('fetches fresh view data and shows the Close action', async () => {
    const target = mountModal();
    await open('view');

    expect(apiMocks.getById).toHaveBeenCalledWith('user-1');
    expect(formMocks.loadOptions).not.toHaveBeenCalled();
    expect(target.textContent).toContain('Fresh user-1');
    expect(target.textContent).toContain('—');
    expect(
      [...target.querySelectorAll('div.text-sm.text-muted-foreground')].some(
        (element) => element.textContent === '—',
      ),
    ).toBe(true);
    expect(target.querySelectorAll('[data-testid^="form-"]')).toHaveLength(0);
    expect(modalState.state).toMatchObject({
      cancelText: 'users.actions.close',
      showConfirmButton: false,
    });
  });

  it('starts edit detail and options together, then fills owned fields individually', async () => {
    let resolveUser!: (user: { id: string; name: string }) => void;
    apiMocks.getById.mockReturnValue(
      new Promise((resolve) => {
        resolveUser = resolve;
      }),
    );
    const target = mountModal();
    modalState.data = { mode: 'edit', onSaved: vi.fn(), userId: 'user-1' };
    modalState.hooks?.onOpenChange(true);
    await settle();

    expect(apiMocks.getById).toHaveBeenCalledWith('user-1');
    expect(formMocks.loadOptions).toHaveBeenCalledOnce();
    expect(target.querySelectorAll('[data-testid^="form-"]')).toHaveLength(2);
    expect(modalState.state).toMatchObject({
      loading: true,
      confirmDisabled: true,
    });

    resolveUser({ id: 'user-1', name: 'Fresh user' });
    await settle();

    expect(formMocks.parse).toHaveBeenCalledWith({
      id: 'user-1',
      name: 'Fresh user',
    });
    expect(formState.apis[0]?.setFieldValue).toHaveBeenCalledWith(
      'profile.code',
      'EMP-001',
      false,
    );
    expect(formState.apis[0]?.setFieldValue).toHaveBeenCalledWith(
      'new_password',
      '',
      false,
    );
    expect(formState.apis[0]?.setFieldValue).toHaveBeenCalledWith(
      'role_names',
      ['admin', 'editor'],
      false,
    );
    expect(formState.apis[1]?.setFieldValue).toHaveBeenCalledWith(
      'profile.address',
      'Address',
      false,
    );
    expect(formState.apis[1]?.setFieldValue).toHaveBeenCalledWith(
      'email',
      'mail@example.com',
      false,
    );
    expect(modalState.state.loading).toBe(false);

    target.querySelector('button')?.click();
    await settle();
    expect(formState.apis[0]?.resetForm).toHaveBeenCalledTimes(2);
    expect(formState.apis[0]?.setFieldValue).toHaveBeenCalledWith(
      'new_password',
      '',
      false,
    );

    await modalState.hooks?.onConfirm();
    expect(apiMocks.update).toHaveBeenCalledWith('user-1', {
      name: 'Updated user',
    });
    expect(authMocks.fetchUserInfo).not.toHaveBeenCalled();
    expect(modalState.close).toHaveBeenCalledOnce();
  });

  it('refreshes Auth after editing the authenticated user assignment', async () => {
    authMocks.user.id = 'user-1';
    const target = mountModal();
    await open('edit');
    target.querySelector('button')?.click();
    await settle();

    await modalState.hooks?.onConfirm();

    expect(authMocks.fetchUserInfo).toHaveBeenCalledOnce();
  });

  it('keeps loading until the minimum wait finishes and disables save and reset', async () => {
    let finishWait!: () => void;
    formMocks.wait.mockReturnValue(
      new Promise<void>((resolve) => {
        finishWait = resolve;
      }),
    );
    const target = mountModal();
    await open('create');

    expect(formMocks.wait).toHaveBeenCalledOnce();
    expect(modalState.state.loading).toBe(true);
    expect(target.querySelectorAll('[data-testid^="form-"]')).toHaveLength(2);
    expect(target.querySelector('button')?.disabled).toBe(true);
    await modalState.hooks?.onConfirm();
    expect(apiMocks.create).not.toHaveBeenCalled();

    finishWait();
    await settle();
    expect(modalState.state.loading).toBe(false);
  });

  it('shows an inline error and retries without exposing stale content', async () => {
    apiMocks.getById.mockRejectedValueOnce(new Error('Network'));
    const target = mountModal();
    await open('view');

    expect(target.textContent).toContain('users.messages.loadFailed');
    expect(target.textContent).not.toContain('Fresh user-1');
    expect(modalState.state.confirmDisabled).toBe(true);

    target.querySelector('button')?.click();
    await settle();
    expect(apiMocks.getById).toHaveBeenCalledTimes(2);
    expect(formMocks.wait).toHaveBeenCalledTimes(2);
    expect(target.textContent).toContain('Fresh user-1');
  });

  it('ignores a previous user response after closing and opening another user', async () => {
    let resolveOld!: (user: { id: string; name: string }) => void;
    apiMocks.getById.mockReturnValueOnce(
      new Promise((resolve) => {
        resolveOld = resolve;
      }),
    );
    const target = mountModal();
    await open('view', 'user-1');
    modalState.hooks?.onOpenChange(false);
    await open('view', 'user-2');
    resolveOld({ id: 'user-1', name: 'Old user' });
    await settle();

    expect(target.textContent).toContain('Fresh user-2');
    expect(target.textContent).not.toContain('Old user');
  });

  it('moves to the tab containing invalid fields', async () => {
    const target = mountModal();
    await open('create');
    formState.apis[1]?.validate.mockResolvedValueOnce({ valid: false });

    await modalState.hooks?.onConfirm();
    await settle();

    expect(
      target.querySelector<HTMLElement>('[data-active-key]')?.dataset.activeKey,
    ).toBe('additional');
    expect(apiMocks.create).not.toHaveBeenCalled();
  });
});
