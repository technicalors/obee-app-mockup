<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Button, Modal, Spin } from 'ant-design-vue';
import { renderAsync } from 'docx-preview';

import { useFilePreview } from '../composables/use-file-preview';

const {
  closePreview,
  currentFile,
  docxBuffer,
  downloadCurrentFile,
  isLoadingContent,
  isPreviewOpen,
  loadingError,
  openCurrentFileInNewTab,
  textContent,
} = useFilePreview();

const docxContainerRef = ref<HTMLElement | null>(null);
const docxRendering = ref(false);
const docxError = ref<null | string>(null);

const fileExtension = computed(() => {
  if (!currentFile.value?.filename) return '';
  const parts = currentFile.value.filename.split('.');
  return parts.length > 1 ? (parts.pop() || '').toUpperCase() : 'FILE';
});

const badgeBg = computed(() => {
  const ext = fileExtension.value;
  switch (ext) {
    case '7Z':
    case 'RAR':
    case 'ZIP': {
      return 'bg-amber-500 text-white dark:bg-amber-600';
    }
    case 'AAC':
    case 'FLAC':
    case 'M4A':
    case 'MP3':
    case 'WAV': {
      return 'bg-pink-500 text-white dark:bg-pink-600';
    }
    case 'CSV':
    case 'XLS':
    case 'XLSX': {
      return 'bg-emerald-500 text-white dark:bg-emerald-600';
    }
    case 'DOC':
    case 'DOCX': {
      return 'bg-indigo-500 text-white dark:bg-indigo-600';
    }
    case 'LOG':
    case 'TXT': {
      return 'bg-cyan-500 text-white dark:bg-cyan-600';
    }
    case 'M4V':
    case 'MKV':
    case 'MOV':
    case 'MP4':
    case 'WEBM': {
      return 'bg-purple-500 text-white dark:bg-purple-600';
    }
    case 'PDF': {
      return 'bg-rose-500 text-white dark:bg-rose-600';
    }
    default: {
      return 'bg-blue-500 text-white dark:bg-blue-600';
    }
  }
});

const canOpenInNewTab = computed(() => {
  const type = currentFile.value?.fileType;
  return (
    type === 'audio' ||
    type === 'image' ||
    type === 'pdf' ||
    type === 'text' ||
    type === 'video'
  );
});

const lineCount = computed(() => {
  if (!textContent.value) return 0;
  return textContent.value.split('\n').length;
});

watch(
  () => [docxBuffer.value, isPreviewOpen.value] as const,
  async ([buffer, isOpen]) => {
    if (!isOpen || !buffer) return;
    docxRendering.value = true;
    docxError.value = null;
    await nextTick();
    if (!docxContainerRef.value) {
      docxRendering.value = false;
      return;
    }
    try {
      docxContainerRef.value.innerHTML = '';
      await renderAsync(buffer, docxContainerRef.value, undefined, {
        breakPages: true,
        className: 'docx-preview-content',
        ignoreWidth: false,
        inWrapper: true,
      });
    } catch (error) {
      console.error('Failed to render docx in modal:', error);
      docxError.value =
        error instanceof Error ? error.message : 'Cannot render Word preview';
    } finally {
      docxRendering.value = false;
    }
  },
);
</script>

