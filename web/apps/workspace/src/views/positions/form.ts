import type { VbenFormSchema } from '#/adapter/form';
import type {
  CreatePositionPayload,
  Position,
  UpdatePositionPayload,
} from '#/api';

import { markRaw } from 'vue';

import _ from 'lodash';

import { z } from '#/adapter/form';
import {
  createPositionPayloadSchema,
  updatePositionPayloadSchema,
} from '#/api/contracts';
import { $t } from '#/locales';

export function createPositionFormSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      fieldName: 'name',
      label: $t('page.positions.fields.name'),
      rules: markRaw(
        z
          .string()
          .min(1, $t('page.positions.validation.nameRequired'))
          .max(255),
      ),
    },
    {
      component: 'Textarea',
      componentProps: {
        rows: 4,
      },
      defaultValue: null,
      fieldName: 'description',
      formItemClass: 'md:col-span-2',
      label: $t('page.positions.fields.description'),
      rules: markRaw(z.string().max(65_535).nullable()),
    },
  ];
}

export function buildPositionCreatePayload(
  values: Record<string, unknown>,
): CreatePositionPayload {
  return createPositionPayloadSchema.parse(
    _.pick(values, ['description', 'name']),
  );
}

export function buildPositionUpdatePayload(
  values: Record<string, unknown>,
): UpdatePositionPayload {
  return updatePositionPayloadSchema.parse(
    _.pick(values, ['description', 'name']),
  );
}

export function toPositionFormValues(
  position: Position,
): UpdatePositionPayload {
  return {
    description: position.description,
    name: position.name,
  };
}
