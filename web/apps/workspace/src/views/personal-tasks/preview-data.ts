import {
  personalTaskListSchema,
  personalTaskSchema,
} from '#/api/contracts/personal-tasks';

const userId = '00000000-0000-4000-8000-000000000010';
const obeeListId = '00000000-0000-4000-8000-000000000020';
const otherListId = '00000000-0000-4000-8000-000000000021';
const firstTaskId = '00000000-0000-4000-8000-000000000030';
const secondTaskId = '00000000-0000-4000-8000-000000000031';
const completedTaskId = '00000000-0000-4000-8000-000000000032';
const thirdTaskId = '00000000-0000-4000-8000-000000000033';
const childTaskId = '00000000-0000-4000-8000-000000000034';
const createdAt = '2026-10-01T02:00:00.000000Z';

export const previewLists = personalTaskListSchema.array().parse([
  {
    created_at: createdAt,
    id: obeeListId,
    is_default: true,
    title: 'My Tasks',
    updated_at: createdAt,
    user_id: userId,
  },
  {
    created_at: createdAt,
    id: otherListId,
    is_default: false,
    title: 'Project tasks',
    updated_at: createdAt,
    user_id: userId,
  },
]);

function previewTask(task: {
  completed_at: null | string;
  due_date: null | string;
  id: string;
  notes: null | string;
  parent_id: null | string;
  position: number;
  starred: boolean;
  status: 'completed' | 'needsAction';
  task_list_id: string;
  title: string;
}) {
  const { starred, ...fields } = task;
  return {
    ...fields,
    created_at: createdAt,
    deleted_at: null,
    extension: {
      created_at: createdAt,
      recurrence: null,
      starred,
      task_id: task.id,
      updated_at: createdAt,
    },
    hidden: false,
    updated_at: createdAt,
    user_id: userId,
  };
}

export const previewTasks = personalTaskSchema.array().parse([
  previewTask({
    completed_at: null,
    due_date: '2026-10-02',
    id: firstTaskId,
    notes: 'Chốt nội dung và gửi cho nhóm sản phẩm.',
    parent_id: null,
    position: 0,
    starred: true,
    status: 'needsAction',
    task_list_id: obeeListId,
    title: 'Draft weekly product update',
  }),
  previewTask({
    completed_at: null,
    due_date: '2026-10-03',
    id: secondTaskId,
    notes: 'Kiểm tra luồng tạo tài khoản mới trên mobile và web.',
    parent_id: null,
    position: 0,
    starred: false,
    status: 'needsAction',
    task_list_id: otherListId,
    title: 'Review onboarding flow',
  }),
  previewTask({
    completed_at: '2026-09-30T10:15:00.000000Z',
    due_date: null,
    id: completedTaskId,
    notes: null,
    parent_id: null,
    position: 1,
    starred: false,
    status: 'completed',
    task_list_id: obeeListId,
    title: 'Send design notes',
  }),
  previewTask({
    completed_at: null,
    due_date: '2026-10-06',
    id: thirdTaskId,
    notes: 'Đối chiếu checklist phát hành với nhóm QA.',
    parent_id: null,
    position: 2,
    starred: true,
    status: 'needsAction',
    task_list_id: obeeListId,
    title: 'Prepare release checklist',
  }),
  previewTask({
    completed_at: null,
    due_date: null,
    id: childTaskId,
    notes: null,
    parent_id: firstTaskId,
    position: 0,
    starred: false,
    status: 'needsAction',
    task_list_id: obeeListId,
    title: 'Confirm password reset emails',
  }),
]);
