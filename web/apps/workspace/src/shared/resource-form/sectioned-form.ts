import type { VbenFormSchema } from '#/adapter/form';

import { h, markRaw } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { z } from '#/adapter/form';

export type SectionedFormMode = 'create' | 'edit' | (string & {});

type SectionedFormFieldSchema<TContext> =
  | ((context: TContext) => null | VbenFormSchema)
  | VbenFormSchema;

export interface SectionedFormField<
  TMode extends SectionedFormMode = SectionedFormMode,
  TContext = undefined,
> {
  modes: readonly TMode[];
  schema?: SectionedFormFieldSchema<TContext>;
}

export interface SectionedFormSection<
  TSection extends string,
  TMode extends SectionedFormMode = SectionedFormMode,
  TContext = undefined,
> {
  children: readonly SectionedFormField<TMode, TContext>[];
  icon?: string;
  key: TSection;
  title: string;
}

export interface SectionedFormDefaultGroup<
  TMode extends SectionedFormMode = SectionedFormMode,
  TContext = undefined,
> {
  children: readonly SectionedFormField<TMode, TContext>[];
  key?: never;
  title?: never;
}

export type SectionedFormGroup<
  TSection extends string,
  TMode extends SectionedFormMode = SectionedFormMode,
  TContext = undefined,
> =
  | SectionedFormDefaultGroup<TMode, TContext>
  | SectionedFormSection<TSection, TMode, TContext>;

interface BuildSectionedFormSchemaOptions<
  TSection extends string,
  TMode extends SectionedFormMode,
  TContext,
> {
  context?: TContext;
  groups: readonly SectionedFormGroup<TSection, TMode, TContext>[];
  mode: TMode;
}

interface BuildSectionedFormSchemasOptions<
  TSection extends string,
  TMode extends SectionedFormMode,
  TContext,
> {
  context?: TContext;
  groups: readonly SectionedFormGroup<TSection, TMode, TContext>[];
  modes: readonly TMode[];
}

interface PopulatedGroup<TSection extends string> {
  fields: VbenFormSchema[];
  icon?: string;
  key?: TSection;
  title?: string;
}

export function localizedRule<TSchema extends z.ZodTypeAny>(
  schema: TSchema,
  message: string,
) {
  return z.custom<z.input<TSchema>>(
    (value) => schema.safeParse(value).success,
    {
      message,
    },
  );
}

function isSectionedFormSection<
  TSection extends string,
  TMode extends SectionedFormMode,
  TContext,
>(
  group: SectionedFormGroup<TSection, TMode, TContext>,
): group is SectionedFormSection<TSection, TMode, TContext> {
  return group.key !== undefined;
}

function createSectionDivider<TSection extends string>(
  section: SectionedFormSection<TSection>,
): VbenFormSchema {
  return {
    component: 'Divider',
    componentProps: {
      orientation: 'left',
      plain: true,
    },
    fieldName: `__section.${section.key}`,
    formItemClass:
      'col-span-full !pb-0 pt-1 [&_.ant-divider]:!my-2 [&_.ant-divider-inner-text]:!px-0 [&_.ant-divider-inner-text]:text-sm [&_.ant-divider-inner-text]:font-semibold [&_.ant-divider-inner-text]:text-foreground [&_.ant-divider::before]:!border-border [&_.ant-divider::after]:!border-border',
    hideLabel: true,
    renderComponentContent: () => ({
      default: () =>
        h(
          'span',
          { class: 'inline-flex items-center gap-2' },
          section.icon === undefined
            ? section.title
            : [
                h(IconifyIcon, {
                  class: 'size-4 text-muted-foreground',
                  icon: section.icon,
                }),
                h('span', section.title),
              ],
        ),
    }),
    rules: markRaw(z.undefined().optional()),
    valueFormat: () => undefined,
  };
}

function resolveFieldSchema<TContext>(
  field: SectionedFormField<SectionedFormMode, TContext>,
  context: TContext,
): null | VbenFormSchema {
  if (field.schema === undefined) {
    return null;
  }

  if (typeof field.schema === 'function') {
    return field.schema(context);
  }

  return field.schema;
}

export function buildSectionedFormSchema<
  TSection extends string,
  TMode extends SectionedFormMode,
  TContext = undefined,
>({
  context,
  groups,
  mode,
}: BuildSectionedFormSchemaOptions<
  TSection,
  TMode,
  TContext
>): VbenFormSchema[] {
  const populatedGroups: PopulatedGroup<TSection>[] = groups.flatMap(
    (group) => {
      const groupFields = group.children
        .filter((field) => field.modes.includes(mode))
        .map((field) => resolveFieldSchema(field, context as TContext))
        .filter((field): field is VbenFormSchema => field !== null);

      return groupFields.length === 0
        ? []
        : [
            {
              fields: groupFields,
              icon: isSectionedFormSection(group) ? group.icon : undefined,
              key: group.key,
              title: group.title,
            },
          ];
    },
  );

  return populatedGroups.flatMap((group) =>
    group.key === undefined || group.title === undefined
      ? group.fields
      : [
          createSectionDivider({
            children: [],
            icon: group.icon,
            key: group.key,
            title: group.title,
          }),
          ...group.fields,
        ],
  );
}

export function buildSectionedFormSchemas<
  TSection extends string,
  TMode extends SectionedFormMode,
  TContext = undefined,
>({
  context,
  groups,
  modes,
}: BuildSectionedFormSchemasOptions<TSection, TMode, TContext>): Record<
  TMode,
  VbenFormSchema[]
> {
  return Object.fromEntries(
    modes.map((mode) => [
      mode,
      buildSectionedFormSchema({
        context,
        groups,
        mode,
      }),
    ]),
  ) as Record<TMode, VbenFormSchema[]>;
}
