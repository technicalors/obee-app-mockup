import type { Ref } from 'vue';

import { computed, ref, watch } from 'vue';

import { useElementSize } from '@vueuse/core';

const COMPACT_BREAKPOINT = 960;
export const MIN_SIDEBAR_WIDTH = 240;
export const MAX_SIDEBAR_WIDTH = 480;
const KEYBOARD_STEP = 16;

/**
 * Resizable filter sidebar state shared by master data pages. `content` is the
 * layout row measured for `compact`; `trigger` is the button that opens the
 * panel while compact and gets focus back when it closes.
 */
export function useResizableFilterSidebar(
  refs: {
    content: Ref<HTMLElement | null>;
    open: Ref<boolean>;
    trigger: Ref<null | { $el: HTMLElement }>;
  },
  options: { openWhenCompact?: boolean } = {},
) {
  const { content, open, trigger } = refs;
  const { width: contentWidth } = useElementSize(content);
  // Width is 0 until the first measurement; treating it as compact flashes the narrow layout.
  const compact = computed(
    () => contentWidth.value > 0 && contentWidth.value < COMPACT_BREAKPOINT,
  );
  const width = ref(288);
  let pointerId: null | number = null;
  let startX = 0;
  let startWidth = 0;

  function setWidth(value: number): void {
    width.value = Math.max(
      MIN_SIDEBAR_WIDTH,
      Math.min(MAX_SIDEBAR_WIDTH, value),
    );
  }

  function startResize(event: PointerEvent): void {
    if (compact.value) return;
    event.preventDefault();
    pointerId = event.pointerId;
    startX = event.clientX;
    startWidth = width.value;
    (event.currentTarget as HTMLElement).setPointerCapture(event.pointerId);
  }

  function resize(event: PointerEvent): void {
    if (event.pointerId !== pointerId) return;
    setWidth(startWidth + event.clientX - startX);
  }

  function stopResize(event: PointerEvent): void {
    if (event.pointerId === pointerId) pointerId = null;
  }

  function resizeWithKeyboard(event: KeyboardEvent): void {
    switch (event.key) {
      case 'ArrowLeft': {
        event.preventDefault();
        setWidth(width.value - KEYBOARD_STEP);
        break;
      }
      case 'ArrowRight': {
        event.preventDefault();
        setWidth(width.value + KEYBOARD_STEP);
        break;
      }
      case 'End': {
        event.preventDefault();
        setWidth(MAX_SIDEBAR_WIDTH);
        break;
      }
      case 'Home': {
        event.preventDefault();
        setWidth(MIN_SIDEBAR_WIDTH);
        break;
      }
    }
  }

  watch(compact, (isCompact) => {
    // Layout changes preserve filter drafts; only an explicit close discards them.
    open.value = isCompact && options.openWhenCompact === true;
  });

  watch(
    open,
    (isOpen) => {
      if (!isOpen && compact.value) trigger.value?.$el.focus();
    },
    { flush: 'post' },
  );

  return {
    compact,
    resize,
    resizeWithKeyboard,
    startResize,
    stopResize,
    width,
  };
}
