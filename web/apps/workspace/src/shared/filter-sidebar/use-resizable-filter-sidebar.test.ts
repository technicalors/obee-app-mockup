import { createApp, nextTick, ref } from 'vue';

import { describe, expect, it, vi } from 'vitest';

import { useResizableFilterSidebar } from './use-resizable-filter-sidebar';

const width = ref(0);
vi.mock('@vueuse/core', () => ({ useElementSize: () => ({ width }) }));

function setup(options?: { openWhenCompact?: boolean }) {
  const open = ref(false);
  let sidebar!: ReturnType<typeof useResizableFilterSidebar>;
  createApp({
    setup() {
      sidebar = useResizableFilterSidebar(
        { content: ref(null), open, trigger: ref(null) },
        options,
      );
      return () => null;
    },
  }).mount(document.createElement('div'));
  return { open, sidebar };
}

describe('useResizableFilterSidebar', () => {
  it('is not compact before the first measurement', () => {
    width.value = 0;
    expect(setup().sidebar.compact.value).toBe(false);
  });

  it('switches to compact below 960px and closes the panel', async () => {
    width.value = 1280;
    const { open, sidebar } = setup();
    open.value = true;
    width.value = 800;
    await nextTick();

    expect(sidebar.compact.value).toBe(true);
    expect(open.value).toBe(false);
  });

  it('opens the panel when compact if requested', async () => {
    width.value = 1280;
    const { open } = setup({ openWhenCompact: true });
    width.value = 800;
    await nextTick();

    expect(open.value).toBe(true);
  });

  it('clamps keyboard resizing between 240 and 480', () => {
    width.value = 1280;
    const { sidebar } = setup();
    const key = (name: string) =>
      sidebar.resizeWithKeyboard(new KeyboardEvent('keydown', { key: name }));

    key('ArrowRight');
    expect(sidebar.width.value).toBe(304);
    key('End');
    expect(sidebar.width.value).toBe(480);
    key('Home');
    expect(sidebar.width.value).toBe(240);
    key('ArrowLeft');
    expect(sidebar.width.value).toBe(240);
  });
});
