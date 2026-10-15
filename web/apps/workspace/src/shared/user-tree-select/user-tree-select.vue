<script setup lang="ts">
import type { DefaultOptionType } from 'ant-design-vue/es/vc-tree-select/TreeSelect';

import type { UserTreeSelectionUser } from '#/api/contracts';

import { computed } from 'vue';

import { TreeSelect } from 'ant-design-vue';

import { $t } from '#/locales';

import { buildUserTreeOptions } from './user-tree-select';

const props = withDefaults(
  defineProps<{
    ariaLabel?: string;
    disabled?: boolean;
    loadError?: boolean;
    loading?: boolean;
    modelValue: string[];
    multiple?: boolean;
    placeholder?: string;
    size?: 'large' | 'middle' | 'small';
    testId?: string;
    users: UserTreeSelectionUser[];
  }>(),
  {
    ariaLabel: undefined,
    disabled: false,
    loadError: false,
    loading: false,
    multiple: true,
    placeholder: undefined,
    size: undefined,
    testId: undefined,
  },
);

const emit = defineEmits<{
  'update:modelValue': [value: string[]];
}>();

const treeData = computed(() => buildUserTreeOptions(props.users));
const treeValue = computed(() =>
  props.multiple ? props.modelValue : props.modelValue[0],
);
const selectDisabled = computed(
  () => props.disabled || props.loading || props.loadError,
);

function filterTreeNode(inputValue: string, treeNode: DefaultOptionType) {
  const searchText = treeNode.searchText;

  return (
    typeof searchText === 'string' &&
    searchText.toLocaleLowerCase().includes(inputValue.toLocaleLowerCase())
  );
}

function handleValueUpdate(value: unknown): void {
  if (selectDisabled.value) {
    return;
  }

  let candidates: unknown[];

  if (Array.isArray(value)) {
    candidates = value;
  } else if (value === undefined || value === null) {
    candidates = [];
  } else {
    candidates = [value];
  }
  const userIds = new Set([
    ...props.users.map((user) => user.id),
    ...props.modelValue,
  ]);
  const selectedIds = [
    ...new Set(
      candidates.filter(
        (candidate): candidate is string =>
          typeof candidate === 'string' && userIds.has(candidate),
      ),
    ),
  ];

  emit(
    'update:modelValue',
    props.multiple ? selectedIds : selectedIds.slice(0, 1),
  );
}
</script>

<template>
  <div class="min-w-0">
    <TreeSelect
      :aria-label="ariaLabel"
      :data-testid="testId"
      :disabled="selectDisabled"
      :dropdown-match-select-width="false"
      :dropdown-style="{ width: '400px', minWidth: '400px' }"
      :filter-tree-node="filterTreeNode"
      :list-height="224"
      :loading="loading"
      max-tag-count="responsive"
      :multiple="multiple"
      not-found-content=""
      :placeholder="placeholder"
      popup-class-name="user-tree-select-popup"
      :show-checked-strategy="TreeSelect.SHOW_CHILD"
      :show-search="true"
      :size="size"
      :tree-checkable="multiple"
      :tree-data="treeData"
      :value="treeValue"
      allow-clear
      class="w-full"
      @update:value="handleValueUpdate"
    />
    <p v-if="loadError" class="mt-1 text-xs text-destructive" role="alert">
      {{ $t('userTreeSelect.loadError') }}
    </p>
  </div>
</template>

<style>
.user-tree-select-popup.ant-select-dropdown {
  width: 400px !important;
  min-width: 400px !important;
  max-height: min(70vh, 24rem);
  overflow-y: auto;
}
</style>
