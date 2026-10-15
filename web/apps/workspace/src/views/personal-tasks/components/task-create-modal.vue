<script setup lang="ts">
import type { Dayjs } from 'dayjs';

import type { TaskFilterType } from '../use-personal-tasks';

import type {
  PersonalTaskList,
  PersonalTaskRecurrence,
} from '#/api/contracts/personal-tasks';

import { markRaw, ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';
import { createIconifyIcon } from '@vben/icons';
import { preferences } from '@vben/preferences';

import dayjs from 'dayjs';

import { useVbenForm, z } from '#/adapter/form';
import {
  PERSONAL_TASK_RECURRENCE_MAX,
  personalTaskRecurrenceFrequencySchema,
  personalTaskRecurrenceSchema,
} from '#/api/contracts/personal-tasks';
import { $t } from '#/locales';

import { getTodayLocalDate } from '../use-personal-tasks';

interface ModalData {
  isStarredFilterActive: boolean;
  lists: PersonalTaskList[];
  saveTask: (payload: {
    dueDate: null | string;
    listId: string;
    notes: null | string;
    recurrence: null | PersonalTaskRecurrence;
    starred: boolean;
    title: string;
  }) => Promise<boolean>;
  selectedListId: TaskFilterType;
}

const repeatSchema = z.enum([
  'daily',
  'weekdays',
  'weekly',
  'monthly',
  'yearly',
  'custom',
]);
const endTypeSchema = z.enum(['never', 'on', 'after']);

const formFieldsSchema = z.object({
  count: z.unknown(),
  due_date: z.string().date().nullish(),
  end_type: z.unknown(),
  frequency: z.unknown(),
  interval: z.unknown(),
  notes: z.string().max(8192).nullish(),
  repeat: repeatSchema.nullish(),
  task_list_id: z.string().uuid(),
  title: z.string().trim().min(1).max(1024),
  until: z.unknown(),
  weekdays: z.unknown(),
});

type FormValues = z.infer<typeof formFieldsSchema>;
type FormFieldValues = Partial<Record<keyof FormValues, unknown>>;

const formValuesSchema = formFieldsSchema.transform((values, context) => {
  if (!values.repeat) return { ...values, recurrence: null };
  if (!values.due_date) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      message: $t('ui.formRules.selectRequired', [
        $t('personalTasks.taskDetail.dueDate'),
      ]),
      path: ['due_date'],
    });
    return z.NEVER;
  }
  if (
    values.repeat === 'custom' &&
    !endTypeSchema.safeParse(values.end_type).success
  ) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      message: $t('ui.formRules.selectRequired', [
        $t('personalTasks.recurrence.ends'),
      ]),
      path: ['end_type'],
    });
    return z.NEVER;
  }

  const recurrence = personalTaskRecurrenceSchema.safeParse(
    buildRecurrence(values),
  );
  if (!recurrence.success) {
    for (const issue of recurrence.error.issues) {
      context.addIssue({ ...issue, path: issue.path.slice(0, 1) });
    }
    return z.NEVER;
  }
  if (
    recurrence.data.until !== null &&
    recurrence.data.until < values.due_date
  ) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      message: $t('personalTasks.recurrence.untilBeforeDueDate'),
      path: ['until'],
    });
    return z.NEVER;
  }
  return {
    ...values,
    recurrence: {
      ...recurrence.data,
      weekdays:
        recurrence.data.weekdays === null
          ? null
          : recurrence.data.weekdays.toSorted(),
    },
  };
});

const StarIcon = createIconifyIcon('lucide:star');
const titleLabel = $t('personalTasks.create.titleLabel');
const intervalLabel = $t('personalTasks.recurrence.repeatEvery');
const weekdaysLabel = $t('personalTasks.recurrence.on');
const countLabel = $t('personalTasks.recurrence.count');
const weekdaysRequiredMessage = $t('personalTasks.recurrence.weekdaysRequired');
const weekdayKeys = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'] as const;
const isStarred = ref(false);
let isSubmitting = false;

const recurrenceCountRule = (label: string) =>
  markRaw(
    z
      .number({ required_error: $t('ui.formRules.required', [label]) })
      .int()
      .min(1)
      .max(PERSONAL_TASK_RECURRENCE_MAX),
  );

