import type { SectionedFormGroup } from './sectioned-form';

import { describe, expect, it } from 'vitest';

import {
  buildSectionedFormSchema,
  buildSectionedFormSchemas,
} from './sectioned-form';

type TestMode = 'create' | 'edit';
type TestSection = 'account' | 'contact' | 'empty';

const groups: readonly SectionedFormGroup<TestSection, TestMode>[] = [
  {
    children: [
      {
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          fieldName: 'name',
        },
      },
    ],
    key: 'account',
    title: 'Account',
  },
  {
    children: [
      {
        modes: ['edit'],
        schema: {
          component: 'Input',
          fieldName: 'email',
        },
      },
    ],
    key: 'contact',
    title: 'Contact',
  },
  {
    children: [],
    key: 'empty',
    title: 'Empty',
  },
];

describe('buildSectionedFormSchema', () => {
  it('includes section dividers before each non-empty section', () => {
    const schema = buildSectionedFormSchema({
      groups,
      mode: 'edit',
    });

    expect(schema.map((field) => field.fieldName)).toEqual([
      '__section.account',
      'name',
      '__section.contact',
      'email',
    ]);
  });

  it('omits sections without fields for the selected mode', () => {
    const schema = buildSectionedFormSchema({
      groups,
      mode: 'create',
    });

    expect(schema.map((field) => field.fieldName)).toEqual([
      '__section.account',
      'name',
    ]);
  });

  it('filters fields by mode', () => {
    const schema = buildSectionedFormSchema({
      groups,
      mode: 'create',
    });

    expect(schema.some((field) => field.fieldName === 'email')).toBe(false);
  });

  it('uses non-submittable section marker fields', () => {
    const schema = buildSectionedFormSchema({
      groups,
      mode: 'edit',
    });
    const divider = schema[0];

    expect(divider?.fieldName).toBe('__section.account');
    expect(
      divider?.valueFormat?.('visible section title', () => {}, {}),
    ).toBeUndefined();
  });

  it('builds mode schemas from field factories with reusable context', () => {
    const contextualGroups: Array<
      SectionedFormGroup<TestSection, TestMode, { canEdit: boolean }>
    > = [
      {
        children: [
          {
            modes: ['create', 'edit'],
            schema: {
              component: 'Input',
              fieldName: 'name',
            },
          },
        ],
        key: 'account',
        title: 'Account',
      },
      {
        children: [
          {
            modes: ['edit'],
            schema: {
              component: 'Input',
              fieldName: 'email',
            },
          },
        ],
        key: 'contact',
        title: 'Contact',
      },
      {
        children: [
          {
            modes: ['edit'],
            schema: ({ canEdit }) =>
              canEdit
                ? {
                    component: 'Input',
                    fieldName: 'restricted',
                  }
                : null,
          },
        ],
        key: 'empty',
        title: 'Empty',
      },
    ];

    const schemas = buildSectionedFormSchemas({
      context: {
        canEdit: false,
      },
      groups: contextualGroups,
      modes: ['create', 'edit'],
    });

    expect(schemas.create.map((field) => field.fieldName)).toEqual([
      '__section.account',
      'name',
    ]);
    expect(schemas.edit.map((field) => field.fieldName)).toEqual([
      '__section.account',
      'name',
      '__section.contact',
      'email',
    ]);
  });

  it('renders default groups without a divider', () => {
    const schema = buildSectionedFormSchema({
      groups: [
        {
          children: [
            {
              modes: ['create', 'edit'],
              schema: {
                component: 'Input',
                fieldName: 'default_name',
              },
            },
          ],
        },
        ...groups,
      ],
      mode: 'create',
    });

    expect(schema.map((field) => field.fieldName)).toEqual([
      'default_name',
      '__section.account',
      'name',
    ]);
  });
});
