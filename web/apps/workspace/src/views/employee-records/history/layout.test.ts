import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { describe, expect, it } from 'vitest';

const historyDirectory = resolve(
  process.cwd(),
  'apps/workspace/src/views/employee-records/history',
);
const historyListSource = readFileSync(
  resolve(historyDirectory, 'index.vue'),
  'utf8',
);
const historyDetailSource = readFileSync(
  resolve(historyDirectory, 'detail.vue'),
  'utf8',
);
const recordCardSource = readFileSync(
  resolve(historyDirectory, 'employee-record-card.vue'),
  'utf8',
);
const summaryCardSource = readFileSync(
  resolve(historyDirectory, 'employee-summary-card.vue'),
  'utf8',
);

describe('employee history layout', () => {
  it('uses ResourceListPage, Grid, and UserDetailModal for the history list table', () => {
    expect(historyListSource).toContain('ResourceListPage');
    expect(historyListSource).toContain('Grid');
    expect(historyListSource).toContain('UserDetailModal');
    expect(historyListSource).toContain('page.employeeHistory.listTitle');
    expect(historyListSource).toContain('page.employeeHistory.listDescription');
  });

  it('renders without page header and keeps the empty state separate from the record layout in detail view', () => {
    expect(historyDetailSource).not.toContain(
      ':description="$t(\'page.employeeHistory.pageDescription\')"',
    );
    expect(historyDetailSource).not.toContain('<template #title>');
    expect(historyDetailSource).not.toContain('header-class=');
    expect(historyDetailSource).toContain('employee-history-layout');
    expect(historyDetailSource).toContain('employee-history-empty-card');
    expect(historyDetailSource).toContain('EmployeeSummaryCard');
  });

  it('keeps the selected employee summary as the desktop-side identity card', () => {
    expect(summaryCardSource).toContain('position: sticky');
    expect(summaryCardSource).toContain('employee-summary-name');
    expect(summaryCardSource).toContain('page.employeeHistory.status.active');
    expect(summaryCardSource).toContain('page.employeeHistory.fields.workUnit');
    expect(summaryCardSource).toContain('getUserAvatarSource(user)');
    expect(summaryCardSource).toContain('usersResource.updateAvatar');
    expect(summaryCardSource).toContain('data-testid="change-avatar-button"');
    expect(historyDetailSource).toContain(
      '@avatar-updated="selectedUser = $event"',
    );
  });

  it('uses tabs and does not render empty table headers for history sections', () => {
    expect(recordCardSource).toContain('Tabs');
    expect(recordCardSource).toContain('Tabs.TabPane');
    expect(recordCardSource).toContain(
      'v-if="section.rows.length > 0" class="employee-history-table"',
    );
    expect(recordCardSource).toContain('employee-history-section-empty');
    expect(recordCardSource).toContain(':scroll="{ x: \'max-content\' }"');
    expect(recordCardSource).not.toContain('section-header--blue');
    expect(recordCardSource).not.toContain('section-header--yellow');
    expect(recordCardSource).not.toContain('section-header--orange');
  });

  it('stacks the two-column layout on smaller screens', () => {
    expect(historyDetailSource).toContain(
      'grid-template-columns: minmax(260px, 300px) minmax(0, 1fr)',
    );
    expect(historyDetailSource).toContain('@media (max-width: 767px)');
    expect(historyDetailSource).toContain('grid-template-columns: 1fr');
  });
});
