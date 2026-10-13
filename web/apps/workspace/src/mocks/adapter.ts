import type {
  AxiosAdapter,
  AxiosResponse,
  InternalAxiosRequestConfig,
} from '@vben/request';

import { AxiosHeaders } from '@vben/request';

import { paginationQuerySchema } from '#/api/contracts';

import {
  mockAttendanceRange,
  mockAuthUser,
  mockCompany,
  mockDepartments,
  mockEquipments,
  mockLocations,
  mockNotifications,
  mockPermissions,
  mockPositions,
  mockRoles,
  mockSchedules,
  mockUsers,
} from './data';

interface Identifiable {
  id: string;
}

function paginated<T>(items: T[], page: number, perPage: number) {
  const offset = (page - 1) * perPage;
  return {
    items: items.slice(offset, offset + perPage),
    pagination: {
      has_next: offset + perPage < items.length,
      page,
      per_page: perPage,
      total: items.length,
    },
  };
}

function findById<T extends Identifiable>(items: T[], id: string): T {
  const item = items.find((candidate) => candidate.id === id);
  if (item === undefined) {
    throw new Error(`Mock record ${id} was not found.`);
  }
  return item;
}

function success(
  config: InternalAxiosRequestConfig,
  data: unknown,
  status = 200,
): AxiosResponse {
  return {
    config,
    data,
    headers: new AxiosHeaders({ 'content-type': 'application/json' }),
    status,
    statusText: status === 204 ? 'No Content' : 'OK',
  };
}

function collectionResponse(
  config: InternalAxiosRequestConfig,
  items: unknown[],
) {
  const pagination = paginationQuerySchema.safeParse(config.params);
  return pagination.success
    ? paginated(items, pagination.data.page, pagination.data.per_page)
    : items;
}

function resourceId(path: string): string {
  const parts = path.split('/');
  const id = parts.at(-1);
  if (id === undefined || id === '') {
    throw new Error(`Mock resource path has no id: ${path}`);
  }
  return id;
}

function pathSegment(path: string, index: number): string {
  const segment = path.split('/')[index];
  if (segment === undefined || segment === '') {
    throw new Error(`Mock path segment ${index} is required: ${path}`);
  }
  return segment;
}

