/* eslint-disable vue/one-component-per-file */

import type { App } from 'vue';

import { createApp, defineComponent, h, nextTick } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

type ModalData = {
  facilityResourceId: string;
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
  config: null as null | { commonConfig?: { hideRequiredMark?: boolean } },
  resetForm: vi.fn(),
  setValues: vi.fn(),
}));

const formMocks = vi.hoisted(() => ({
  toFacilityResourceFormValues: vi.fn(),
}));

const dateMocks = vi.hoisted(() => ({
  formatDateTime: vi.fn((value: string) => `Formatted ${value}`),
}));

const apiMocks = vi.hoisted(() => ({
  getById: vi.fn(),
}));

const translations: Record<string, string> = {
  'common.reset': 'Reset',
  'common.notProvided': 'Not provided',
  'facilityResource.actions.cancel': 'Cancel',
  'facilityResource.actions.create': 'Add facility',
  'facilityResource.actions.save': 'Save',
  'facilityResource.create.title': 'Add facility',
  'facilityResource.detail.title': 'Facility details',
  'facilityResource.edit.title': 'Edit facility',
  'facilityResource.fields.code': 'Facility code',
  'facilityResource.fields.createdAt': 'Created at',
  'facilityResource.fields.name': 'Facility name',
  'facilityResource.fields.note': 'Note',
  'facilityResource.fields.quantity': 'Quantity',
  'facilityResource.fields.type': 'Type',
  'facilityResource.fields.updatedAt': 'Updated at',
  'facilityResource.types.equipment': 'Equipment',
  'facilityResource.types.room': 'Room',
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
  useVbenForm: (config: { commonConfig?: { hideRequiredMark?: boolean } }) => {
    formState.config = config;
    return [
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
    ] as const;
  },
}));

vi.mock('#/api', () => ({
  facilityResourcesResource: {
    create: vi.fn(),
    getById: apiMocks.getById,
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
  Spin: defineComponent({
    name: 'SpinStub',
    setup(_, { slots }) {
      return () => h('div', slots.default?.());
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
  buildFacilityResourceCreatePayload: vi.fn(),
  buildFacilityResourceUpdatePayload: vi.fn(),
  toFacilityResourceFormValues: formMocks.toFacilityResourceFormValues,
  useFacilityResourceFormSchema: () => ({
    createFormSchema: { value: [] },
    editFormSchema: { value: [] },
  }),
}));

function createFacilityResource() {
  return {
    code: 'EQ-001',
    created_at: '2026-07-29T08:30:00.000Z',
    id: 'facility-resource-1',
    name: 'Laptop',
    note: 'Loan devices',
    quantity: 3,
    type: 'equipment' as const,
    updated_at: '2026-07-29T09:45:00.000Z',
  };
}

async function settle(): Promise<void> {
  await Promise.resolve();
  await nextTick();
}

async function mountModal(
  componentPath:
    | './create-facility-resource-modal.vue'
    | './facility-resource-detail-modal.vue',
  data?: ModalData,
) {
  const { default: Modal } =
    componentPath === './create-facility-resource-modal.vue'
      ? await import('./create-facility-resource-modal.vue')
      : await import('./facility-resource-detail-modal.vue');

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
  formState.config = null;
  formState.resetForm.mockReset();
  formState.setValues.mockReset();
  dateMocks.formatDateTime.mockClear();
  apiMocks.getById.mockReset();
  apiMocks.getById.mockResolvedValue(createFacilityResource());
  formMocks.toFacilityResourceFormValues.mockReset();
  formMocks.toFacilityResourceFormValues.mockReturnValue({
    code: 'EQ-001',
    name: 'Laptop',
    note: 'Loan devices',
    quantity: 3,
    type: 'equipment',
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

describe('facility resource modals', () => {
  it('localizes the create modal when it opens', async () => {
    const mounted = await mountModal('./create-facility-resource-modal.vue');
    mountedApps.push(mounted.app);
    mountedTargets.push(mounted.target);

    expect(modalState.setState).toHaveBeenCalledWith({
      cancelText: 'Cancel',
      confirmText: 'Add facility',
      title: 'Add facility',
    });
    expect(formState.resetForm).toHaveBeenCalledTimes(1);
    expect(formState.config?.commonConfig?.hideRequiredMark).toBeUndefined();
  });

  it('renders translated facility resource information in view mode', async () => {
    const mounted = await mountModal('./facility-resource-detail-modal.vue', {
      facilityResourceId: 'facility-resource-1',
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
      title: 'Facility details',
    });
    expect(mounted.target.textContent).not.toContain('Facility information');
    expect(mounted.target.textContent).toContain('Facility code');
    expect(mounted.target.textContent).toContain('EQ-001');
    expect(mounted.target.textContent).toContain('Facility name');
    expect(mounted.target.textContent).toContain('Laptop');
    expect(mounted.target.textContent).toContain('Type');
    expect(mounted.target.textContent).toContain('Equipment');
    expect(mounted.target.textContent).toContain('Quantity');
    expect(mounted.target.textContent).toContain('3');
    expect(mounted.target.textContent).toContain('Note');
    expect(mounted.target.textContent).toContain('Loan devices');
    const note = mounted.target.querySelector('dd.whitespace-pre-wrap');
    expect(note?.classList.contains('break-words')).toBe(true);
    expect(note?.classList.contains('h-[94px]')).toBe(true);
    expect(note?.classList.contains('overflow-y-auto')).toBe(true);
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
    expect(apiMocks.getById).toHaveBeenCalledWith('facility-resource-1');
    expect(formState.config?.commonConfig?.hideRequiredMark).toBeUndefined();
    expect(mounted.target.textContent?.indexOf('Created at')).toBeLessThan(
      mounted.target.textContent?.indexOf('Note') ?? -1,
    );
    expect(
      mounted.target.querySelector('[data-testid="form-stub"]'),
    ).toBeNull();
  });

  it('localizes the edit modal and initializes its form values', async () => {
    const mounted = await mountModal('./facility-resource-detail-modal.vue', {
      facilityResourceId: 'facility-resource-1',
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
      title: 'Edit facility',
    });
    expect(formState.setValues).toHaveBeenCalledWith({
      code: 'EQ-001',
      name: 'Laptop',
      note: 'Loan devices',
      quantity: 3,
      type: 'equipment',
    });
    expect(apiMocks.getById).toHaveBeenCalledWith('facility-resource-1');
    expect(
      mounted.target.querySelector('[data-testid="form-stub"]'),
    ).not.toBeNull();
  });
});
