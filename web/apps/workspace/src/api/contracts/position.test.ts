import { describe, expect, it } from 'vitest';

import {
  createPositionPayloadSchema,
  positionIndexQuerySchema,
  positionSchema,
  updatePositionPayloadSchema,
} from './position';

describe('position contracts', () => {
  it('accepts the position API response shape', () => {
    expect(
      positionSchema.parse({
        created_at: '2026-07-30T00:00:00.000000Z',
        description: null,
        id: 'position-1',
        name: 'Software Engineer',
        updated_at: '2026-07-30T00:00:00.000000Z',
      }),
    ).toMatchObject({
      name: 'Software Engineer',
    });
  });

  it('keeps create and update payloads strict', () => {
    expect(
      createPositionPayloadSchema.parse({
        description: null,
        name: 'Software Engineer',
      }),
    ).toMatchObject({
      name: 'Software Engineer',
    });
    expect(() =>
      updatePositionPayloadSchema.parse({
        company_id: 'company-1',
      }),
    ).toThrow('Unrecognized key');
    expect(() =>
      createPositionPayloadSchema.parse({
        display_name: 'Software Engineer',
        name: 'Software Engineer',
      }),
    ).toThrow('Unrecognized key');
  });

  it('accepts pagination with optional position filters', () => {
    expect(
      positionIndexQuerySchema.parse({
        page: 1,
        per_page: 20,
        search: 'engineer',
      }),
    ).toEqual({
      page: 1,
      per_page: 20,
      search: 'engineer',
    });
  });
});
