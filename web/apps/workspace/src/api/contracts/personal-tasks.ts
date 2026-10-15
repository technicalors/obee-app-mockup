import { z } from '@vben/common-ui';

const timestampSchema = z.string().datetime({ offset: true });
export const personalTaskStatusSchema = z.enum(['needsAction', 'completed']);
export const personalTaskRecurrenceFrequencySchema = z.enum([
  'day',
  'week',
  'month',
  'month_weekday',
  'year',
]);
export const PERSONAL_TASK_RECURRENCE_MAX = 999;

/** `count` is the number of occurrences left, including the current task. */
export const personalTaskRecurrenceSchema = z
  .object({
    count: z.number().int().min(1).max(PERSONAL_TASK_RECURRENCE_MAX).nullable(),
    frequency: personalTaskRecurrenceFrequencySchema,
    interval: z.number().int().min(1).max(PERSONAL_TASK_RECURRENCE_MAX),
    until: z.string().date().nullable(),
    weekdays: z.number().int().min(0).max(6).array().min(1).max(7).nullable(),
  })
  .strict()
  .superRefine((rule, context) => {
    if ((rule.frequency === 'week') !== (rule.weekdays !== null)) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Weekdays are required for weekly recurrence only',
        path: ['weekdays'],
      });
    }
    if (rule.weekdays && new Set(rule.weekdays).size !== rule.weekdays.length) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Weekdays must be distinct',
        path: ['weekdays'],
      });
    }
    if (rule.until !== null && rule.count !== null) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'A recurrence ends either on a date or after a count',
        path: ['count'],
      });
    }
  });

export const personalTaskListSchema = z
  .object({
    created_at: timestampSchema,
    id: z.string().uuid(),
    is_default: z.boolean(),
    title: z.string().max(1024),
    updated_at: timestampSchema,
    user_id: z.string().uuid(),
  })
  .strict();

export const personalTaskExtensionSchema = z
  .object({
    created_at: timestampSchema,
    recurrence: personalTaskRecurrenceSchema.nullable(),
    starred: z.boolean(),
    task_id: z.string().uuid(),
    updated_at: timestampSchema,
  })
  .strict();

const personalTaskBaseSchema = z
  .object({
    created_at: timestampSchema,
    deleted_at: z.null(),
    due_date: z.string().date().nullable(),
    extension: personalTaskExtensionSchema,
    hidden: z.boolean(),
    id: z.string().uuid(),
    notes: z.string().max(8192).nullable(),
    parent_id: z.string().uuid().nullable(),
    position: z.number().int().nonnegative(),
    task_list_id: z.string().uuid(),
    title: z.string().max(1024),
    updated_at: timestampSchema,
    user_id: z.string().uuid(),
  })
  .strict();

const openPersonalTaskSchema = personalTaskBaseSchema.extend({
  completed_at: z.null(),
  status: z.literal('needsAction'),
});

const completedPersonalTaskSchema = personalTaskBaseSchema.extend({
  completed_at: timestampSchema,
  status: z.literal('completed'),
});

export const personalTaskSchema = z.discriminatedUnion('status', [
  openPersonalTaskSchema,
  completedPersonalTaskSchema,
]);

export const personalTasksResponseSchema = z
  .object({
    lists: personalTaskListSchema.array(),
    tasks: personalTaskSchema.array(),
  })
  .strict();

export type PersonalTask = z.infer<typeof personalTaskSchema>;
export type CompletedPersonalTask = z.infer<typeof completedPersonalTaskSchema>;
export type PersonalTasksResponse = z.infer<typeof personalTasksResponseSchema>;
export type PersonalTaskExtension = z.infer<typeof personalTaskExtensionSchema>;
export type PersonalTaskList = z.infer<typeof personalTaskListSchema>;
export type PersonalTaskStatus = z.infer<typeof personalTaskStatusSchema>;
export type PersonalTaskRecurrence = z.infer<
  typeof personalTaskRecurrenceSchema
>;
export type PersonalTaskRecurrenceFrequency = z.infer<
  typeof personalTaskRecurrenceFrequencySchema
>;