<template>
  <Modal
    :open="isPreviewOpen"
    :footer="null"
    :destroy-on-close="true"
    :closable="false"
    centered
    width="min(95vw, 960px)"
    wrap-class-name="chat-file-preview-modal-wrap"
    @cancel="closePreview"
  >
    <div class="flex flex-col gap-3 p-1">
      <!-- Header -->
      <div
        class="flex items-center justify-between border-b border-border/50 pb-2.5"
      >
        <div class="flex min-w-0 items-center gap-2.5">
          <div
            class="flex size-7 shrink-0 items-center justify-center rounded-md font-bold text-[10px] tracking-wide shadow-2xs"
            :class="badgeBg"
          >
            {{ fileExtension }}
          </div>
          <div class="flex min-w-0 items-baseline gap-2">
            <span
              class="truncate font-semibold text-foreground text-sm"
              :title="currentFile?.filename"
            >
              {{ currentFile?.filename }}
            </span>
            <span
              v-if="currentFile?.size"
              class="shrink-0 text-muted-foreground text-xs"
            >
              ({{ currentFile.size }})
            </span>
          </div>
        </div>

        <div class="flex shrink-0 items-center gap-1.5">
          <Button
            v-if="canOpenInNewTab"
            size="small"
            type="text"
            class="flex items-center gap-1 text-muted-foreground text-xs hover:text-foreground"
            @click="openCurrentFileInNewTab"
          >
            <template #icon>
              <IconifyIcon icon="lucide:external-link" class="size-3.5" />
            </template>
            <span class="hidden sm:inline">{{ $t('chat.openInNewTab') }}</span>
          </Button>

          <Button
            size="small"
            type="primary"
            class="flex items-center gap-1 text-xs"
            @click="downloadCurrentFile"
          >
            <template #icon>
              <IconifyIcon icon="lucide:download" class="size-3.5" />
            </template>
            <span>{{ $t('chat.downloadFile') }}</span>
          </Button>

          <Button
            size="small"
            type="text"
            shape="circle"
            class="flex items-center justify-center text-muted-foreground hover:text-foreground"
            @click="closePreview"
          >
            <template #icon>
              <IconifyIcon icon="lucide:x" class="size-4" />
            </template>
          </Button>
        </div>
      </div>

      <!-- Content Area -->
      <div class="relative min-h-[300px]">
        <!-- Loading State -->
        <div
          v-if="isLoadingContent || docxRendering"
          class="flex h-[400px] flex-col items-center justify-center gap-3 text-muted-foreground"
        >
          <Spin size="large" />
          <span class="text-xs">{{ $t('chat.loadingDocument') }}</span>
        </div>

        <!-- Error State -->
        <div
          v-else-if="loadingError || docxError"
          class="flex h-[320px] flex-col items-center justify-center gap-3 text-center"
        >
          <IconifyIcon
            icon="lucide:alert-circle"
            class="size-10 text-destructive"
          />
          <span class="font-medium text-foreground text-sm">
            {{ loadingError || docxError }}
          </span>
          <Button
            type="primary"
            class="flex items-center gap-1.5 text-xs"
            @click="downloadCurrentFile"
          >
            <template #icon>
              <IconifyIcon icon="lucide:download" class="size-3.5" />
            </template>
            <span>{{ $t('chat.downloadFile') }}</span>
          </Button>
        </div>

        <!-- Render Specific Types -->
        <template v-else-if="currentFile">
          <!-- 1. Image -->
          <div
            v-if="currentFile.fileType === 'image'"
            class="flex max-h-[75vh] items-center justify-center overflow-hidden rounded-lg bg-black/5 p-2 dark:bg-white/5"
          >
            <img
              :src="currentFile.url"
              :alt="currentFile.filename"
              class="max-h-[72vh] max-w-full select-none rounded object-contain shadow-sm"
            />
          </div>

          <!-- 2. PDF -->
          <div
            v-else-if="currentFile.fileType === 'pdf'"
            class="h-[75vh] w-full overflow-hidden rounded-lg border border-border/40 bg-white"
          >
            <iframe
              :src="currentFile.url"
              class="size-full border-0"
              title="PDF Preview"
            ></iframe>
          </div>

          <!-- 3. Word DOCX -->
          <div
            v-else-if="currentFile.fileType === 'docx'"
            class="h-[75vh] w-full overflow-y-auto rounded-lg border border-border/40 bg-muted/25 p-2 md:p-4"
          >
            <div
              ref="docxContainerRef"
              class="docx-preview-host mx-auto max-w-[850px]"
            ></div>
          </div>

          <!-- 4. Text / Code -->
          <div
            v-else-if="currentFile.fileType === 'text'"
            class="flex h-[75vh] w-full flex-col overflow-hidden rounded-lg border border-border/40 bg-muted/15"
          >
            <div
              class="flex items-center justify-between border-b border-border/40 bg-muted/40 px-3 py-1.5 font-mono text-muted-foreground text-xs"
            >
              <span>{{ currentFile.filename }}</span>
              <span v-if="lineCount">{{ lineCount }} lines</span>
            </div>
            <pre
              class="flex-1 select-text overflow-auto p-4 font-mono text-foreground text-xs leading-relaxed whitespace-pre-wrap"
            ><code>{{ textContent }}</code></pre>
          </div>

          <!-- 5. Video -->
          <div
            v-else-if="currentFile.fileType === 'video'"
            class="flex max-h-[75vh] items-center justify-center overflow-hidden rounded-lg bg-black p-2"
          >
            <video
              :src="currentFile.url"
              controls
              autoplay
              class="max-h-[72vh] max-w-full rounded"
            ></video>
          </div>

          <!-- 6. Audio -->
          <div
            v-else-if="currentFile.fileType === 'audio'"
            class="flex h-[240px] flex-col items-center justify-center gap-4 rounded-lg border border-border/40 bg-muted/15 p-6"
          >
            <div
              class="flex size-14 items-center justify-center rounded-full bg-primary/10 text-primary"
            >
              <IconifyIcon icon="lucide:music" class="size-7" />
            </div>
            <div class="font-medium text-foreground text-sm">
              {{ currentFile.filename }}
            </div>
            <audio
              :src="currentFile.url"
              controls
              autoplay
              class="w-full max-w-md"
            ></audio>
          </div>

          <!-- 7. Unsupported / Fallback -->
          <div
            v-else
            class="flex h-[320px] flex-col items-center justify-center gap-3 rounded-lg border border-border/40 bg-muted/15 p-6 text-center"
          >
            <div
              class="flex size-16 items-center justify-center rounded-2xl font-bold text-lg shadow-xs"
              :class="badgeBg"
            >
              {{ fileExtension }}
            </div>
            <div class="font-medium text-foreground text-sm">
              {{ currentFile.filename }}
            </div>
            <!-- eslint-disable vue/html-closing-bracket-newline -->
            <span
              v-if="currentFile.size"
              class="text-muted-foreground text-xs"
              >{{ currentFile.size }}</span
            >
            <!-- eslint-enable vue/html-closing-bracket-newline -->
            <p class="max-w-xs text-muted-foreground text-xs">
              {{ $t('chat.unsupportedPreview') }}
            </p>
            <Button
              type="primary"
              class="mt-2 flex items-center gap-1.5 text-xs"
              @click="downloadCurrentFile"
            >
              <template #icon>
                <IconifyIcon icon="lucide:download" class="size-3.5" />
              </template>
              <span>{{ $t('chat.downloadFile') }}</span>
            </Button>
          </div>
        </template>
      </div>
    </div>
  </Modal>
</template>

<style>
.docx-preview-host .docx-wrapper {
  padding: 0 !important;
  background: transparent !important;
}

.docx-preview-host .docx-wrapper > section.docx {
  margin: 0 auto 16px !important;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgb(0 0 0 / 8%) !important;
}
</style>
