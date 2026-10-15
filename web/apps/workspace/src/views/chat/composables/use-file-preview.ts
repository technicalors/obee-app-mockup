import { ref } from 'vue';

export type FilePreviewType =
  | 'audio'
  | 'docx'
  | 'image'
  | 'pdf'
  | 'text'
  | 'unsupported'
  | 'video';

export interface FilePreviewItem {
  filename: string;
  fileType: FilePreviewType;
  mimeType?: string;
  size?: string;
  url: string;
}

const isPreviewOpen = ref(false);
const currentFile = ref<FilePreviewItem | null>(null);
const isLoadingContent = ref(false);
const loadingError = ref<null | string>(null);
const textContent = ref<string>('');
const docxBuffer = ref<ArrayBuffer | null>(null);

export function detectFileType(
  filename: string,
  mimeType?: string,
): FilePreviewType {
  const ext = (filename.split('.').pop() || '').toLowerCase();
  const mime = (mimeType || '').toLowerCase();

  // 1. Image
  if (
    ['avif', 'bmp', 'gif', 'ico', 'jpeg', 'jpg', 'png', 'svg', 'webp'].includes(
      ext,
    ) ||
    mime.startsWith('image/')
  ) {
    return 'image';
  }

  // 2. PDF
  if (ext === 'pdf' || mime === 'application/pdf') {
    return 'pdf';
  }

  // 3. Word DOCX
  if (
    ext === 'docx' ||
    mime ===
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ) {
    return 'docx';
  }

  // 4. Video
  if (
    ['m4v', 'mkv', 'mov', 'mp4', 'ogg', 'ogv', 'webm'].includes(ext) ||
    mime.startsWith('video/')
  ) {
    return 'video';
  }

  // 5. Audio
  if (
    ['aac', 'flac', 'm4a', 'mp3', 'oga', 'ogg', 'opus', 'wav'].includes(ext) ||
    mime.startsWith('audio/')
  ) {
    return 'audio';
  }

  // 6. Text / Code / Documents
  if (
    [
      'bash',
      'c',
      'conf',
      'cpp',
      'css',
      'csv',
      'env',
      'go',
      'h',
      'hpp',
      'htm',
      'html',
      'ini',
      'java',
      'js',
      'json',
      'jsx',
      'less',
      'log',
      'markdown',
      'md',
      'php',
      'py',
      'rs',
      'scss',
      'sh',
      'sql',
      'toml',
      'ts',
      'tsx',
      'txt',
      'vue',
      'xml',
      'yaml',
      'yml',
    ].includes(ext) ||
    mime.startsWith('text/') ||
    mime === 'application/json' ||
    mime === 'application/javascript' ||
    mime === 'application/xml'
  ) {
    return 'text';
  }

  return 'unsupported';
}

export function useFilePreview() {
  async function previewFile(item: {
    filename: string;
    mimeType?: string;
    size?: string;
    url: string;
  }): Promise<void> {
    if (!item.url) return;

    const fileType = detectFileType(item.filename, item.mimeType);
    currentFile.value = {
      filename: item.filename,
      fileType,
      mimeType: item.mimeType,
      size: item.size,
      url: item.url,
    };
    loadingError.value = null;
    textContent.value = '';
    docxBuffer.value = null;
    isPreviewOpen.value = true;

    if (fileType === 'text') {
      isLoadingContent.value = true;
      try {
        const response = await fetch(item.url);
        if (!response.ok) {
          throw new Error(`Failed to load file (${response.statusText})`);
        }
        textContent.value = await response.text();
      } catch (error) {
        console.error('Failed to read text file:', error);
        loadingError.value =
          error instanceof Error ? error.message : 'Cannot load file content';
      } finally {
        isLoadingContent.value = false;
      }
    } else if (fileType === 'docx') {
      isLoadingContent.value = true;
      try {
        const response = await fetch(item.url);
        if (!response.ok) {
          throw new Error(`Failed to load file (${response.statusText})`);
        }
        docxBuffer.value = await response.arrayBuffer();
      } catch (error) {
        console.error('Failed to read docx buffer:', error);
        loadingError.value =
          error instanceof Error ? error.message : 'Cannot load Word document';
      } finally {
        isLoadingContent.value = false;
      }
    }
  }

  function previewImage(url: string, title = ''): void {
    void previewFile({
      filename: title || 'Image',
      url,
    });
  }

  function closePreview(): void {
    isPreviewOpen.value = false;
    currentFile.value = null;
    textContent.value = '';
    docxBuffer.value = null;
    loadingError.value = null;
    isLoadingContent.value = false;
  }

  function downloadCurrentFile(): void {
    if (!currentFile.value) return;
    const a = document.createElement('a');
    a.href = currentFile.value.url;
    a.download = currentFile.value.filename;
    document.body.append(a);
    a.click();
    a.remove();
  }

  function openCurrentFileInNewTab(): void {
    if (!currentFile.value) return;
    window.open(currentFile.value.url, '_blank');
  }

  return {
    closePreview,
    currentFile,
    docxBuffer,
    downloadCurrentFile,
    isLoadingContent,
    isPreviewOpen,
    loadingError,
    openCurrentFileInNewTab,
    previewFile,
    previewImage,
    textContent,
  };
}
