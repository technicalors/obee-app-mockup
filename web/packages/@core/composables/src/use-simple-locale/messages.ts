export type Locale = 'en-US' | 'vi-VN' | 'zh-CN';

export const messages: Record<Locale, Record<string, string>> = {
  'en-US': {
    cancel: 'Cancel',
    collapse: 'Collapse',
    confirm: 'Confirm',
    expand: 'Expand',
    prompt: 'Prompt',
    reset: 'Reset',
    submit: 'Submit',
    confirmTitle: 'Please Confirm',
  },
  'vi-VN': {
    cancel: 'Hủy',
    collapse: 'Thu gọn',
    confirm: 'Xác nhận',
    expand: 'Mở rộng',
    prompt: 'Thông báo',
    reset: 'Đặt lại',
    submit: 'Gửi',
    confirmTitle: 'Vui lòng xác nhận',
  },
  'zh-CN': {
    cancel: '取消',
    collapse: '收起',
    confirm: '确认',
    expand: '展开',
    prompt: '提示',
    reset: '重置',
    submit: '提交',
    confirmTitle: '请确认',
  },
};

export const getMessages = (locale: Locale) => messages[locale];