// Strips everything but digits as the user types, so decimals and signs never enter the field.
const integerInputProps = {
  max: PERSONAL_TASK_RECURRENCE_MAX,
  min: 1,
  parser: (value: string | undefined) => value?.replaceAll(/\D/g, '') ?? '',
  precision: 0,
};

const isCustomRepeat = (values: FormFieldValues) => values.repeat === 'custom';

const [Form, formApi] = useVbenForm({
  commonConfig: {
    componentProps: {
      class: 'w-full',
    },
  },
  layout: 'vertical',
  schema: [
    {
      component: 'Input',
      componentProps: {
        'data-testid': 'create-task-title',
        maxlength: 1024,
        onPressEnter: handleTitleEnter,
        placeholder: $t('personalTasks.create.titlePlaceholder'),
      },
      fieldName: 'title',
      formItemClass: 'col-span-full',
      label: titleLabel,
      rules: markRaw(
        z
          .string()
          .trim()
          .min(1, $t('ui.formRules.required', [titleLabel]))
          .max(1024),
      ),
    },
    {
      component: 'DatePicker',
      componentProps: {
        'data-testid': 'create-task-date',
        placeholder: $t('personalTasks.taskDetail.dueDatePlaceholder'),
        valueFormat: 'YYYY-MM-DD',
      },
      fieldName: 'due_date',
      label: $t('personalTasks.taskDetail.dueDate'),
      rules: markRaw(formFieldsSchema.shape.due_date),
    },
    {
      component: 'Select',
      componentProps: {
        'data-testid': 'create-task-list',
      },
      fieldName: 'task_list_id',
      label: $t('personalTasks.taskDetail.list'),
      rules: markRaw(formFieldsSchema.shape.task_list_id),
    },
    {
      component: 'Select',
      componentProps: {
        allowClear: true,
        'data-testid': 'create-task-recurrence',
        placeholder: $t('personalTasks.recurrence.none'),
      },
      dependencies: {
        componentProps: (values) => ({
          options: repeatOptions(values.due_date),
        }),
        disabled: (values) => !values.due_date,
        trigger: (values, form) => {
          if (!values.due_date) form.setFieldValue('repeat', undefined);
        },
        triggerFields: ['due_date'],
      },
      fieldName: 'repeat',
      formItemClass: 'col-span-full',
      label: $t('personalTasks.recurrence.label'),
      rules: markRaw(repeatSchema.nullish()),
    },
    {
      component: 'Divider',
      componentProps: {
        orientation: 'left',
        plain: true,
      },
      dependencies: {
        if: isCustomRepeat,
        triggerFields: ['repeat'],
      },
      fieldName: 'custom_divider',
      formItemClass:
        'col-span-full !pb-0 [&_.ant-divider]:!my-1 [&_.ant-divider-inner-text]:!px-0 [&_.ant-divider-inner-text]:text-sm [&_.ant-divider-inner-text]:font-semibold',
      hideLabel: true,
      renderComponentContent: () => ({
        default: () => $t('personalTasks.recurrence.customTitle'),
      }),
    },
    {
      component: 'InputNumber',
      componentProps: {
        'data-testid': 'custom-recurrence-interval',
        ...integerInputProps,
      },
      defaultValue: 1,
      dependencies: {
        if: isCustomRepeat,
        triggerFields: ['repeat'],
      },
      fieldName: 'interval',
      label: intervalLabel,
      rules: recurrenceCountRule(intervalLabel),
    },
    {
      component: 'Select',
      componentProps: {
        'data-testid': 'custom-recurrence-unit',
      },
      defaultValue: 'week',
      dependencies: {
        componentProps: (values) => ({
          options: frequencyOptions(values.interval),
        }),
        if: isCustomRepeat,
        triggerFields: ['repeat', 'interval'],
      },
      fieldName: 'frequency',
      label: $t('personalTasks.recurrence.unit'),
      rules: markRaw(personalTaskRecurrenceFrequencySchema),
    },
    {
      component: 'CheckboxGroup',
      componentProps: {
        'data-testid': 'custom-recurrence-weekdays',
        options: weekdayKeys.map((key, value) => ({
          label: $t(`personalTasks.recurrence.weekdays.${key}`),
          value,
        })),
      },
      dependencies: {
        if: (values) => isCustomRepeat(values) && values.frequency === 'week',
        trigger: (values, form) => {
          if (
            isCustomRepeat(values) &&
            values.due_date &&
            !values.weekdays?.length
          ) {
            form.setFieldValue('weekdays', [dayjs(values.due_date).day()]);
          }
        },
        triggerFields: ['repeat', 'frequency'],
      },
      fieldName: 'weekdays',
      formItemClass: 'col-span-full',
      label: weekdaysLabel,
      rules: markRaw(
        z
          .array(z.number().int().min(0).max(6), {
            required_error: weekdaysRequiredMessage,
          })
          .min(1, weekdaysRequiredMessage)
          .max(7)
          .refine(
            (days) => new Set(days).size === days.length,
            $t('personalTasks.recurrence.weekdaysDistinct'),
          ),
      ),
    },
    {
      component: 'RadioGroup',
      componentProps: {
        'data-testid': 'custom-recurrence-end-type',
        options: [
          { label: $t('personalTasks.recurrence.never'), value: 'never' },
          { label: $t('personalTasks.recurrence.endsOnDate'), value: 'on' },
          { label: $t('personalTasks.recurrence.endsAfter'), value: 'after' },
        ],
      },
      defaultValue: 'never',
      dependencies: {
        if: isCustomRepeat,
        triggerFields: ['repeat'],
      },
      fieldName: 'end_type',
      formItemClass: 'col-span-full',
      label: $t('personalTasks.recurrence.ends'),
      rules: markRaw(endTypeSchema),
    },
    {
      component: 'DatePicker',
      componentProps: {
        'data-testid': 'custom-recurrence-end-date',
        valueFormat: 'YYYY-MM-DD',
      },
      dependencies: {
        componentProps: (values) => ({
          disabledDate: (date: Dayjs) =>
            Boolean(values.due_date) &&
            date.isBefore(dayjs(values.due_date), 'day'),
        }),
        if: (values) => isCustomRepeat(values) && values.end_type === 'on',
        rules: (values) => untilRule(values.due_date),
        triggerFields: ['repeat', 'end_type', 'due_date'],
      },
      fieldName: 'until',
      label: $t('personalTasks.recurrence.endDate'),
    },
    {
      component: 'InputNumber',
      componentProps: {
        'data-testid': 'custom-recurrence-end-after',
        ...integerInputProps,
      },
      defaultValue: 10,
      dependencies: {
        if: (values) => isCustomRepeat(values) && values.end_type === 'after',
        triggerFields: ['repeat', 'end_type'],
      },
      fieldName: 'count',
      label: countLabel,
      rules: recurrenceCountRule(countLabel),
    },
    {
      component: 'Textarea',
      componentProps: {
        'data-testid': 'create-task-notes',
        maxlength: 8192,
        placeholder: $t('personalTasks.create.notesPlaceholder'),
        rows: 4,
      },
      fieldName: 'notes',
      formItemClass: 'col-span-full',
      label: $t('personalTasks.taskDetail.notes'),
    },
  ],
  showDefaultActions: false,
  wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
});

