/* eslint-disable vue/one-component-per-file */

import type { App } from 'vue';

import { createApp, defineComponent, h, nextTick } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import UserDetailModal from './user-detail-modal.vue';

const modalState = vi.hoisted(() => ({
  data: null as null | {
    mode: 'edit' | 'view';
    onSaved: () => Promise<void>;
    user: {
      id: string;
      username: string;
    };
  },
  hooks: null as null | {
    onClosed: () => Promise<void>;
    onConfirm: () => Promise<void>;
    onOpenChange: (open: boolean) => Promise<void>;
  },
  options: null as null | {
    class?: string;
    contentClass?: string;
    onClosed: () => Promise<void>;
  },
}));

const formState = vi.hoisted(() => ({
  apis: [] as Array<{
    getValues: ReturnType<typeof vi.fn>;
    resetForm: ReturnType<typeof vi.fn>;
    setValues: ReturnType<typeof vi.fn>;
    validate: ReturnType<typeof vi.fn>;
  }>,
  wrapperClasses: [] as string[],
}));

const apiMocks = vi.hoisted(() => ({
  getUserInfoApi: vi.fn(),
  resetPassword: vi.fn(),
  update: vi.fn(),
}));

const notificationMocks = vi.hoisted(() => ({
  success: vi.fn(),
}));

const authMocks = vi.hoisted(() => ({
  setAuthenticatedUser: vi.fn(),
  user: {
    id: 'someone-else',
  },
}));

const formMocks = vi.hoisted(() => ({
  buildUserDetail: vi.fn(),
  buildUserPasswordResetPayload: vi.fn(),
  buildUserUpdatePayload: vi.fn(),
  canEditRoles: {
    value: true,
  },
  editAdditionalFormSchema: {
    value: [{ fieldName: 'profile.starting_date' }],
  },
  editBasicFormSchema: {
    value: [{ fieldName: 'profile.position_id' }],
  },
  loadOptions: vi.fn(),
  mergeUserFormValues: vi.fn(),
  toUserFormValues: vi.fn(),
}));

