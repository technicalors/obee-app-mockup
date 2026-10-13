import type { InternalAxiosRequestConfig } from '@vben/request';

import { AxiosHeaders } from '@vben/request';

import { describe, expect, it } from 'vitest';

import {
  attendanceContextSchema,
  authUserSchema,
  paginatedListSchema,
  userSchema,
} from '#/api/contracts';

import { mockAdapter } from './adapter';

function requestConfig(
  url: string,
  method: 'GET' | 'POST',
  params?: object,
): InternalAxiosRequestConfig {
  return {
    headers: new AxiosHeaders(),
    method,
    params,
    url,
  };
}

describe('mock request adapter', () => {
  it('returns a contract-valid authenticated administrator', async () => {
    const response = await mockAdapter(requestConfig('/auth/login', 'POST'));

    if (response === undefined) {
      throw new Error('Mock adapter response is required.');
    }

    const user = authUserSchema.parse(response.data);
    expect(user.username).toBe('admin');
    expect(user.permissions).toContain('users.viewAny');
  });

  it('returns contract-valid paginated users', async () => {
    const response = await mockAdapter(
      requestConfig('/users', 'GET', { page: 1, per_page: 10 }),
    );

    if (response === undefined) {
      throw new Error('Mock adapter response is required.');
    }

    const users = paginatedListSchema(userSchema).parse(response.data);
    expect(users.items).toHaveLength(8);
    expect(users.pagination.total).toBe(8);
  });

  it('returns contract-valid attendance context', async () => {
    const response = await mockAdapter(
      requestConfig('/attendance/context', 'GET'),
    );

    if (response === undefined) {
      throw new Error('Mock adapter response is required.');
    }

    const attendance = attendanceContextSchema.parse(response.data);
    expect(attendance.assigned_locations).toHaveLength(2);
  });
});
