import type {
  AxiosAdapter,
  AxiosResponse,
  InternalAxiosRequestConfig,
} from '@vben/request';

import { AxiosHeaders } from '@vben/request';

import { paginationQuerySchema } from '#/api/contracts';

import {
  mockAbsenceRequests,
  mockAttendanceRange,
  mockAuthUser,
  mockFacilityResources,
  mockHttpMutationLogs,
  mockLeaveBalance,
  mockLocations,
  mockNotifications,
  mockOrganizations,
  mockPermissions,
  mockPersonalTaskLists,
  mockPersonalTasks,
  mockPositions,
  mockRoles,
  mockSchedules,
  mockUsers,
  mockUserTree,
  mockWorkShifts,
  mockWorkUserShifts,
} from './data';

interface Identifiable {
  id: string;
}

let personalTasksStore = [...mockPersonalTasks];
let personalTaskListsStore = [...mockPersonalTaskLists];
let absenceRequestsStore = [...mockAbsenceRequests];
let facilityResourcesStore = [...mockFacilityResources];
let organizationsStore = [...mockOrganizations];
let usersStore = [...mockUsers];
let workShiftsStore = [...mockWorkShifts];
let workUserShiftsStore = [...mockWorkUserShifts];
let schedulesStore = [...mockSchedules];

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

  // Auth & Session
  if (path === '/sanctum/csrf-cookie') return success(config, {});
  if (path === '/auth/login' || path === '/auth/user')
    return success(config, mockAuthUser);
  if (path === '/auth/logout') return success(config, {});
  if (path === '/permissions') return success(config, mockPermissions);

  // Notifications
  if (path === '/notifications/recipients') return success(config, usersStore);
  if (path === '/notifications/read-all')
    return success(config, {
      updated: mockNotifications.filter((item) => item.read_at === null).length,
    });
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
      read_at: '2026-10-15T09:00:00+07:00',
    });

  // Attendance
  if (path === '/attendance/context')
    return success(config, {
      assigned_locations: mockLocations,
      has_shift_today: true,
      ip_address: '127.0.0.1',
      shift_end_at: '2026-10-15T17:30:00+07:00',
      shift_start_at: '2026-10-15T08:00:00+07:00',
      user: { id: mockAuthUser.id, name: mockAuthUser.name },
    });
  if (path === '/attendance/logs/range')
    return success(config, mockAttendanceRange);
  if (path === '/attendance/logs' && method === 'GET')
    return success(config, {
      date: '2026-10-15',
      first_check_in_at: '2026-10-15T08:25:00+07:00',
      last_check_out_at: null,
      logs: [
        {
          attendance_location_id: mockLocations[0]!.id,
          checked_at: '2026-10-15T08:25:00+07:00',
          id: '16000000-0000-4000-8000-000000000001',
          ip_address: '127.0.0.1',
          latitude: 10.7743,
          location: mockLocations[0]!,
          longitude: 106.7037,
          source: 'web',
          user_id: mockAuthUser.id,
        },
      ],
      total_work_seconds: 25_200,
    });
  if (path === '/attendance/logs' && method === 'POST')
    return success(config, {
      attendance_location_id: mockLocations[0]!.id,
      checked_at: '2026-10-15T17:31:00+07:00',
      id: '16000000-0000-4000-8000-000000000002',
      ip_address: '127.0.0.1',
      latitude: 10.7743,
      location: mockLocations[0]!,
      longitude: 106.7037,
      source: 'web',
      user_id: mockAuthUser.id,
    });

  // Attendance Locations
  if (path === '/attendance-locations' && method === 'GET')
    return success(config, collectionResponse(config, mockLocations));
  if (path === '/attendance-locations' && method === 'POST') {
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    const newLoc = {
      created_at: new Date().toISOString(),
      deleted_at: null,
      excluded_users: [],
      id: `loc-${Date.now()}`,
      ips: [],
      latitude: payload.latitude ?? 10.7743,
      longitude: payload.longitude ?? 106.7037,
      name: payload.name ?? 'Điểm chấm công mới',
      organizations: [mockOrganizations[0]!],
      radius_meters: payload.radius_meters ?? 150,
      updated_at: new Date().toISOString(),
      users: [],
      validation_mode: payload.validation_mode ?? 'location',
    };
    mockLocations.push(newLoc);
    return success(config, newLoc, 201);
  }
  if (/^\/attendance-locations\/[^/]+$/.test(path)) {
    const id = resourceId(path);
    if (method === 'GET') return success(config, findById(mockLocations, id));
    if (method === 'PUT') return success(config, findById(mockLocations, id));
    if (method === 'DELETE') return success(config, undefined, 204);
  }

  // Schedules
  if (path === '/schedules' && method === 'GET')
    return success(config, schedulesStore);
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
  if (/^\/schedules\/[^/]+$/.test(path))
    return success(config, findById(schedulesStore, resourceId(path)));

  // Organizations
  if (path === '/organizations' && method === 'GET')
    return success(config, collectionResponse(config, organizationsStore));
  if (path === '/organizations' && method === 'POST') {
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    const newOrg = {
      created_at: new Date().toISOString(),
      id: `org-${Date.now()}`,
      name: payload.name ?? 'Phòng ban mới',
      parent_id: payload.parent_id ?? null,
      tax_identification_number: payload.tax_identification_number ?? null,
      type: payload.type ?? 'Phòng ban',
      updated_at: new Date().toISOString(),
    };
    organizationsStore.push(newOrg);
    return success(config, newOrg, 201);
  }
  if (/^\/organizations\/[^/]+\/users$/.test(path))
    return success(config, collectionResponse(config, usersStore));
  if (/^\/organizations\/[^/]+$/.test(path)) {
    const id = resourceId(path);
    if (method === 'GET')
      return success(config, findById(organizationsStore, id));
    if (method === 'PUT') {
      const org = findById(organizationsStore, id);
      const payload =
        typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
      Object.assign(org, payload, { updated_at: new Date().toISOString() });
      return success(config, org);
    }
    if (method === 'DELETE') {
      organizationsStore = organizationsStore.filter((o) => o.id !== id);
      return success(config, undefined, 204);
    }
  }

  // Users
  if (path === '/users/tree') return success(config, mockUserTree);
  if (path === '/users' && method === 'GET')
    return success(config, collectionResponse(config, usersStore));
  if (path === '/users' && method === 'POST') {
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    const org =
      organizationsStore.find((o) => o.id === payload.organization_id) ??
      organizationsStore[0]!;
    const pos = mockPositions[0]!;
    const newUser = {
      avatar: `https://api.dicebear.com/7.x/avataaars/svg?seed=${payload.username}`,
      created_at: new Date().toISOString(),
      deleted_at: null,
      email: payload.email ?? null,
      email_verified_at: new Date().toISOString(),
      id: `user-${Date.now()}`,
      matrix_user_id: `@${payload.username}:obee.local`,
      name: payload.name,
      organization: org,
      organization_id: org.id,
      profile: {
        address: payload.profile?.address ?? '',
        age: 28,
        bank_account_number: '1903123456789',
        birthday: payload.profile?.birthday ?? '1995-01-01',
        citizen_identification_card: '079123456789',
        code: payload.profile?.code ?? `NV${usersStore.length + 1}`,
        created_at: new Date().toISOString(),
        dependent_tax_identification_number: null,
        education_level: 'university' as const,
        employee_type: 'Toàn thời gian',
        health_insurance_card_number: 'DN4791234567',
        joined_at: '2024-01-01',
        personal_tax_identification_number: '8001234567',
        phone_number: payload.profile?.mobile ?? '0901234567',
        position: pos,
        position_id: pos.id,
        seniority: 1,
        sex: payload.profile?.sex ?? 'male',
        social_insurance_number: '7912345678',
        starting_date: '2024-01-01',
        updated_at: new Date().toISOString(),
      },
      roles: [mockRoles[2]!],
      supabase_id: null,
      updated_at: new Date().toISOString(),
      username: payload.username,
    };
    usersStore.push(newUser);
    return success(config, newUser, 201);
  }
  if (/^\/users\/[^/]+\/password$/.test(path)) return success(config, {});
  if (/^\/users\/[^/]+\/restore$/.test(path)) return success(config, {});
  if (/^\/users\/[^/]+\/avatar$/.test(path))
    return success(config, findById(usersStore, pathSegment(path, 2)));
  if (/^\/users\/[^/]+$/.test(path)) {
    const id = resourceId(path);
    if (method === 'GET') return success(config, findById(usersStore, id));
    if (method === 'PUT') {
      const u = findById(usersStore, id);
      const payload =
        typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
      Object.assign(u, payload, { updated_at: new Date().toISOString() });
      return success(config, u);
    }
    if (method === 'DELETE') {
      usersStore = usersStore.filter((u) => u.id !== id);
      return success(config, undefined, 204);
    }
  }

  // Positions & Roles
  if (path === '/positions' && method === 'GET')
    return success(config, collectionResponse(config, mockPositions));
  if (/^\/positions\/[^/]+$/.test(path))
    return success(config, findById(mockPositions, resourceId(path)));
  if (path === '/roles' && method === 'GET') return success(config, mockRoles);
  if (/^\/roles\/[^/]+$/.test(path))
    return success(config, findById(mockRoles, resourceId(path)));

  // Facility Resources
  if (path === '/facility-resources' && method === 'GET')
    return success(config, collectionResponse(config, facilityResourcesStore));
  if (path === '/facility-resources' && method === 'POST') {
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    const newRes = {
      code: payload.code ?? `RES-${Date.now()}`,
      created_at: new Date().toISOString(),
      id: `fac-${Date.now()}`,
      name: payload.name,
      note: payload.note ?? null,
      quantity: payload.quantity ?? 1,
      type: payload.type ?? 'equipment',
      updated_at: new Date().toISOString(),
    };
    facilityResourcesStore.push(newRes);
    return success(config, newRes, 201);
  }
  if (/^\/facility-resources\/[^/]+$/.test(path)) {
    const id = resourceId(path);
    if (method === 'GET')
      return success(config, findById(facilityResourcesStore, id));
    if (method === 'PUT') {
      const res = findById(facilityResourcesStore, id);
      const payload =
        typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
      Object.assign(res, payload, { updated_at: new Date().toISOString() });
      return success(config, res);
    }
    if (method === 'DELETE') {
      facilityResourcesStore = facilityResourcesStore.filter(
        (r) => r.id !== id,
      );
      return success(config, undefined, 204);
    }
  }

  // Personal Tasks
  if (path === '/personal-tasks' && method === 'GET') {
    return success(config, {
      lists: personalTaskListsStore,
      tasks: personalTasksStore,
    });
  }
  if (path === '/personal-tasks/lists' && method === 'POST') {
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    const newList = {
      created_at: new Date().toISOString(),
      id: globalThis.crypto.randomUUID(),
      is_default: false,
      title: payload.title,
      updated_at: new Date().toISOString(),
      user_id: mockAuthUser.id,
    };
    personalTaskListsStore.push(newList);
    return success(config, newList, 201);
  }
  if (/^\/personal-tasks\/lists\/[^/]+$/.test(path)) {
    const id = resourceId(path);
    if (method === 'PATCH') {
      const list = findById(personalTaskListsStore, id);
      const payload =
        typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
      if (payload.title) list.title = payload.title;
      return success(config, list);
    }
    if (method === 'DELETE') {
      personalTaskListsStore = personalTaskListsStore.filter(
        (l) => l.id !== id,
      );
      personalTasksStore = personalTasksStore.filter(
        (t) => t.task_list_id !== id,
      );
      return success(config, undefined, 204);
    }
  }
  if (path === '/personal-tasks/tasks' && method === 'POST') {
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    const taskId = globalThis.crypto.randomUUID();
    const newTask = {
      completed_at:
        payload.status === 'completed' ? new Date().toISOString() : null,
      created_at: new Date().toISOString(),
      deleted_at: null,
      due_date: payload.due_date ?? null,
      extension: {
        created_at: new Date().toISOString(),
        recurrence: payload.recurrence ?? null,
        starred: payload.starred ?? false,
        task_id: taskId,
        updated_at: new Date().toISOString(),
      },
      hidden: false,
      id: taskId,
      notes: payload.notes ?? null,
      parent_id: payload.parent_id ?? null,
      position: personalTasksStore.length,
      status: payload.status ?? 'needsAction',
      task_list_id: payload.task_list_id ?? personalTaskListsStore[0]!.id,
      title: payload.title,
      updated_at: new Date().toISOString(),
      user_id: mockAuthUser.id,
    };
    personalTasksStore.unshift(newTask);
    return success(config, newTask, 201);
  }
  if (/^\/personal-tasks\/tasks\/[^/]+\/move$/.test(path)) {
    const id = pathSegment(path, 3);
    const task = findById(personalTasksStore, id);
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    task.task_list_id = payload.task_list_id;
    return success(config, task);
  }
  if (/^\/personal-tasks\/tasks\/[^/]+$/.test(path)) {
    const id = resourceId(path);
    if (method === 'PATCH') {
      const task = findById(personalTasksStore, id);
      const payload =
        typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
      if (payload.status !== undefined) {
        task.status = payload.status;
        task.completed_at =
          payload.status === 'completed' ? new Date().toISOString() : null;
      }
      if (payload.title !== undefined) task.title = payload.title;
      if (payload.notes !== undefined) task.notes = payload.notes;
      if (payload.due_date !== undefined) task.due_date = payload.due_date;
      if (payload.starred !== undefined && task.extension)
        task.extension.starred = payload.starred;
      task.updated_at = new Date().toISOString();
      return success(config, task);
    }
    if (method === 'DELETE') {
      personalTasksStore = personalTasksStore.filter(
        (t) => t.id !== id && t.parent_id !== id,
      );
      return success(config, undefined, 204);
    }
  }

  // Absence Requests
  if (path === '/absence-requests' && method === 'GET')
    return success(config, collectionResponse(config, absenceRequestsStore));
  if (path === '/absence-requests/reviewer-capability')
    return success(config, true);
  if (path === '/absence-requests/leave-balance')
    return success(config, mockLeaveBalance);
  if (path === '/absence-requests/preview-coverage') {
    return success(config, {
      holiday_days: 0,
      items: [
        {
          date: '2026-10-20',
          days: 1,
          hours: 8,
          note: 'Ca Hành Chính',
          status: 'covered',
          work_shift_id: 'shift-office',
        },
        {
          date: '2026-10-21',
          days: 0.5,
          hours: 4,
          note: 'Ca Hành Chính buổi sáng',
          status: 'covered',
          work_shift_id: 'shift-office',
        },
      ],
      off_days: 0,
      total_days: 1.5,
      working_days: 1.5,
    });
  }
  if (path === '/absence-requests' && method === 'POST') {
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    const reviewer =
      usersStore.find((u) => u.id === payload.reviewer_id) ?? usersStore[0]!;
    const newReq = {
      address: payload.address ?? null,
      approval_note: null,
      approved_at: null,
      created_at: new Date().toISOString(),
      duration_days: 1,
      end_at: payload.end_at,
      id: `absence-${Date.now()}`,
      leave_type: payload.leave_type,
      reason: payload.reason,
      rejected_at: null,
      requested_by: mockAuthUser.id,
      requester: {
        avatar: mockAuthUser.avatar,
        created_at: mockAuthUser.created_at,
        deleted_at: null,
        email: mockAuthUser.email,
        email_verified_at: mockAuthUser.email_verified_at,
        id: mockAuthUser.id,
        matrix_user_id: mockAuthUser.matrix_user_id,
        name: mockAuthUser.name,
        organization_id: mockAuthUser.organization_id,
        supabase_id: null,
        updated_at: mockAuthUser.updated_at,
        username: mockAuthUser.username,
      },
      reviewer: {
        avatar: reviewer.avatar,
        created_at: reviewer.created_at,
        deleted_at: null,
        email: reviewer.email,
        email_verified_at: reviewer.email_verified_at,
        id: reviewer.id,
        matrix_user_id: reviewer.matrix_user_id,
        name: reviewer.name,
        organization_id: reviewer.organization_id,
        supabase_id: null,
        updated_at: reviewer.updated_at,
        username: reviewer.username,
      },
      reviewer_id: reviewer.id,
      root_organization: mockOrganizations[0]!,
      root_organization_id: mockOrganizations[0]!.id,
      start_at: payload.start_at,
      status: 'pending' as const,
      submitted_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      user: {
        avatar: mockAuthUser.avatar,
        created_at: mockAuthUser.created_at,
        deleted_at: null,
        email: mockAuthUser.email,
        email_verified_at: mockAuthUser.email_verified_at,
        id: mockAuthUser.id,
        matrix_user_id: mockAuthUser.matrix_user_id,
        name: mockAuthUser.name,
        organization_id: mockAuthUser.organization_id,
        supabase_id: null,
        updated_at: mockAuthUser.updated_at,
        username: mockAuthUser.username,
      },
      user_id: mockAuthUser.id,
    };
    absenceRequestsStore.unshift(newReq);
    return success(config, newReq, 201);
  }
  if (/^\/absence-requests\/[^/]+\/approve$/.test(path)) {
    const id = pathSegment(path, 2);
    const req = findById(absenceRequestsStore, id);
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    req.status = 'approved';
    req.approved_at = new Date().toISOString();
    req.approval_note = payload?.approval_note ?? 'Đã phê duyệt';
    return success(config, req);
  }
  if (/^\/absence-requests\/[^/]+\/reject$/.test(path)) {
    const id = pathSegment(path, 2);
    const req = findById(absenceRequestsStore, id);
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    req.status = 'rejected';
    req.rejected_at = new Date().toISOString();
    req.approval_note = payload?.approval_note ?? 'Từ chối duyệt';
    return success(config, req);
  }
  if (/^\/absence-requests\/[^/]+\/return$/.test(path)) {
    const id = pathSegment(path, 2);
    const req = findById(absenceRequestsStore, id);
    req.status = 'returned';
    return success(config, req);
  }
  if (/^\/absence-requests\/[^/]+$/.test(path)) {
    const id = resourceId(path);
    if (method === 'GET')
      return success(config, findById(absenceRequestsStore, id));
    if (method === 'DELETE') {
      absenceRequestsStore = absenceRequestsStore.filter((r) => r.id !== id);
      return success(config, undefined, 204);
    }
  }

  // Work Shifts & User Shifts
  if (path === '/work-shifts' && method === 'GET')
    return success(config, workShiftsStore);
  if (path === '/work-shifts' && method === 'POST') {
    const payload =
      typeof config.data === 'string' ? JSON.parse(config.data) : config.data;
    const newShift = {
      created_at: new Date().toISOString(),
      created_by: mockAuthUser.id,
      id: `shift-${Date.now()}`,
      name: payload.name,
      periods: (payload.periods || []).map((p: any, idx: number) => ({
        created_at: new Date().toISOString(),
        end_day_offset: p.end_day_offset ?? 0,
        end_time: p.end_time,
        id: `p-${Date.now()}-${idx}`,
        start_day_offset: p.start_day_offset ?? 0,
        start_time: p.start_time,
        updated_at: new Date().toISOString(),
        work_shift_id: `shift-${Date.now()}`,
      })),
      root_organization_id: mockOrganizations[0]!.id,
      updated_at: new Date().toISOString(),
    };
    workShiftsStore.push(newShift);
    return success(config, newShift, 201);
  }
  if (/^\/work-shifts\/[^/]+$/.test(path)) {
    const id = resourceId(path);
    if (method === 'PUT') return success(config, findById(workShiftsStore, id));
    if (method === 'DELETE') {
      workShiftsStore = workShiftsStore.filter((s) => s.id !== id);
      return success(config, undefined, 204);
    }
  }
  if (path === '/work-user-shifts' && method === 'GET')
    return success(config, workUserShiftsStore);
  if (path === '/work-user-shifts/mine' && method === 'GET')
    return success(
      config,
      workUserShiftsStore.filter((s) => s.user_id === mockAuthUser.id),
    );
  if (path === '/work-user-shifts/range' && method === 'POST') {
    return success(config, workUserShiftsStore.slice(0, 5), 201);
  }
  if (/^\/work-user-shifts\/[^/]+$/.test(path)) {
    const id = resourceId(path);
    if (method === 'PUT')
      return success(config, findById(workUserShiftsStore, id));
    if (method === 'DELETE') {
      workUserShiftsStore = workUserShiftsStore.filter((s) => s.id !== id);
      return success(config, undefined, 204);
    }
  }

  // Http Mutation Logs
  if (path === '/http-mutation-logs' && method === 'GET')
    return success(config, collectionResponse(config, mockHttpMutationLogs));
  if (path === '/http-mutation-logs/suggest') {
    const kind = config.params?.kind;
    if (kind === 'action') {
      return success(config, [
        'PersonalTasks@Store',
        'AbsenceRequests@Approve',
        'AttendanceLocations@Update',
        'WorkUserShifts@AssignRange',
      ]);
    }
    return success(
      config,
      usersStore.slice(0, 5).map((u) => ({
        avatar: u.avatar,
        email: u.email,
        id: u.id,
        name: u.name,
        username: u.username,
      })),
    );
  }
  if (/^\/http-mutation-logs\/[^/]+\/markdown$/.test(path)) {
    return success(config, {
      markdown:
        '### Chi tiết Mutation Log\n- **Hành động:** Demo mutation action\n- **Trạng thái:** Thành công (200 OK)\n- **Thời gian:** Vừa xong',
    });
  }
  if (/^\/http-mutation-logs\/[^/]+$/.test(path))
    return success(config, findById(mockHttpMutationLogs, resourceId(path)));

  // Chat
  if (path === '/chat/matrix-credentials') {
    return success(config, {
      access_token: 'mock-matrix-access-token',
      device_id: 'mock-device-web',
      homeserver_url: 'https://matrix.obee.local',
      user_id: mockAuthUser.matrix_user_id || '@admin:obee.local',
      well_known: {
        'm.homeserver': {
          base_url: 'https://matrix.obee.local',
        },
      },
    });
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
