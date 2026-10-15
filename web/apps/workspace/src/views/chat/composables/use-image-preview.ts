import { computed } from 'vue';

import { useFilePreview } from './use-file-preview';

export function useImagePreview() {
  const filePreview = useFilePreview();

  return {
    closePreview: filePreview.closePreview,
    isPreviewOpen: filePreview.isPreviewOpen,
    previewImage: filePreview.previewImage,
    previewImageTitle: computed(
      () => filePreview.currentFile.value?.filename || '',
    ),
    previewImageUrl: computed(() => filePreview.currentFile.value?.url || ''),
  };
}
