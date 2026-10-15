import type {
  CreateFacilityResourcePayload,
  FacilityResource,
  FacilityResourceType,
  UpdateFacilityResourcePayload,
} from '#/api';
import type { SectionedFormGroup } from '#/shared/resource-form';

import { computed, markRaw } from 'vue';

import _ from 'lodash';

import { z } from '#/adapter/form';
import {
  createFacilityResourcePayloadSchema,
  facilityResourceTypeSchema,
  updateFacilityResourcePayloadSchema,
} from '#/api/contracts';
import { $t } from '#/locales';
import { buildSectionedFormSchemas } from '#/shared/resource-form';

type FacilityResourceFormMode = 'create' | 'edit';

type FacilityResourceFormValues = {
  code: string;
  name: string;
  note: null | string;
  quantity: number;
  type: FacilityResourceType;
};

const facilityResourceFormGroups: readonly SectionedFormGroup<
  never,
  FacilityResourceFormMode
>[] = [
  {
    children: [
      {
        modes: ['create'],
        schema: {
          component: 'Input',
          fieldName: 'code',
          label: $t('facilityResource.fields.code'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('facilityResource.validation.codeRequired'))
              .max(36),
          ),
        },
      },
      {
        modes: ['edit'],
        schema: {
          component: 'Input',
          componentProps: { disabled: true },
          fieldName: 'code',
          label: $t('facilityResource.fields.code'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('facilityResource.validation.codeRequired'))
              .max(36),
          ),
        },
      },
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          fieldName: 'name',
          label: $t('facilityResource.fields.name'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('facilityResource.validation.nameRequired'))
              .max(255),
          ),
        },
      },
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'Select',
          componentProps: {
            options: [
              {
                label: $t('facilityResource.types.room'),
                value: 'room',
              },
              {
                label: $t('facilityResource.types.equipment'),
                value: 'equipment',
              },
            ],
          },
          defaultValue: 'equipment',
          fieldName: 'type',
          label: $t('facilityResource.fields.type'),
          rules: markRaw(facilityResourceTypeSchema),
        },
      },
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'InputNumber',
          componentProps: {
            class: 'w-full',
            max: 2_147_483_647,
            min: 1,
            precision: 0,
          },
          defaultValue: 1,
          dependencies: {
            disabled: (values) => values.type === 'room',
            trigger(values, _actions, controller) {
              if (values.type === 'room' && values.quantity !== 1) {
                return controller.setFieldValue('quantity', 1, false);
              }
            },
            triggerFields: ['type'],
          },
          fieldName: 'quantity',
          label: $t('facilityResource.fields.quantity'),
          rules: markRaw(
            z
              .number({
                message: $t('facilityResource.validation.quantityPositive'),
              })
              .int($t('facilityResource.validation.quantityPositive'))
              .min(1, $t('facilityResource.validation.quantityPositive'))
              .max(
                2_147_483_647,
                $t('facilityResource.validation.quantityMax'),
              ),
          ),
        },
      },
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'Textarea',
          componentProps: {
            class: 'h-[188px] resize-none overflow-y-auto',
            maxlength: 65_535,
          },
          defaultValue: null,
          fieldName: 'note',
          formItemClass: 'md:col-span-2',
          label: $t('facilityResource.fields.note'),
          rules: markRaw(z.string().max(65_535).nullable().optional()),
        },
      },
    ],
  },
];

export function useFacilityResourceFormSchema() {
  const formSchemas = computed(() =>
    buildSectionedFormSchemas({
      groups: facilityResourceFormGroups,
      modes: ['create', 'edit'],
    }),
  );

  return {
    createFormSchema: computed(() => formSchemas.value.create),
    editFormSchema: computed(() => formSchemas.value.edit),
  };
}

export function toFacilityResourceFormValues(
  facilityResource: FacilityResource,
): FacilityResourceFormValues {
  return {
    code: facilityResource.code,
    name: facilityResource.name,
    type: facilityResource.type,
    quantity: facilityResource.quantity,
    note: facilityResource.note,
  };
}

export function buildFacilityResourceCreatePayload(
  values: Record<string, unknown>,
): CreateFacilityResourcePayload {
  const payload = _.pick(values, ['code', 'name', 'type', 'quantity', 'note']);
  return createFacilityResourcePayloadSchema.parse({
    ...payload,
    note: payload.note === '' ? null : payload.note,
  });
}

export function buildFacilityResourceUpdatePayload(
  values: Record<string, unknown>,
): UpdateFacilityResourcePayload {
  const payload = _.pick(values, ['name', 'type', 'quantity', 'note']);
  return updateFacilityResourcePayloadSchema.parse({
    ...payload,
    note: payload.note === '' ? null : payload.note,
  });
}
