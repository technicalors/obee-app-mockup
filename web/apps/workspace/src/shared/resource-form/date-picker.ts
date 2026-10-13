export function getDatePickerDisplayFormat(locale: string): string {
  switch (locale) {
    case 'en-US': {
      return 'MM/DD/YYYY';
    }
    case 'vi-VN': {
      return 'DD/MM/YYYY';
    }
    case 'zh-CN': {
      return 'YYYY-MM-DD';
    }
    default: {
      return 'YYYY-MM-DD';
    }
  }
}
