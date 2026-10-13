/* eslint-disable vue/one-component-per-file */

import type { App } from 'vue';

import { createApp, defineComponent, h, nextTick } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

type ModalData = {
  equipment: {
    code: string;
    created_at: string;
    id: string;
    name: string;
    updated_at: string;
  };
  mode: 'edit' | 'view';
  onSaved: () => Promise<void>;
};

const modalState = vi.hoisted(() => ({
  data: null as ModalData | null,
  hooks: null as null | {
    onOpenChange: (open: boolean) => Promise<void>;
  },
  setState: vi.fn(),
}));

const formState = vi.hoisted(() => ({
  resetForm: vi.fn(),
  setValues: vi.fn(),
}));

const formMocks = vi.hoisted(() => ({
  toEquipmentFormValues: vi.fn(),
}));

const dateMocks = vi.hoisted(() => ({
  formatDateTime: vi.fn((value: string) => `Formatted ${value}`),
}));

const translations: Record<string, string> = {
  'common.reset': 'Reset',
  'page.equipment.actions.cancel': 'Cancel',
  'page.equipment.actions.create': 'Create equipment',
  'page.equipment.actions.save': 'Save',
  'page.equipment.create.title': 'Create equipment',
  'page.equipment.detail.title': 'Equipment details',
  'page.equipment.edit.title': 'Edit equipment',
  'page.equipment.fields.code': 'Equipment code',
  'page.equipment.fields.createdAt': 'Created at',
  'page.equipment.fields.name': 'Equipment name',
  'page.equipment.fields.updatedAt': 'Updated at',
  'page.equipment.sections.equipment': 'Equipment information',
};

vi.mock('@vben/common-ui', () => ({
  useVbenModal: (options: {
    onOpenChange: (open: boolean) => Promise<void>;
  }) => {
    modalState.hooks = {
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
        getData: () => {
          if (modalState.data === null) {
            throw new Error('Modal data not configured');
          }

          return modalState.data;
        },
        setState: modalState.setState,
      },
    ] as const;
  },
}));

vi.mock('#/adapter/form', () => ({
  useVbenForm: () => [
    defineComponent({
      name: 'FormStub',
      setup() {
        return () => h('div', { 'data-testid': 'form-stub' });
      },
    }),
    {
      resetForm: formState.resetForm,
      setValues: formState.setValues,
    },
  ],
}));

vi.mock('#/api', () => ({
  equipmentsResource: {
    create: vi.fn(),
    update: vi.fn(),
  },
}));

vi.mock('ant-design-vue', () => ({
  App: {
    useApp: () => ({ notification: { success: vi.fn() } }),
  },
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
  Divider: defineComponent({
    name: 'DividerStub',
    setup(_, { slots }) {
      return () =>
        h('div', { 'data-testid': 'divider-stub' }, slots.default?.());
    },
  }),
}));

vi.mock('@vben/icons', () => ({
  IconifyIcon: defineComponent({
    name: 'IconifyIconStub',
    props: {
      icon: {
        required: true,
        type: String,
      },
    },
    setup(props) {
      return () => h('span', { 'data-icon': props.icon });
    },
  }),
}));

vi.mock('@vben/utils', () => ({
  formatDateTime: dateMocks.formatDateTime,
}));

vi.mock('#/locales', () => ({
  $t: (key: string) => translations[key] ?? key,
}));

vi.mock('#/shared/request-feedback', () => ({
  showRequestError: vi.fn(),
}));

vi.mock('./form', () => ({
  buildEquipmentCreatePayload: vi.fn(),
  buildEquipmentUpdatePayload: vi.fn(),
  toEquipmentFormValues: formMocks.toEquipmentFormValues,
  useEquipmentFormSchema: () => ({
    createFormSchema: { value: [] },
    editFormSchema: { value: [] },
  }),
}));

function createEquipment() {
  return {
    code: 'EQ-001',
    created_at: '2026-07-29T08:30:00.000Z',
    id: 'equipment-1',
    name: 'Laptop',
    updated_at: '2026-07-29T09:45:00.000Z',
  };
}

async function settle(): Promise<void> {
  await Promise.resolve();
  await nextTick();
}

