import { describe, expect, it, vi } from 'vitest';

import { useFilterDraft } from './use-filter-draft';

interface Filters {
  roles: string[];
  search: string;
}

function setup(busy = false) {
  const onApply = vi.fn(async () => {});
  const filters = useFilterDraft<Filters>({
    busy: () => busy,
    defaults: () => ({ roles: [], search: '' }),
    onApply,
  });
  return { filters, onApply };
}

describe('useFilterDraft', () => {
  it('applies a copy of the draft, closes, and reloads', async () => {
    const { filters, onApply } = setup();
    filters.open.value = true;
    filters.draft.value = { roles: ['admin'], search: 'an' };
    await filters.apply();
    filters.draft.value.roles.push('staff');

    expect(filters.applied.value).toEqual({ roles: ['admin'], search: 'an' });
    expect(filters.open.value).toBe(false);
    expect(onApply).toHaveBeenCalledOnce();
  });

  it('close discards the draft and reset restores defaults', () => {
    const { filters } = setup();
    filters.draft.value = { roles: ['admin'], search: 'an' };
    filters.close();
    expect(filters.draft.value).toEqual({ roles: [], search: '' });

    filters.draft.value = { roles: [], search: 'x' };
    filters.reset();
    expect(filters.draft.value).toEqual({ roles: [], search: '' });
  });

  it('ignores apply and reset while busy', async () => {
    const { filters, onApply } = setup(true);
    filters.draft.value = { roles: [], search: 'x' };

    await filters.apply();
    filters.reset();

    expect(onApply).not.toHaveBeenCalled();
    expect(filters.draft.value.search).toBe('x');
  });
});
