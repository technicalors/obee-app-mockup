import { describe, expect, it } from 'vitest';

import {
  buildPositionCreatePayload,
  buildPositionUpdatePayload,
  toPositionFormValues,
} from './form';

describe('position form payloads', () => {
  it('strips UI-only fields from create and update payloads', () => {
    expect(
      buildPositionCreatePayload({
        __section: undefined,
        description: 'Builds products',
        name: 'Software Engineer',
      }),
    ).toEqual({
      description: 'Builds products',
      name: 'Software Engineer',
    });
    expect(
      buildPositionUpdatePayload({
        description: null,
        name: 'Senior Software Engineer',
      }),
    ).toEqual({
      description: null,
      name: 'Senior Software Engineer',
    });
  });

  it('maps a position response to editable values', () => {
    expect(
      toPositionFormValues({
        created_at: '2026-07-30T00:00:00.000000Z',
        description: null,
        id: 'position-1',
        name: 'Software Engineer',
        updated_at: '2026-07-30T00:00:00.000000Z',
      }),
    ).toEqual({
      description: null,
      name: 'Software Engineer',
    });
  });
});