async function mountModal(
  componentPath:
    | './create-equipment-modal.vue'
    | './equipment-detail-modal.vue',
  data?: ModalData,
) {
  const { default: Modal } =
    componentPath === './create-equipment-modal.vue'
      ? await import('./create-equipment-modal.vue')
      : await import('./equipment-detail-modal.vue');

  modalState.data = data ?? null;

  const target = document.createElement('div');
  document.body.append(target);

  const app = createApp(Modal);
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
  modalState.setState.mockReset();
  formState.resetForm.mockReset();
  formState.setValues.mockReset();
  dateMocks.formatDateTime.mockClear();
  formMocks.toEquipmentFormValues.mockReset();
  formMocks.toEquipmentFormValues.mockReturnValue({
    code: 'EQ-001',
    name: 'Laptop',
  });
  mountedApps = [];
  mountedTargets = [];
});

afterEach(() => {
  for (const app of mountedApps) {
    app.unmount();
  }

  for (const target of mountedTargets) {
    target.remove();
  }
});

describe('equipment modals', () => {
  it('localizes the create modal when it opens', async () => {
    const mounted = await mountModal('./create-equipment-modal.vue');
    mountedApps.push(mounted.app);
    mountedTargets.push(mounted.target);

    expect(modalState.setState).toHaveBeenCalledWith({
      cancelText: 'Cancel',
      confirmText: 'Create equipment',
      title: 'Create equipment',
    });
    expect(formState.resetForm).toHaveBeenCalledTimes(1);
  });

  it('renders translated equipment information in view mode', async () => {
    const mounted = await mountModal('./equipment-detail-modal.vue', {
      equipment: createEquipment(),
      mode: 'view',
      onSaved: vi.fn().mockResolvedValue(undefined),
    });
    mountedApps.push(mounted.app);
    mountedTargets.push(mounted.target);

    expect(modalState.setState).toHaveBeenCalledWith({
      cancelText: 'Cancel',
      confirmText: 'Save',
      showCancelButton: false,
      showConfirmButton: false,
      title: 'Equipment details',
    });
    expect(mounted.target.textContent).toContain('Equipment information');
    expect(mounted.target.textContent).toContain('Equipment code');
    expect(mounted.target.textContent).toContain('EQ-001');
    expect(mounted.target.textContent).toContain('Equipment name');
    expect(mounted.target.textContent).toContain('Laptop');
    expect(mounted.target.textContent).toContain('Created at');
    expect(mounted.target.textContent).toContain(
      'Formatted 2026-07-29T08:30:00.000Z',
    );
    expect(mounted.target.textContent).toContain('Updated at');
    expect(mounted.target.textContent).toContain(
      'Formatted 2026-07-29T09:45:00.000Z',
    );
    expect(dateMocks.formatDateTime).toHaveBeenCalledWith(
      '2026-07-29T08:30:00.000Z',
    );
    expect(dateMocks.formatDateTime).toHaveBeenCalledWith(
      '2026-07-29T09:45:00.000Z',
    );
    expect(
      mounted.target.querySelector('[data-testid="divider-stub"]'),
    ).not.toBeNull();
    expect(
      mounted.target.querySelector('[data-icon="lucide:package"]'),
    ).not.toBeNull();
    expect(
      mounted.target.querySelector('[data-testid="form-stub"]'),
    ).toBeNull();
  });

  it('localizes the edit modal and initializes its form values', async () => {
    const mounted = await mountModal('./equipment-detail-modal.vue', {
      equipment: createEquipment(),
      mode: 'edit',
      onSaved: vi.fn().mockResolvedValue(undefined),
    });
    mountedApps.push(mounted.app);
    mountedTargets.push(mounted.target);

    expect(modalState.setState).toHaveBeenCalledWith({
      cancelText: 'Cancel',
      confirmText: 'Save',
      showCancelButton: true,
      showConfirmButton: true,
      title: 'Edit equipment',
    });
    expect(formState.setValues).toHaveBeenCalledWith({
      code: 'EQ-001',
      name: 'Laptop',
    });
    expect(
      mounted.target.querySelector('[data-testid="form-stub"]'),
    ).not.toBeNull();
  });
});
