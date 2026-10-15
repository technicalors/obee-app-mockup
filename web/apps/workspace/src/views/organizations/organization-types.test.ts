import { computed } from 'vue';

import { i18n } from '@vben/locales';

import { afterEach, expect, it, vi } from 'vitest';

import englishOrganizations from '#/locales/langs/en-US/organizations.json';
import vietnameseOrganizations from '#/locales/langs/vi-VN/organizations.json';

import {
  createOrganizationTypeOptions,
  getOrganizationTypeLabel,
} from './organization-types';

vi.mock('#/locales', async () => {
  const { i18n } = await import('@vben/locales');
  return { $t: i18n.global.t };
});

const previousLocale = i18n.global.locale.value;

afterEach(() => {
  i18n.global.locale.value = previousLocale;
});

it('updates type labels immediately with the locale while keeping stored values', () => {
  i18n.global.setLocaleMessage('vi-VN', {
    organizations: vietnameseOrganizations,
  });
  i18n.global.setLocaleMessage('en-US', {
    organizations: englishOrganizations,
  });
  i18n.global.locale.value = 'vi-VN';
  const options = computed(createOrganizationTypeOptions);
  const values = options.value.map(({ value }) => value);

  expect(options.value.map(({ label }) => label)).toEqual([
    'Công ty',
    'Phòng ban',
    'Bộ phận',
    'Nhóm',
    'Tổ',
  ]);
  expect(getOrganizationTypeLabel('Phòng ban')).toBe('Phòng ban');

  i18n.global.locale.value = 'en-US';

  expect(options.value.map(({ label }) => label)).toEqual([
    'Company',
    'Department',
    'Division',
    'Team',
    'Unit',
  ]);
  expect(options.value.map(({ value }) => value)).toEqual(values);
  expect(getOrganizationTypeLabel('Phòng ban')).toBe('Department');
  expect(getOrganizationTypeLabel('Custom workshop')).toBe('Custom workshop');
});
