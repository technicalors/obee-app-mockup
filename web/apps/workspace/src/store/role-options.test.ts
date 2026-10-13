import { createPinia, setActivePinia } from 'pinia';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { useRoleOptionsStore } from './role-options';

const rolesResource = vi.hoisted(() => ({
  getAll: vi.fn(),
}));

vi.mock('#/api/roles', () => ({
  rolesResource,
}));

describe('useRoleOptionsStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
    rolesResource.getAll.mockReset();
  });

  it('loads roles once for multiple consumers', async () => {
    rolesResource.getAll.mockResolvedValue([
      {
        created_at: '2026-06-11T00:00:00.000000Z',
        description: null,
        id: 'role-1',
        name: 'admin',
        permissions: [],
        updated_at: '2026-06-11T00:00:00.000000Z',
      },
    ]);

    const store = useRoleOptionsStore();

    await Promise.all([store.loadOnce(), store.loadOnce()]);
    await store.loadOnce();

    expect(rolesResource.getAll).toHaveBeenCalledTimes(1);
    expect(store.roles).toEqual([
      expect.objectContaining({
        id: 'role-1',
        name: 'admin',
        permissions: [],
      }),
    ]);
    expect(store.loaded).toBe(true);
  });

  it('refreshes roles after the initial cached load', async () => {
    rolesResource.getAll
      .mockResolvedValueOnce([
        {
          created_at: '2026-06-11T00:00:00.000000Z',
          description: null,
          id: 'role-1',
          name: 'admin',
          permissions: [],
          updated_at: '2026-06-11T00:00:00.000000Z',
        },
      ])
      .mockResolvedValueOnce([
        {
          created_at: '2026-06-11T00:00:00.000000Z',
          description: null,
          id: 'role-2',
          name: 'manager',
          permissions: [],
          updated_at: '2026-06-11T00:00:00.000000Z',
        },
      ]);

    const store = useRoleOptionsStore();

    await store.loadOnce();
    await store.refresh();

    expect(rolesResource.getAll).toHaveBeenCalledTimes(2);
    expect(store.roles).toEqual([
      expect.objectContaining({
        id: 'role-2',
        name: 'manager',
        permissions: [],
      }),
    ]);
  });

  it('resets cached role state', async () => {
    rolesResource.getAll.mockResolvedValue([
      {
        created_at: '2026-06-11T00:00:00.000000Z',
        description: null,
        id: 'role-1',
        name: 'admin',
        permissions: [],
        updated_at: '2026-06-11T00:00:00.000000Z',
      },
    ]);

    const store = useRoleOptionsStore();

    await store.loadOnce();
    store.$reset();

    expect(store.roles).toEqual([]);
    expect(store.loaded).toBe(false);
    expect(store.loading).toBe(false);
  });
});
