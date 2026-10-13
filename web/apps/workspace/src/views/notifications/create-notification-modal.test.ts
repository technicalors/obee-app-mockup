import { createApp } from 'vue';

import { describe, expect, it, vi } from 'vitest';

const formState = vi.hoisted(() => ({
  config: undefined as unknown,
}));

vi.mock('@vben/common-ui', () => ({
  useVbenModal: () => [
    {},
    {
      close: vi.fn(),
      getData: vi.fn(),
      lock: vi.fn(),
      unlock: vi.fn(),
    },
  ],
}));

vi.mock('ant-design-vue', () => ({
  Button: {},
  notification: {
    success: vi.fn(),
  },
}));

vi.mock('#/adapter/form', () => ({
  useVbenForm: (config: unknown) => {
    formState.config = config;

    return [
      {},
      {
        getValues: vi.fn(),
        resetForm: vi.fn(),
        validate: vi.fn(),
      },
    ];
  },
}));

vi.mock('#/api', () => ({
  getNotificationRecipientsApi: vi.fn(),
  manualNotificationPayloadSchema: {
    parse: vi.fn(),
    shape: {
      recipient_ids: [],
    },
  },
}));

vi.mock('#/locales', () => ({
  $t: (key: string) => key,
}));

vi.mock('#/shared/request-feedback', () => ({
  showRequestError: vi.fn(),
}));

vi.mock('#/store', () => ({
  useNotificationStore: () => ({
    sendManualNotification: vi.fn(),
  }),
}));

interface FormSchemaConfig {
  schema: Array<{
    component: string;
    componentProps: Record<string, unknown>;
  }>;
}

describe('createNotificationModal', () => {
  it('configures recipient search by the displayed user identity', async () => {
    const { default: CreateNotificationModal } =
      await import('./create-notification-modal.vue');
    const app = createApp(CreateNotificationModal);
    app.mount(document.createElement('div'));

    const config = formState.config as FormSchemaConfig;
    const recipientField = config.schema[0];

    if (recipientField === undefined) {
      throw new Error('Recipient field is missing.');
    }

    expect(recipientField.component).toBe('ApiSelect');
    expect(recipientField.componentProps.optionFilterProp).toBe('label');
    expect(recipientField.componentProps.showSearch).toBe(true);
    expect(
      (
        recipientField.componentProps.labelFn as (recipient: {
          name: string;
          username: string;
        }) => string
      )({
        name: 'Nguyen Van An',
        username: 'an.nguyen',
      }),
    ).toBe('Nguyen Van An (an.nguyen)');

    app.unmount();
  });
});
