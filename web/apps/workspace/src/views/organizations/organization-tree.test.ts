import type { Organization } from '#/api';

import { describe, expect, it } from 'vitest';

import {
  buildOrganizationGraphData,
  buildOrganizationTree,
  escapeOrganizationChartHtml,
} from './organization-tree';

function makeOrganization(overrides: Partial<Organization> = {}): Organization {
  return {
    created_at: '2026-01-01T00:00:00Z',
    id: 'organization-1',
    name: 'Organization',
    parent_id: null,
    tax_identification_number: null,
    type: 'Công ty',
    updated_at: '2026-01-01T00:00:00Z',
    ...overrides,
  };
}

describe('organization graph data', () => {
  it('keeps each real root and its children in the chart without a synthetic parent', () => {
    const north = makeOrganization({ id: 'north', name: 'North' });
    const child = makeOrganization({
      id: 'child',
      name: 'Research',
      parent_id: 'north',
      type: 'Nhóm',
    });
    const south = makeOrganization({ id: 'south', name: 'South' });
    const roots = buildOrganizationTree([child, south, north]);
    const chartData = buildOrganizationGraphData(roots);

    expect(
      chartData.map(({ id, parentId, level }) => ({
        id,
        parentId,
        level,
      })),
    ).toEqual([
      { id: 'south', parentId: null, level: 0 },
      { id: 'north', parentId: null, level: 0 },
      { id: 'child', parentId: 'north', level: 1 },
    ]);
    expect(chartData[2]?.organization).toBe(child);
    expect(chartData[2]?.type).toBe('Nhóm');
  });

  it('rejects a hierarchy with an unavailable parent or a cycle', () => {
    expect(() =>
      buildOrganizationTree([
        makeOrganization({ id: 'child', parent_id: 'missing' }),
      ]),
    ).toThrow('Organization child has an unavailable parent.');

    expect(() =>
      buildOrganizationTree([
        makeOrganization({ id: 'one', parent_id: 'two' }),
        makeOrganization({ id: 'two', parent_id: 'one' }),
      ]),
    ).toThrow('The organization hierarchy has an unreachable cycle.');
  });

  it('escapes user-controlled names and free-form type labels for chart HTML', () => {
    expect(escapeOrganizationChartHtml(`R&D <East> "Ops" 'Team'`)).toBe(
      'R&amp;D &lt;East&gt; &quot;Ops&quot; &#039;Team&#039;',
    );
  });
});
