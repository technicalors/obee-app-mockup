import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { describe, expect, it } from 'vitest';

const attendanceViewSource = readFileSync(
  resolve(process.cwd(), 'apps/workspace/src/views/attendance/index.vue'),
  'utf8',
);

describe('attendance view responsive layout', () => {
  it('keeps a dedicated tablet-and-up layout separate from phone layout', () => {
    expect(attendanceViewSource).toContain('hidden md:block');
    expect(attendanceViewSource).toContain('<div class="md:hidden">');
  });

  it('uses a two-column tablet grid before expanding to the xl desktop layout', () => {
    expect(attendanceViewSource).toContain(
      'mb-6 grid grid-cols-2 gap-6 xl:grid-cols-3',
    );
    expect(attendanceViewSource).toContain('col-span-2 xl:col-span-1');
    expect(attendanceViewSource).toContain(
      'grid grid-cols-1 gap-6 xl:grid-cols-3',
    );
    expect(attendanceViewSource).toContain('xl:col-span-2');
  });
});