const [Modal, modalApi] = useVbenModal({
  class: 'w-[640px]',
  confirmText: $t('personalTasks.actions.save'),
  draggable: true,
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (!open) return;
    const data = modalApi.getData<ModalData>();
    const selectedList = data.lists.find(
      (list) => list.id === data.selectedListId,
    );
    const targetList =
      selectedList ?? data.lists.find((list) => list.is_default);
    if (targetList === undefined) {
      throw new Error('Default task list is not loaded');
    }
    formApi.updateSchema([
      {
        componentProps: {
          options: data.lists.map((list) => ({
            label: list.title,
            value: list.id,
          })),
        },
        fieldName: 'task_list_id',
      },
    ]);
    isStarred.value = data.isStarredFilterActive;
    await formApi.resetForm();
    await formApi.setValues({
      due_date: getTodayLocalDate(),
      task_list_id: targetList.id,
    });
  },
  title: $t('personalTasks.create.modalTitle'),
});

async function submit(): Promise<void> {
  if (isSubmitting) return;
  isSubmitting = true;

  try {
    const { valid } = await formApi.validate();
    if (!valid) return;

    const parsed = formValuesSchema.safeParse(await formApi.getValues());
    if (!parsed.success) {
      for (const issue of parsed.error.issues) {
        const field = issue.path[0];
        if (typeof field === 'string')
          formApi.form.setFieldError(field, issue.message);
      }
      return;
    }
    const values = parsed.data;
    modalApi.lock();
    try {
      const wasSaved = await modalApi.getData<ModalData>().saveTask({
        dueDate: values.due_date ?? null,
        listId: values.task_list_id,
        notes: values.notes?.trim() || null,
        recurrence: values.recurrence,
        starred: isStarred.value,
        title: values.title,
      });
      if (wasSaved) modalApi.close();
    } finally {
      modalApi.unlock();
    }
  } finally {
    isSubmitting = false;
  }
}

