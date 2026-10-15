import { describe, expect, it } from 'vitest';

import {
  httpMutationLogIndexQuerySchema,
  httpMutationLogSchema,
} from './http-mutation-log';

const log = {
  action: 'UpdateUserAction',
  app_url: 'https://obee.local',
  code: 'ABC1234',
  code_snippet: null,
  git_sha_1: 'unknown',
  id: '019e2444-4fa6-716d-a1fe-58fd4e9c602d',
  instance_id: null,
  is_error: true,
  logged_at: '2026-05-15T08:30:00.000000Z',
  payload: '{"body":{"title":"Updated"}}',
  requested_by: null,
  requested_by_user: null,
  response: '[json-response]',
  response_status: 422,
  trace: null,
  uri: '/api/users',
};

describe('http mutation-log contract', () => {
  it('accepts nullable diagnostic fields and rejects missing required fields', () => {
    expect(httpMutationLogSchema.parse(log)).toEqual(log);
    expect(() =>
      httpMutationLogSchema.parse({ ...log, response_status: undefined }),
    ).toThrow(/response_status/);
    expect(() =>
      httpMutationLogSchema.parse({ ...log, is_error: 'true' }),
    ).toThrow(/is_error/);
  });

  it('accepts supported filters and rejects invalid codes and time ranges', () => {
    expect(
      httpMutationLogIndexQuerySchema.parse({
        page: 2,
        per_page: 20,
        is_error: 0,
        range: '1h',
      }),
    ).toMatchObject({ is_error: 0, range: '1h' });
    expect(
      httpMutationLogIndexQuerySchema.parse({
        page: 1,
        per_page: 10,
        search: 'X6',
      }),
    ).toMatchObject({ search: 'X6' });
    expect(() =>
      httpMutationLogIndexQuerySchema.parse({
        page: 1,
        per_page: 10,
        code: 'X6',
      }),
    ).toThrow(/code/);
    expect(() =>
      httpMutationLogIndexQuerySchema.parse({
        page: 1,
        per_page: 10,
        range: '1w',
      }),
    ).toThrow(/range/);
  });
});
