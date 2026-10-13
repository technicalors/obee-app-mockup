import type { NotificationInstance } from 'ant-design-vue/es/notification';

import { notification } from 'ant-design-vue';

import { ApiProblemError } from '#/api';

export function showRequestError(
  error: unknown,
  fallbackMessage: string,
  context: string,
  notificationApi: NotificationInstance = notification,
): void {
  if (error instanceof ApiProblemError) {
    notificationApi.error({
      description: error.problem.detail,
      message: error.problem.title,
    });
    return;
  }

  console.error(context, error);
  notificationApi.error({
    message: fallbackMessage,
  });
}
