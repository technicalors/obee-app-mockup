import { describe, expect, it } from 'vitest';

import { loginPayloadSchema } from './auth';

describe('auth contracts', () => {
  it('accepts either email or username as the login identifier', () => {
    expect(
      loginPayloadSchema.parse({
        email: 'admin',
        password: 'secret123',
      }),
    ).toEqual({
      email: 'admin',
      password: 'secret123',
    });

    expect(
      loginPayloadSchema.parse({
        email: 'admin@example.com',
        password: 'secret123',
      }),
    ).toEqual({
      email: 'admin@example.com',
      password: 'secret123',
    });
  });

  it('rejects empty login credentials', () => {
    expect(() =>
      loginPayloadSchema.parse({
        email: '',
        password: '',
      }),
    ).toThrow('String must contain at least 1 character(s)');
  });
});