function buildRecurrence(values: FormValues): unknown {
  if (!values.repeat || !values.due_date) return null;
  const preset = { count: null, interval: 1, until: null, weekdays: null };
  const rule = {
    custom: {
      count: values.end_type === 'after' ? values.count : null,
      frequency: values.frequency,
      interval: values.interval,
      until: values.end_type === 'on' ? values.until : null,
      weekdays: values.frequency === 'week' ? values.weekdays : null,
    },
    daily: { ...preset, frequency: 'day' },
    monthly: { ...preset, frequency: 'month' },
    weekdays: { ...preset, frequency: 'week', weekdays: [1, 2, 3, 4, 5] },
    weekly: {
      ...preset,
      frequency: 'week',
      weekdays: [dayjs(values.due_date).day()],
    },
    yearly: { ...preset, frequency: 'year' },
  }[values.repeat];

  return rule;
}

function repeatOptions(dueDate: unknown): {
  label: string;
  value: z.infer<typeof repeatSchema>;
}[] {
  if (typeof dueDate !== 'string' || dueDate === '') return [];
  const date = dayjs(dueDate).toDate();
  const locale = preferences.app.locale;
  const weekday = new Intl.DateTimeFormat(locale, { weekday: 'long' }).format(
    date,
  );
  const monthDayNumber = new Intl.NumberFormat(locale).format(date.getDate());
  const monthAndDay = new Intl.DateTimeFormat(locale, {
    day: 'numeric',
    month: 'long',
  }).format(date);

  return [
    { label: $t('personalTasks.recurrence.daily'), value: 'daily' },
    {
      label: $t('personalTasks.recurrence.weekdaysPreset'),
      value: 'weekdays',
    },
    {
      label: $t('personalTasks.recurrence.weekly', { weekday }),
      value: 'weekly',
    },
    {
      label: $t('personalTasks.recurrence.monthly', { day: monthDayNumber }),
      value: 'monthly',
    },
    {
      label: $t('personalTasks.recurrence.yearly', { date: monthAndDay }),
      value: 'yearly',
    },
    { label: $t('personalTasks.recurrence.custom'), value: 'custom' },
  ];
}

function frequencyOptions(interval: unknown) {
  const plural = interval === 1 ? '' : 'Plural';

  return personalTaskRecurrenceFrequencySchema.options.map((frequency) => ({
    label: $t(`personalTasks.recurrence.units.${frequency}${plural}`),
    value: frequency,
  }));
}

function untilRule(dueDate: unknown) {
  const label = $t('personalTasks.recurrence.endDate');

  return z
    .string({ required_error: $t('ui.formRules.selectRequired', [label]) })
    .date()
    .refine(
      (until) => typeof dueDate !== 'string' || until >= dueDate,
      $t('personalTasks.recurrence.untilBeforeDueDate'),
    );
}

function handleTitleEnter(event: KeyboardEvent): void {
  if (event.isComposing || event.keyCode === 229) return;
  event.preventDefault();
  void submit();
}
</script>

<template>
  <Modal :close-on-click-modal="false">
    <template #title>
      <span class="flex items-center gap-2">
        <button
          type="button"
          class="inline-flex size-8 items-center justify-center rounded-md transition-colors hover:bg-muted"
          :class="
            isStarred
              ? 'text-amber-600 dark:text-amber-400'
              : 'text-muted-foreground'
          "
          :aria-pressed="isStarred"
          :aria-label="
            $t(
              isStarred
                ? 'personalTasks.actions.removeStar'
                : 'personalTasks.actions.star',
            )
          "
          data-testid="create-task-star"
          @click="isStarred = !isStarred"
        >
          <StarIcon class="size-5" :class="{ 'fill-current': isStarred }" />
        </button>
        {{ $t('personalTasks.create.modalTitle') }}
      </span>
    </template>
    <Form class="px-6 pb-1 pt-2" data-testid="task-create-modal" />
  </Modal>
</template>
