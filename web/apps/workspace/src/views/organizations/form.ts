import type {
  CreateOrganizationPayload,
  Organization,
  OrganizationType,
  UpdateOrganizationPayload,
} from '#/api';
import type { SectionedFormGroup } from '#/shared/resource-form';

import { computed, markRaw } from 'vue';

import _ from 'lodash';

import { z } from '#/adapter/form';
import { organizationsResource } from '#/api';
import {
  createOrganizationPayloadSchema,
  organizationTypeSchema,
  updateOrganizationPayloadSchema,
} from '#/api/contracts';
import { $t } from '#/locales';
import { buildSectionedFormSchemas } from '#/shared/resource-form';

import { createOrganizationTypeOptions } from './organization-types';

type OrganizationFormMode = 'create' | 'edit';
type OrganizationFormSection = 'organization';

const companyOrganizationType: OrganizationType = 'Công ty';

interface OrganizationFormValues {
  name: string;
  parent_id: null | string;
  tax_identification_number: null | string;
  type: string;
}

const organizationFormGroups: () => readonly SectionedFormGroup<
  OrganizationFormSection,
  OrganizationFormMode
>[] = () => [
  {
    children: [
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          fieldName: 'name',
          label: $t('organizations.fields.name'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('organizations.validation.nameRequired'))
              .max(255),
          ),
        },
      },
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'Select',
          componentProps: {
            dropdownStyle: { zIndex: 2200 },
            options: createOrganizationTypeOptions(),
          },
          dependencies: {
            rules(values) {
              return markRaw(
                organizationTypeSchema.refine(
                  (value) =>
                    values.parent_id === null || values.parent_id === undefined
                      ? value === companyOrganizationType
                      : value !== companyOrganizationType,
                  {
                    message: $t('organizations.validation.typeParentMismatch'),
                  },
                ),
              );
            },
            triggerFields: ['parent_id'],
          },
          fieldName: 'type',
          label: $t('organizations.fields.type'),
        },
      },
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'ApiSelect',
          componentProps: {
            allowClear: true,
            api: organizationsResource.getAllRows,
            dropdownStyle: { zIndex: 2200 },
            labelField: 'name',
            valueField: 'id',
          },
          defaultValue: null,
          dependencies: {
            disabled: (values) => values.type === companyOrganizationType,
            triggerFields: ['type'],
          },
          fieldName: 'parent_id',
          label: $t('organizations.fields.parent'),
          rules: markRaw(z.string().nullish()),
          valueFormat: (value) => z.string().nullish().parse(value) ?? null,
        },
      },
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          componentProps: { maxlength: 14 },
          defaultValue: null,
          fieldName: 'tax_identification_number',
          label: $t('organizations.fields.taxIdentificationNumber'),
          dependencies: {
            show: (values) => values.type === companyOrganizationType,
            rules(values) {
              return markRaw(
                values.type === companyOrganizationType
                  ? z.string().max(14).nullish()
                  : z
                      .null({
                        message: $t('organizations.validation.taxRootOnly'),
                      })
                      .optional(),
              );
            },
            triggerFields: ['type'],
          },
          valueFormat: (value) =>
            value === '' ? null : (z.string().nullish().parse(value) ?? null),
        },
      },
    ],
    icon: 'lucide:building-2',
    key: 'organization',
    title: $t('organizations.sections.organization'),
  },
];

export function useOrganizationFormSchema() {
  const formSchemas = computed(() =>
    buildSectionedFormSchemas({
      groups: organizationFormGroups(),
      modes: ['create', 'edit'],
    }),
  );

  return {
    createFormSchema: computed(() =>
      formSchemas.value.create.filter(
        (field) => field.fieldName !== '__section.organization',
      ),
    ),
    editFormSchema: computed(() => formSchemas.value.edit),
  };
}

export function toOrganizationFormValues(
  organization: Organization,
): OrganizationFormValues {
  return {
    name: organization.name,
    parent_id: organization.parent_id,
    tax_identification_number: organization.tax_identification_number,
    type: organization.type,
  };
}

export function buildOrganizationCreatePayload(
  values: Record<string, unknown>,
): CreateOrganizationPayload {
  const pickedValues = _.pick(values, [
    'name',
    'type',
    'parent_id',
    'tax_identification_number',
  ]);
  return createOrganizationPayloadSchema.parse(pickedValues);
}

export function buildOrganizationUpdatePayload(
  values: Record<string, unknown>,
): UpdateOrganizationPayload {
  const pickedValues = _.pick(values, [
    'name',
    'type',
    'parent_id',
    'tax_identification_number',
  ]);
  return updateOrganizationPayloadSchema.parse(pickedValues);
}
