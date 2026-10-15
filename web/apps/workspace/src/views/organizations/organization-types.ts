import { $t } from '#/locales';

const organizationTypes = [
  { value: 'Công ty', key: 'organizations.types.company' },
  { value: 'Phòng ban', key: 'organizations.types.department' },
  { value: 'Bộ phận', key: 'organizations.types.division' },
  { value: 'Nhóm', key: 'organizations.types.team' },
  { value: 'Tổ', key: 'organizations.types.unit' },
] as const;

export function createOrganizationTypeOptions() {
  return organizationTypes.map(({ key, value }) => ({ label: $t(key), value }));
}

export function getOrganizationTypeLabel(type: string): string {
  const organizationType = organizationTypes.find(
    ({ value }) => value === type,
  );
  if (organizationType === undefined) return type;
  return $t(organizationType.key);
}
