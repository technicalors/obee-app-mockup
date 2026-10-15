import { createApp, defineComponent, h, nextTick } from 'vue';

import { notification } from 'ant-design-vue';
import { afterEach, describe, expect, it, vi } from 'vitest';

import viMessages from '#/locales/langs/vi-VN/attendanceLocations.json';

import DetailForm from './detail-form.vue';

const api = vi.hoisted(() => ({
  create: vi.fn(),
  update: vi.fn(),
  showRequestError: vi.fn(),
  push: vi.fn(),
}));

vi.mock('#/api', () => ({
  attendanceLocationsResource: { create: api.create, update: api.update },
  filterOrganizationsByRoot: vi.fn(),
  organizationsResource: { getAllRows: vi.fn() },
  userTreeResource: { getAll: vi.fn() },
}));
vi.mock('#/store', () => ({ useAuthStore: () => ({ user: null }) }));
vi.mock('@vben/access', () => ({
  useAccess: () => ({ hasAccessByCodes: () => true }),
}));
vi.mock('vue-router', async (importOriginal) => ({
  ...(await importOriginal<typeof import('vue-router')>()),
  useRouter: () => ({ push: api.push }),
}));
vi.mock('@vben/common-ui', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@vben/common-ui')>()),
  Page: defineComponent({
    setup(_props, { slots }) {
      return () => h('div', [slots.extra?.(), slots.default?.()]);
    },
  }),
}));
vi.mock('@vben/icons', () => ({ IconifyIcon: { render: () => null } }));
vi.mock('./MapboxMapPicker.vue', () => ({ default: { render: () => null } }));
vi.mock('#/shared/user-tree-select/user-tree-select.vue', () => ({
  default: { render: () => null },
}));
vi.mock('#/shared/request-feedback', () => ({
  showRequestError: api.showRequestError,
}));
vi.mock('#/locales', () => ({
  $t: (key: string, params?: Record<string, number | string>) =>
    key === 'attendanceLocations.validation.radiusRange'
      ? viMessages.validation.radiusRange.replace('{max}', String(params?.max))
      : key,
}));

afterEach(() => {
  vi.restoreAllMocks();
  vi.clearAllMocks();
});

describe('attendance location form validation', () => {
  it('shows the radius limit beside the field and prevents saving invalid input', async () => {
    const errors = vi
      .spyOn(notification, 'error')
      .mockImplementation(() => undefined);
    vi.spyOn(notification, 'success').mockImplementation(() => undefined);
    const element = document.createElement('div');
    document.body.append(element);
    const app = createApp(DetailForm, { mode: 'create' });
    app.mount(element);
    try {
      await nextTick();
      await vi.waitFor(() =>
        expect(element.querySelector('.ant-spin')).toBeNull(),
      );
      await vi.waitFor(() =>
        expect(
          element.querySelector(
            'input[placeholder="attendanceLocations.placeholders.radius"]',
          ),
        ).not.toBeNull(),
      );
      const radius = element.querySelector<HTMLInputElement>(
        'input[placeholder="attendanceLocations.placeholders.radius"]',
      );
      expect(radius).not.toBeNull();
      if (radius === null) throw new Error('Radius input is missing.');
      const name = element.querySelector<HTMLInputElement>(
        'input[placeholder="attendanceLocations.placeholders.name"]',
      );
      if (name === null) throw new Error('Location name input is missing.');
      name.value = 'Worldwide';
      name.dispatchEvent(new Event('input', { bubbles: true }));
      radius.value = '2000000001';
      radius.dispatchEvent(new Event('input', { bubbles: true }));
      await nextTick();
      const save = element.querySelector<HTMLButtonElement>('button[form]');
      expect(save).not.toBeNull();
      save?.click();
      await vi.waitFor(() => {
        expect(element.textContent).toContain(
          'Bán kính phải là số nguyên từ 1 đến 2000000000 mét.',
        );
      });
      expect(api.create).not.toHaveBeenCalled();
      expect(api.update).not.toHaveBeenCalled();
      expect(api.showRequestError).not.toHaveBeenCalled();
      expect(errors).not.toHaveBeenCalled();

      radius.value = '2000000000';
      radius.dispatchEvent(new Event('input', { bubbles: true }));
      await nextTick();
      save?.click();
      await vi.waitFor(() => {
        expect(element.textContent).not.toContain(
          'attendanceLocations.validation.nameRequired',
        );
        expect(api.create).toHaveBeenCalledWith(
          expect.objectContaining({
            name: 'Worldwide',
            radius_meters: 2_000_000_000,
          }),
        );
      });
      await vi.waitFor(() =>
        expect(api.push).toHaveBeenCalledWith(
          '/master-data/attendance-locations',
        ),
      );
      await vi.waitFor(() =>
        expect(element.textContent).not.toContain(
          'Bán kính phải là số nguyên từ 1 đến 2000000000 mét.',
        ),
      );
      expect(api.showRequestError).not.toHaveBeenCalled();
    } finally {
      app.unmount();
      element.remove();
    }
  });
});
