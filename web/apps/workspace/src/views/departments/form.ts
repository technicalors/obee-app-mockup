import type {
  CreateDepartmentPayload,
  DepartmentWithRelations,
  UpdateDepartmentPayload,
} from '#/api';
import type { SectionedFormGroup } from '#/shared/resource-form';

import { computed, markRaw } from 'vue';

import _ from 'lodash';

import { z } from '#/adapter/form';
import { companiesResource, departmentOptionsResource } from '#/api';
import {
  createDepartmentPayloadSchema,
  updateDepartmentPayloadSchema,
} from '#/api/contracts';
import { $t } from '#/locales';
import { buildSectionedFormSchemas } from '#/shared/resource-form';

type DepartmentFormMode = 'create' | 'edit';
type DepartmentFormSection = 'department';

type DepartmentFormValues = {
  company_id: null | string;
  name: string;
  parent_id: null | string;
};

const departmentFormGroups: readonly SectionedFormGroup<
  DepartmentFormSection,
  DepartmentFormMode
>[] = [
  {
    children: [
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          fieldName: 'name',
          label: $t('page.departments.fields.name'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('page.departments.validation.nameRequired'))
              .max(255),
          ),
        },
      },
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'ApiSelect',
          componentProps: {
            allowClear: true,
            api: companiesResource.getAll,
            labelField: 'name',
            dropdownStyle: { zIndex: 2200 },
            valueField: 'id',
          },
          defaultValue: null,
          fieldName: 'company_id',
          label: $t('page.departments.fields.company'),
          rules: markRaw(createDepartmentPayloadSchema.shape.company_id),
        },
      },
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'ApiSelect',
          componentProps: {
            allowClear: true,
            api: departmentOptionsResource.getAll,
            labelField: 'name',
            dropdownStyle: { zIndex: 2200 },
            valueField: 'id',
          },
          defaultValue: null,
          fieldName: 'parent_id',
          label: $t('page.departments.fields.parent'),
          rules: markRaw(createDepartmentPayloadSchema.shape.parent_id),
        },
      },
    ],
    icon: 'lucide:building-2',
    key: 'department',
    title: $t('page.departments.sections.department'),
  },
];

export function useDepartmentFormSchema() {
  const formSchemas = computed(() =>
    buildSectionedFormSchemas({
      groups: departmentFormGroups,
      modes: ['create', 'edit'],
    }),
  );

  return {
    createFormSchema: computed(() => formSchemas.value.create),
    editFormSchema: computed(() => formSchemas.value.edit),
  };
}

export function toDepartmentFormValues(
  department: DepartmentWithRelations,
): DepartmentFormValues {
  return {
    company_id: department.company_id,
    name: department.name,
    parent_id: department.parent_id,
  };
}

export function buildDepartmentCreatePayload(
  values: Record<string, unknown>,
): CreateDepartmentPayload {
  return createDepartmentPayloadSchema.parse(
    _.pick(values, ['company_id', 'name', 'parent_id']),
  );
}

export function buildDepartmentUpdatePayload(
  values: Record<string, unknown>,
): UpdateDepartmentPayload {
  return updateDepartmentPayloadSchema.parse(
    _.pick(values, ['company_id', 'name', 'parent_id']),
  );
}
