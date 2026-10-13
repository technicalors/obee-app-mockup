import { describe, expect, it } from 'vitest';

import { getDatePickerDisplayFormat } from './date-picker';

describe('getDatePickerDisplayFormat', () => {
  it.each([
    ['en-US', 'MM/DD/YYYY'],
    ['vi-VN', 'DD/MM/YYYY'],
    ['zh-CN', 'YYYY-MM-DD'],
    ['unknown', 'YYYY-MM-DD'],
  ])('returns the date picker display format for %s', (locale, format) => {
    expect(getDatePickerDisplayFormat(locale)).toBe(format);
  });
});
