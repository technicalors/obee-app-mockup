<script setup lang="ts">
import type { RecoveryErrorCode } from '#/store';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';
import { useUserStore } from '@vben/stores';

import { Alert, Button, Checkbox, Input, Modal } from 'ant-design-vue';

import { $t } from '#/locales';

interface Props {
  error?: null | RecoveryErrorCode;
  loading?: boolean;
  mode: 'restore' | 'setup';
  open: boolean;
  recoveryKey?: null | string;
}

const props = withDefaults(defineProps<Props>(), {
  error: null,
  loading: false,
  recoveryKey: null,
});

const emit = defineEmits<{
  restore: [key: string];
  setup: [];
  'update:open': [value: boolean];
}>();

const userStore = useUserStore();

const hasSavedKey = ref(false);
const isCopied = ref(false);
const isDownloaded = ref(false);
const inputRecoveryKey = ref('');

const canFinishSetup = computed(
  () => Boolean(props.recoveryKey) && hasSavedKey.value,
);
const canRestore = computed(() => inputRecoveryKey.value.trim().length > 0);
const errorMessage = computed(() =>
  props.error ? $t(`chat.recoveryKeyPreview.errors.${props.error}`) : '',
);

watch(
  () => props.open,
  (open) => {
    if (open) return;
    hasSavedKey.value = false;
    isCopied.value = false;
    isDownloaded.value = false;
    inputRecoveryKey.value = '';
  },
);

async function copyRecoveryKey(): Promise<void> {
  const key = props.recoveryKey;
  if (!key) {
    throw new Error('Matrix recovery key is not available');
  }

  if (navigator.clipboard) {
    await navigator.clipboard.writeText(key);
  } else {
    const textarea = document.createElement('textarea');
    textarea.value = key;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.append(textarea);
    textarea.select();
    document.execCommand('copy');
    textarea.remove();
  }
  isCopied.value = true;
}

function downloadRecoveryKey(): void {
  const key = props.recoveryKey;
  if (!key) {
    throw new Error('Matrix recovery key is not available');
  }
  const username = userStore.userInfo?.username;
  if (!username) {
    throw new Error('Matrix recovery key username is not available');
  }

  const blob = new Blob([`${key}\n`], { type: 'text/plain;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = `${username}_key.txt`;
  document.body.append(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(url);
  isDownloaded.value = true;
}

function finish(): void {
  if (props.mode === 'setup') {
    if (canFinishSetup.value) emit('setup');
    return;
  }

  if (canRestore.value) {
    emit('restore', inputRecoveryKey.value.trim());
  }
}
</script>

<template>
  <Modal
    :open="open"
    :closable="false"
    :mask-closable="false"
    :keyboard="false"
    :footer="null"
    centered
    width="520px"
  >
    <div class="flex flex-col gap-4 pt-1">
      <div class="flex items-start gap-3.5">
        <div
          class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
        >
          <IconifyIcon
            :icon="
              mode === 'setup' ? 'lucide:shield-check' : 'lucide:key-round'
            "
            class="size-5"
          />
        </div>
        <div class="min-w-0 flex-1 space-y-1">
          <h2 class="m-0 text-base font-semibold leading-snug text-foreground">
            {{
              $t(
                mode === 'setup'
                  ? 'chat.recoveryKeyPreview.title'
                  : 'chat.recoveryKeyPreview.restoreTitle',
              )
            }}
          </h2>
          <p class="m-0 text-xs leading-relaxed text-muted-foreground">
            {{
              $t(
                mode === 'setup'
                  ? 'chat.recoveryKeyPreview.intro'
                  : 'chat.recoveryKeyPreview.restoreDescription',
              )
            }}
          </p>
        </div>
      </div>

      <template v-if="mode === 'setup'">
        <div class="flex flex-col gap-2.5">
          <div
            class="rounded-xl border border-border bg-muted/40 px-4 py-3.5 text-center"
          >
            <code
              class="block select-all break-words font-mono text-sm font-semibold leading-relaxed tracking-wider text-foreground"
            >
              {{ recoveryKey }}
            </code>
          </div>
          <div class="grid grid-cols-2 gap-2.5">
            <Button
              class="inline-flex h-9 items-center justify-center gap-1.5 rounded-lg text-xs font-medium"
              :class="{
                '!border-emerald-500/60 !bg-emerald-500/5 !text-emerald-600 dark:!text-emerald-400':
                  isCopied,
              }"
              @click="copyRecoveryKey"
            >
              <IconifyIcon
                :icon="isCopied ? 'lucide:check' : 'lucide:copy'"
                class="size-3.5 shrink-0"
              />
              <span>
                {{
                  $t(
                    isCopied
                      ? 'chat.recoveryKeyPreview.copied'
                      : 'chat.recoveryKeyPreview.copy',
                  )
                }}
              </span>
            </Button>
            <Button
              class="inline-flex h-9 items-center justify-center gap-1.5 rounded-lg text-xs font-medium"
              :class="{
                '!border-emerald-500/60 !bg-emerald-500/5 !text-emerald-600 dark:!text-emerald-400':
                  isDownloaded,
              }"
              @click="downloadRecoveryKey"
            >
              <IconifyIcon
                :icon="isDownloaded ? 'lucide:check' : 'lucide:download'"
                class="size-3.5 shrink-0"
              />
              <span>
                {{
                  $t(
                    isDownloaded
                      ? 'chat.recoveryKeyPreview.downloaded'
                      : 'chat.recoveryKeyPreview.download',
                  )
                }}
              </span>
            </Button>
          </div>
        </div>

        <Alert
          type="warning"
          show-icon
          class="!items-start !rounded-xl !px-3.5 !py-3 [&_.ant-alert-icon]:!mt-0.5"
        >
          <template #message>
            <div class="space-y-0.5 text-xs">
              <div class="font-semibold text-foreground">
                {{ $t('chat.recoveryKeyPreview.warningTitle') }}
              </div>
              <p class="m-0 leading-relaxed text-muted-foreground">
                {{ $t('chat.recoveryKeyPreview.warningDescription') }}
              </p>
            </div>
          </template>
        </Alert>

        <Checkbox v-model:checked="hasSavedKey" class="flex items-center">
          <span class="select-none text-xs font-medium text-foreground">
            {{ $t('chat.recoveryKeyPreview.savedConfirmation') }}
          </span>
        </Checkbox>
      </template>

      <template v-else>
        <div class="flex flex-col gap-2">
          <label class="text-xs font-medium text-foreground">
            {{ $t('chat.recoveryKeyPreview.inputLabel') }}
          </label>
          <Input
            v-model:value="inputRecoveryKey"
            :placeholder="$t('chat.recoveryKeyPreview.inputPlaceholder')"
            :disabled="loading"
            autocomplete="off"
            class="h-10 rounded-lg font-mono text-xs"
            @press-enter="finish"
          />
        </div>
      </template>

      <Alert
        v-if="errorMessage"
        :message="errorMessage"
        type="error"
        show-icon
        class="!rounded-xl text-xs"
      />

      <Button
        type="primary"
        block
        :loading="loading"
        :disabled="mode === 'setup' ? !canFinishSetup : !canRestore"
        class="flex h-10 items-center justify-center rounded-lg text-xs font-medium"
        @click="finish"
      >
        {{
          $t(
            mode === 'setup'
              ? 'chat.recoveryKeyPreview.finish'
              : 'chat.recoveryKeyPreview.confirm',
          )
        }}
      </Button>
    </div>
  </Modal>
</template>
