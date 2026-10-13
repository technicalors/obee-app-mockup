import type {
  CreateEquipmentPayload,
  Equipment,
  UpdateEquipmentPayload,
} from '#/api';
import type { SectionedFormGroup } from '#/shared/resource-form';

import { computed, markRaw } from 'vue';

import _ from 'lodash';

import { z } from '#/adapter/form';
import {
  createEquipmentPayloadSchema,
  updateEquipmentPayloadSchema,
} from '#/api/contracts';
import { $t } from '#/locales';
import { buildSectionedFormSchemas } from '#/shared/resource-form';

type EquipmentFormMode = 'create' | 'edit';
type EquipmentFormSection = 'equipment';

type EquipmentFormValues = {
  code: string;
  name: string;
};

const equipmentFormGroups: readonly SectionedFormGroup<
  EquipmentFormSection,
  EquipmentFormMode
>[] = [
  {
    children: [
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          fieldName: 'code',
          label: $t('page.equipment.fields.code'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('page.equipment.validation.codeRequired'))
              .max(36),
          ),
        },
      },
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          fieldName: 'name',
          label: $t('page.equipment.fields.name'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('page.equipment.validation.nameRequired'))
              .max(255),
          ),
        },
      },
    ],
    icon: 'lucide:package',
    key: 'equipment',
    title: $t('page.equipment.sections.equipment'),
  },
];

export function useEquipmentFormSchema() {
  const formSchemas = computed(() =>
    buildSectionedFormSchemas({
      groups: equipmentFormGroups,
      modes: ['create', 'edit'],
    }),
  );

  return {
    createFormSchema: computed(() => formSchemas.value.create),
    editFormSchema: computed(() => formSchemas.value.edit),
  };
}

export function toEquipmentFormValues(
  equipment: Equipment,
): EquipmentFormValues {
  return {
    code: equipment.code,
    name: equipment.name,
  };
}

export function buildEquipmentCreatePayload(
  values: Record<string, unknown>,
): CreateEquipmentPayload {
  return createEquipmentPayloadSchema.parse(_.pick(values, ['code', 'name']));
}

export function buildEquipmentUpdatePayload(
  values: Record<string, unknown>,
): UpdateEquipmentPayload {
  return updateEquipmentPayloadSchema.parse(_.pick(values, ['code', 'name']));
}
