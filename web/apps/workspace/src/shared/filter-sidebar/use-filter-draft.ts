import type { Ref } from 'vue';

import { ref } from 'vue';

import { cloneDeep } from '@vben/utils';

/**
 * Draft/applied filter state for a sidebar. `onApply` runs after the draft is
 * committed; `busy` blocks apply and reset while the table is loading.
 */
export function useFilterDraft<Filters extends object>(options: {
  busy: () => boolean;
  defaults: () => Filters;
  onApply: () => Promise<void>;
}) {
  const draft = ref(options.defaults()) as Ref<Filters>;
  const applied = ref(options.defaults()) as Ref<Filters>;
  const open = ref(false);
  async function apply(): Promise<void> {
    if (options.busy()) return;
    applied.value = cloneDeep(draft.value);
    open.value = false;
    await options.onApply();
  }

  function reset(): void {
    if (options.busy()) return;
    draft.value = options.defaults();
  }

  function close(): void {
    draft.value = cloneDeep(applied.value);
    open.value = false;
  }

  return { applied, apply, close, draft, open, reset };
}
