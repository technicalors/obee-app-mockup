import { describe, expect, it } from 'vitest';

import { parseProblemPayload, ValidationProblemError } from './problem';
import { resolveRequestBaseURLs } from './request-base-urls';

describe('parseProblemPayload', () => {
  it('returns ApiProblemError for problem json', () => {
    const error = parseProblemPayload({
      detail: 'Authentication is required.',
      status: 401,
      title: 'Unauthenticated',
      type: 'https://obee.local/problems/unauthenticated',
    });

    expect(error.problem.status).toBe(401);
    expect(error.name).toBe('ApiProblemError');
  });

  it('returns ValidationProblemError for validation problem json', () => {
    const error = parseProblemPayload({
      detail: 'The given data was invalid.',
      errors: {
        email: ['The email field is required.'],
      },
      status: 422,
      title: 'Validation failed',
      type: 'https://obee.local/problems/validation-error',
    });

    expect(error).toBeInstanceOf(ValidationProblemError);
    expect((error as ValidationProblemError).problem.errors.email).toEqual([
      'The email field is required.',
    ]);
  });

  it('rejects malformed problem json', () => {
    expect(() =>
      parseProblemPayload({
        detail: 'Authentication is required.',
        status: '401',
        title: 'Unauthenticated',
        type: 'https://obee.local/problems/unauthenticated',
      }),
    ).toThrow(/Expected number/);
  });

  it('requires validation errors for status 422', () => {
    expect(() =>
      parseProblemPayload({
        detail: 'The given data was invalid.',
        status: 422,
        title: 'Validation failed',
        type: 'https://obee.local/problems/validation-error',
      }),
    ).toThrow(/Required/);
  });
});

describe('resolveRequestBaseURLs', () => {
  it('uses vite proxy paths in development', () => {
    expect(resolveRequestBaseURLs('http://obee.local', true)).toEqual({
      apiBaseURL: '/api',
      csrfBaseURL: '',
    });
  });

  it('uses absolute backend urls outside development', () => {
    expect(resolveRequestBaseURLs('http://obee.local', false)).toEqual({
      apiBaseURL: 'http://obee.local/api',
      csrfBaseURL: 'http://obee.local/',
    });
  });

  it('fails fast when backend url is missing', () => {
    expect(() => resolveRequestBaseURLs('', true)).toThrow(
      'VITE_GLOB_BACKEND_URL is required.',
    );
  });
});
