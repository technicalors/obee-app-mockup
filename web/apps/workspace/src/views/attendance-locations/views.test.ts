import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { describe, expect, it } from 'vitest';

const createSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/attendance-locations/create.vue',
  ),
  'utf8',
);
const editSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/attendance-locations/edit.vue',
  ),
  'utf8',
);
const viewSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/attendance-locations/view.vue',
  ),
  'utf8',
);
const detailFormSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/attendance-locations/detail-form.vue',
  ),
  'utf8',
);
const mapboxMapPickerSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/attendance-locations/MapboxMapPicker.vue',
  ),
  'utf8',
);

describe('attendance locations separate pages views', () => {
  it('implements create view mapping to DetailForm with mode=create', () => {
    expect(createSource).toContain('DetailForm');
    expect(createSource).toContain('mode="create"');
  });

  it('implements edit view mapping to DetailForm with mode=edit and route id binding', () => {
    expect(editSource).toContain('DetailForm');
    expect(editSource).toContain('mode="edit"');
    expect(editSource).toContain(':id="id"');
  });

  it('implements view detail mapping to DetailForm with mode=view and route id binding', () => {
    expect(viewSource).toContain('DetailForm');
    expect(viewSource).toContain('mode="view"');
    expect(viewSource).toContain(':id="id"');
  });

  it('uses explicit Ant Design Vue form state for editable attendance location pages', () => {
    expect(detailFormSource).toContain('Form,\n  FormItem,\n  Input,');
    expect(detailFormSource).toContain('Tabs,');
    expect(detailFormSource).toContain(
      'const formState = reactive<AttendanceLocationFormValues>',
    );
    expect(detailFormSource).toContain('class="attendance-location-form"');
  });

  it('does not use Vben schema form for the content-heavy edit page', () => {
    expect(detailFormSource).not.toContain('useVbenForm');
    expect(detailFormSource).not.toContain('formApi');
  });

  it('renders editable attendance location content across four tabs', () => {
    expect(detailFormSource).toContain('<Tabs.TabPane key="basic">');
    expect(detailFormSource).toContain('<Tabs.TabPane key="ips">');
    expect(detailFormSource).toContain('<Tabs.TabPane key="departments">');
    expect(detailFormSource).toContain('<Tabs.TabPane key="users">');
  });

  it('uses tag input controls for editable IP addresses', () => {
    expect(detailFormSource).toContain('formState.ip_addresses');
    expect(detailFormSource).toContain(
      'v-model:value="formState.ip_addresses"',
    );
    expect(detailFormSource).toContain('mode="tags"');
    expect(detailFormSource).not.toContain('showIpInput');
  });

  it('uses searchable checkboxes for department assignment', () => {
    expect(detailFormSource).toContain('departmentSearch');
    expect(detailFormSource).toContain('filteredDepartmentOptions');
    expect(detailFormSource).toContain('<Checkbox.Group');
    expect(detailFormSource).not.toContain(
      ':placeholder="\n                    $t(\'page.attendanceLocations.placeholders.departments\')\n                  "',
    );
  });

  it('treats empty department and user selections as company-wide assignment', () => {
    expect(detailFormSource).toContain(
      'const hasExplicitAssignments = computed',
    );
    expect(detailFormSource).toContain(
      '? selectedUserIds.has(userId) || departmentUserIds.value.has(userId)',
    );
    expect(detailFormSource).toContain(': true;');
  });

  it('uses Ant Design icon props for action buttons instead of inline icon slots', () => {
    expect(detailFormSource).toContain(
      `:icon="h(IconifyIcon, { icon: 'lucide:pencil'`,
    );
    expect(detailFormSource).toContain(
      `:icon="h(IconifyIcon, { icon: 'lucide:save'`,
    );
    expect(detailFormSource).toContain(`icon: 'lucide:crosshair'`);
    expect(detailFormSource).toContain(`icon: 'lucide:user-plus'`);
    expect(detailFormSource).toContain(`icon: 'lucide:user-minus'`);
    expect(detailFormSource).toContain(`icon: 'lucide:trash-2'`);
  });

  it('integrates MapboxMapPicker with explicit form state', () => {
    expect(detailFormSource).toContain('MapboxMapPicker');
    expect(detailFormSource).toContain(':latitude="mapState.latitude"');
    expect(detailFormSource).toContain(':longitude="mapState.longitude"');
    expect(detailFormSource).toContain(':radius="mapState.radius_meters"');
  });

  it('styles custom map controls with explicit button alignment and theme-safe colors', () => {
    expect(mapboxMapPickerSource).toContain('obee-map-control-button');
    expect(mapboxMapPickerSource).toContain('justify-content: center;');
    expect(mapboxMapPickerSource).toContain('background-color: transparent;');
    expect(mapboxMapPickerSource).toContain('color: #333;');
  });

  it('localizes map status messages and style control labels', () => {
    expect(mapboxMapPickerSource).toContain(
      "$t('page.attendanceLocations.actions.switchToSatellite')",
    );
    expect(mapboxMapPickerSource).toContain(
      "$t('page.attendanceLocations.actions.switchToStandard')",
    );
    expect(mapboxMapPickerSource).toContain(
      "$t('page.attendanceLocations.messages.mapboxKeyMissing')",
    );
    expect(mapboxMapPickerSource).toContain(
      "$t('page.attendanceLocations.messages.mapboxUnavailable')",
    );
    expect(mapboxMapPickerSource).not.toContain('Switch to Satellite');
    expect(mapboxMapPickerSource).not.toContain('Switch to Standard');
    expect(mapboxMapPickerSource).not.toContain('WebGL is unavailable');
  });
});