function resolveMockResponse(
  config: InternalAxiosRequestConfig,
): AxiosResponse {
  const method = config.method?.toUpperCase();
  const path = config.url;
  if (path === undefined) {
    throw new Error('Mock request URL is required.');
  }

  if (path === '/sanctum/csrf-cookie') return success(config, {});
  if (path === '/auth/login' || path === '/auth/user')
    return success(config, mockAuthUser);
  if (path === '/auth/logout') return success(config, {});
  if (path === '/companies') return success(config, [mockCompany]);
  if (path === '/permissions') return success(config, mockPermissions);
  if (path === '/notifications/recipients') return success(config, mockUsers);
  if (path === '/notifications/read-all')
    return success(config, {
      updated: mockNotifications.filter((item) => item.read_at === null).length,
    });
  if (path === '/attendance/context')
    return success(config, {
      assigned_locations: mockLocations,
      ip_address: '127.0.0.1',
      user: { id: mockAuthUser.id, name: mockAuthUser.name },
    });
  if (path === '/attendance/logs/range')
    return success(config, mockAttendanceRange);
  if (path === '/attendance/logs' && method === 'GET')
    return success(config, {
      date: '2026-10-13',
      first_check_in_at: '2026-10-13T08:27:00+07:00',
      last_check_out_at: null,
      logs: [
        {
          attendance_location_id: findById(
            mockLocations,
            '12000000-0000-4000-8000-000000000001',
          ).id,
          checked_at: '2026-10-13T08:27:00+07:00',
          id: '16000000-0000-4000-8000-000000000001',
          ip_address: '127.0.0.1',
          latitude: 10.7743,
          location: findById(
            mockLocations,
            '12000000-0000-4000-8000-000000000001',
          ),
          longitude: 106.7037,
          source: 'web',
          user_id: mockAuthUser.id,
        },
      ],
      total_work_seconds: 22_680,
    });
  if (path === '/attendance/logs' && method === 'POST')
    return success(config, {
      attendance_location_id: findById(
        mockLocations,
        '12000000-0000-4000-8000-000000000001',
      ).id,
      checked_at: '2026-10-13T17:31:00+07:00',
      id: '16000000-0000-4000-8000-000000000002',
      ip_address: '127.0.0.1',
      latitude: 10.7743,
      location: findById(mockLocations, '12000000-0000-4000-8000-000000000001'),
      longitude: 106.7037,
      source: 'web',
      user_id: mockAuthUser.id,
    });
  if (path === '/schedules' && method === 'GET')
    return success(config, mockSchedules);
  if (path === '/schedule-events' && method === 'POST')
    return success(config, {});
  if (path.startsWith('/schedule-events/') && method === 'DELETE')
    return success(config, { message: 'Đã xóa lịch demo.' });
  if (path.startsWith('/schedule-events/') && method === 'PUT')
    return success(config, {});
  if (path.endsWith('/join'))
    return success(config, { message: 'Đã tham gia lịch.' });
  if (path.endsWith('/leave'))
    return success(config, { message: 'Đã rời lịch.' });

  if (path === '/departments')
    return success(config, collectionResponse(config, mockDepartments));
  if (/^\/departments\/[^/]+\/users$/.test(path))
    return success(config, collectionResponse(config, mockUsers));
  if (/^\/departments\/[^/]+$/.test(path))
    return success(config, findById(mockDepartments, resourceId(path)));
  if (path === '/users')
    return success(config, collectionResponse(config, mockUsers));
  if (/^\/users\/[^/]+\/password$/.test(path)) return success(config, {});
  if (/^\/users\/[^/]+\/avatar$/.test(path))
    return success(config, findById(mockUsers, pathSegment(path, 2)));
  if (/^\/users\/[^/]+$/.test(path))
    return success(config, findById(mockUsers, resourceId(path)));
  if (path === '/positions')
    return success(config, collectionResponse(config, mockPositions));
  if (/^\/positions\/[^/]+$/.test(path))
    return success(config, findById(mockPositions, resourceId(path)));
  if (path === '/equipments')
    return success(config, collectionResponse(config, mockEquipments));
  if (/^\/equipments\/[^/]+$/.test(path))
    return success(config, findById(mockEquipments, resourceId(path)));
  if (path === '/roles')
    return success(config, method === 'GET' ? mockRoles : mockRoles[0]);
  if (/^\/roles\/[^/]+$/.test(path))
    return success(config, findById(mockRoles, resourceId(path)));
  if (path === '/attendance-locations')
    return success(config, collectionResponse(config, mockLocations));
  if (/^\/attendance-locations\/[^/]+$/.test(path))
    return success(config, findById(mockLocations, resourceId(path)));
  if (path === '/notifications')
    return success(
      config,
      method === 'GET'
        ? collectionResponse(config, mockNotifications)
        : [mockNotifications[0]],
    );
  if (/^\/notifications\/[^/]+\/read$/.test(path))
    return success(config, {
      ...findById(mockNotifications, pathSegment(path, 2)),
      read_at: '2026-10-13T09:00:00+07:00',
    });
  if (/^\/schedules\/[^/]+$/.test(path))
    return success(config, findById(mockSchedules, resourceId(path)));

  if (method === 'POST' || method === 'PUT') {
    if (path.startsWith('/departments'))
      return success(
        config,
        findById(mockDepartments, 'e0000000-0000-4000-8000-000000000001'),
      );
    if (path.startsWith('/users')) return success(config, mockAuthUser);
    if (path.startsWith('/positions'))
      return success(
        config,
        findById(mockPositions, 'b0000000-0000-4000-8000-000000000001'),
      );
    if (path.startsWith('/equipments'))
      return success(
        config,
        findById(mockEquipments, '11000000-0000-4000-8000-000000000001'),
      );
    if (path.startsWith('/attendance-locations'))
      return success(
        config,
        findById(mockLocations, '12000000-0000-4000-8000-000000000001'),
      );
  }
  if (method === 'DELETE') return success(config, undefined, 204);

  throw new Error(`No mock handler for ${method} ${path}.`);
}

export const mockAdapter: AxiosAdapter = async (config) =>
  resolveMockResponse(config);

export function installMockBrowserServices(): void {
  Object.defineProperty(globalThis.navigator, 'geolocation', {
    configurable: true,
    value: {
      clearWatch: () => undefined,
      getCurrentPosition: (successCallback: PositionCallback) => {
        successCallback({
          coords: {
            accuracy: 15,
            altitude: null,
            altitudeAccuracy: null,
            heading: null,
            latitude: 10.7743,
            longitude: 106.7037,
            speed: null,
            toJSON: () => ({}),
          },
          timestamp: Date.now(),
          toJSON: () => ({}),
        });
      },
      watchPosition: () => 1,
    },
  });
}