vi.mock('@vben/common-ui', () => ({
  useVbenModal: (options: {
    class?: string;
    contentClass?: string;
    onClosed: () => Promise<void>;
    onConfirm: () => Promise<void>;
    onOpenChange: (open: boolean) => Promise<void>;
  }) => {
    modalState.options = options;
    modalState.hooks = {
      onClosed: options.onClosed,
      onConfirm: options.onConfirm,
      onOpenChange: options.onOpenChange,
    };

    return [
      defineComponent({
        name: 'ModalStub',
        setup(_, { slots }) {
          return () =>
            h('div', { 'data-testid': 'modal-stub' }, [
              slots.default?.(),
              slots['prepend-footer']?.(),
            ]);
        },
      }),
      {
        close: vi.fn(),
        getData: () => {
          if (modalState.data === null) {
            throw new Error('Modal data not configured');
          }

          return modalState.data;
        },
        lock: vi.fn(),
        setState: vi.fn(),
        unlock: vi.fn(),
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
      setValues: vi.fn().mockResolvedValue(undefined),
      validate: vi.fn().mockResolvedValue({ valid: true }),
    };
    formState.apis.push(api);
    formState.wrapperClasses.push(config.wrapperClass);

    return [
      defineComponent({
        name: `FormStub${index}`,
        setup() {
          return () => h('div', { 'data-testid': `form-stub-${index}` });
        },
      }),
      api,
    ] as const;
  },
}));

vi.mock('#/api', () => ({
  ApiProblemError: class ApiProblemError extends Error {},
  getUserInfoApi: apiMocks.getUserInfoApi,
  usersResource: {
    resetPassword: apiMocks.resetPassword,
    update: apiMocks.update,
  },
}));

vi.mock('ant-design-vue', () => {
  const DescriptionItem = defineComponent({
    name: 'DescriptionsItemStub',
    setup(_, { slots }) {
      return () => h('div', slots.default?.());
    },
  });
  const Descriptions = defineComponent({
    name: 'DescriptionsStub',
    setup(_, { slots }) {
      return () => h('div', slots.default?.());
    },
  });
  const TabPane = defineComponent({
    name: 'TabPaneStub',
    setup(_, { slots }) {
      return () => h('div', slots.default?.());
    },
  });
  const Tabs = Object.assign(
    defineComponent({
      name: 'TabsStub',
      setup(_, { slots }) {
        return () => h('div', slots.default?.());
      },
    }),
    { TabPane },
  );

  return {
    Button: defineComponent({
      name: 'ButtonStub',
      emits: ['click'],
      setup(_, { emit, slots }) {
        return () =>
          h(
            'button',
            {
              onClick: () => emit('click'),
              type: 'button',
            },
            slots.default?.(),
          );
      },
    }),
    Descriptions,
    DescriptionsItem: DescriptionItem,
    notification: notificationMocks,
    Spin: defineComponent({
      name: 'SpinStub',
      setup() {
        return () => h('div', 'Loading');
      },
    }),
    Tabs,
  };
});

vi.mock('#/store', () => ({
  useAuthStore: () => authMocks,
}));

vi.mock('./form', () => ({
  buildUserDetail: formMocks.buildUserDetail,
  buildUserPasswordResetPayload: formMocks.buildUserPasswordResetPayload,
  buildUserUpdatePayload: formMocks.buildUserUpdatePayload,
  mergeUserFormValues: formMocks.mergeUserFormValues,
  toUserFormValues: formMocks.toUserFormValues,
  useUserFormSchema: () => ({
    canEditRoles: formMocks.canEditRoles,
    editAdditionalFormSchema: formMocks.editAdditionalFormSchema,
    editBasicFormSchema: formMocks.editBasicFormSchema,
    loadOptions: formMocks.loadOptions,
  }),
}));

function createUser() {
  return {
    id: 'user-1',
    username: 'admin',
  };
}

async function settle() {
  await Promise.resolve();
  await nextTick();
  await Promise.resolve();
  await nextTick();
}

async function openModal(mode: 'edit' | 'view', onSaved: () => Promise<void>) {
  modalState.data = {
    mode,
    onSaved,
    user: createUser(),
  };

  const target = document.createElement('div');
  document.body.append(target);
  const app = createApp(UserDetailModal);
  app.mount(target);

  if (modalState.hooks === null) {
    throw new Error('Modal hooks not captured');
  }

  await modalState.hooks.onOpenChange(true);
  await settle();

  return { app, target };
}

let mountedApps: App[] = [];
let mountedTargets: HTMLElement[] = [];

beforeEach(() => {
  modalState.data = null;
  modalState.hooks = null;
  modalState.options = null;
  formState.apis = [];
  formState.wrapperClasses = [];
  mountedApps = [];
  mountedTargets = [];
  apiMocks.getUserInfoApi.mockReset();
  apiMocks.resetPassword.mockReset();
  apiMocks.update.mockReset();
  notificationMocks.success.mockReset();
  authMocks.setAuthenticatedUser.mockReset();
  formMocks.buildUserDetail.mockReset();
  formMocks.buildUserPasswordResetPayload.mockReset();
  formMocks.buildUserUpdatePayload.mockReset();
  formMocks.loadOptions.mockReset();
  formMocks.mergeUserFormValues.mockReset();
  formMocks.toUserFormValues.mockReset();

  formMocks.buildUserDetail.mockReturnValue({
    name: 'Admin User',
    sections: [
      {
        key: 'basic',
        rows: [
          {
            key: 'company',
            label: 'Company',
            value: 'Obee',
          },
        ],
        title: 'Basic information',
      },
      {
        key: 'additional',
        rows: [
          {
            key: 'email',
            label: 'Email',
            value: 'admin@example.com',
          },
        ],
        title: 'Additional information',
      },
    ],
  });
  formMocks.buildUserPasswordResetPayload.mockReturnValue(null);
  formMocks.buildUserUpdatePayload.mockReturnValue({ name: 'Admin User' });
  formMocks.loadOptions.mockResolvedValue(undefined);
  formMocks.mergeUserFormValues.mockReturnValue({ name: 'Admin User' });
  formMocks.toUserFormValues.mockReturnValue({
    department_id: null,
    is_active: false,
    name: 'Admin User',
  });
  apiMocks.update.mockResolvedValue({ id: 'updated-user' });
});

afterEach(() => {
  for (const app of mountedApps) {
    app.unmount();
  }
  for (const target of mountedTargets) {
    target.remove();
  }
});

describe('user detail modal', () => {
  it('renders basic and additional sections in view mode', async () => {
    const mounted = await openModal(
      'view',
      vi.fn().mockResolvedValue(undefined),
    );
    mountedApps.push(mounted.app);
    mountedTargets.push(mounted.target);

    expect(mounted.target.textContent).toContain('Company');
    expect(mounted.target.textContent).toContain('Obee');
    expect(mounted.target.textContent).toContain('admin@example.com');
    expect(
      mounted.target.querySelectorAll('[data-testid^="form-stub-"]').length,
    ).toBe(0);
  });

  it('renders two edit forms and saves a merged payload', async () => {
    const onSaved = vi.fn().mockResolvedValue(undefined);
    const mounted = await openModal('edit', onSaved);
    mountedApps.push(mounted.app);
    mountedTargets.push(mounted.target);

    expect(modalState.options).toMatchObject({
      class: 'w-[1120px] !top-2 !max-h-[calc(100dvh-20px)]',
    });

    expect(
      mounted.target.querySelectorAll('[data-testid^="form-stub-"]').length,
    ).toBe(2);
    expect(formState.wrapperClasses).toEqual([
      'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
      'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-3',
    ]);
    expect(formState.apis[0]?.setValues).toHaveBeenCalledWith({
      department_id: null,
      is_active: false,
      name: 'Admin User',
    });
    expect(formState.apis[1]?.setValues).toHaveBeenCalledWith({
      department_id: null,
      is_active: false,
      name: 'Admin User',
    });

    mounted.target
      .querySelector('button')
      ?.dispatchEvent(new MouseEvent('click'));
    await settle();
    expect(formState.apis[0]?.resetForm).toHaveBeenCalledOnce();
    expect(formState.apis[1]?.resetForm).toHaveBeenCalledOnce();

    if (modalState.hooks === null) {
      throw new Error('Modal hooks not captured');
    }

    await modalState.hooks.onConfirm();
    await settle();

    expect(apiMocks.update).toHaveBeenCalledWith('user-1', {
      name: 'Admin User',
    });
    expect(apiMocks.resetPassword).not.toHaveBeenCalled();
    expect(notificationMocks.success).toHaveBeenCalledOnce();
    expect(onSaved).not.toHaveBeenCalled();

    await modalState.hooks.onClosed();

    expect(onSaved).toHaveBeenCalledOnce();
  });
});
