import type { PersonalTaskRecurrence } from '#/api/contracts/personal-tasks';

import {
  personalTaskListSchema,
  personalTaskSchema,
  personalTasksResponseSchema,
} from '#/api/contracts/personal-tasks';
import { requestClient } from '#/api/request';

export async function getPersonalTasksApi() {
  const response = await requestClient.get<unknown>('/personal-tasks');
  return personalTasksResponseSchema.parse(response);
}

export async function createTaskListApi(title: string) {
  const response = await requestClient.post<unknown>('/personal-tasks/lists', {
    title,
  });
  return personalTaskListSchema.parse(response);
}

export async function updateTaskListApi(listId: string, title: string) {
  const response = await requestClient.request<unknown>(
    `/personal-tasks/lists/${listId}`,
    { data: { title }, method: 'PATCH' },
  );
  return personalTaskListSchema.parse(response);
}

export async function deleteTaskListApi(listId: string) {
  await requestClient.delete(`/personal-tasks/lists/${listId}`);
}

export async function createPersonalTaskApi(payload: {
  due_date: null | string;
  due_time?: null | string;
  notes: null | string;
  parent_id: null | string;
  recurrence: null | PersonalTaskRecurrence;
  starred: boolean;
  status: 'completed' | 'needsAction';
  task_list_id: string;
  title: string;
}) {
  const response = await requestClient.post<unknown>(
    '/personal-tasks/tasks',
    payload,
  );
  return personalTaskSchema.parse(response);
}

export async function updatePersonalTaskApi(
  taskId: string,
  payload: {
    due_date?: null | string;
    due_time?: null | string;
    notes?: null | string;
    starred?: boolean;
    status?: 'completed' | 'needsAction';
    title?: string;
  },
) {
  const response = await requestClient.request<unknown>(
    `/personal-tasks/tasks/${taskId}`,
    { data: payload, method: 'PATCH' },
  );
  return personalTaskSchema.parse(response);
}

export async function movePersonalTaskApi(
  taskId: string,
  payload: { task_list_id: string },
) {
  const response = await requestClient.post<unknown>(
    `/personal-tasks/tasks/${taskId}/move`,
    payload,
  );
  return personalTaskSchema.parse(response);
}

export async function deletePersonalTaskApi(taskId: string) {
  await requestClient.delete(`/personal-tasks/tasks/${taskId}`);
}
