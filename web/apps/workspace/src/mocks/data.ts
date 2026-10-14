import type {
  AttendanceLocation,
  AuthUser,
  Company,
  DepartmentWithRelations,
  Equipment,
  InboxNotification,
  Permission,
  Position,
  Role,
  User,
} from '#/api/contracts';
import type { Schedule } from '#/api/schedules';

const timestamp = '2026-10-13T08:00:00+07:00';

function requiredItem<T>(items: T[], index: number): T {
  const item = items[index];
  if (item === undefined) {
    throw new Error(`Mock item at index ${index} is required.`);
  }
  return item;
}

export const mockCompany: Company = {
  created_at: timestamp,
  id: 'a0000000-0000-4000-8000-000000000001',
  name: 'Ouransoft Vietnam',
  tax_identification_number: '0317654321',
  updated_at: timestamp,
};

export const mockPositions: Position[] = [
  {
    created_at: timestamp,
    description: 'Quản lý định hướng sản phẩm và đội ngũ.',
    id: 'b0000000-0000-4000-8000-000000000001',
    name: 'Product Manager',
    updated_at: timestamp,
  },
  {
    created_at: timestamp,
    description: 'Phát triển giao diện ứng dụng web.',
    id: 'b0000000-0000-4000-8000-000000000002',
    name: 'Frontend Developer',
    updated_at: timestamp,
  },
  {
    created_at: timestamp,
    description: 'Phát triển dịch vụ và hệ thống backend.',
    id: 'b0000000-0000-4000-8000-000000000003',
    name: 'Backend Developer',
    updated_at: timestamp,
  },
  {
    created_at: timestamp,
    description: 'Thiết kế trải nghiệm và giao diện sản phẩm.',
    id: 'b0000000-0000-4000-8000-000000000004',
    name: 'UI/UX Designer',
    updated_at: timestamp,
  },
  {
    created_at: timestamp,
    description: 'Quản trị và phát triển nguồn nhân lực.',
    id: 'b0000000-0000-4000-8000-000000000005',
    name: 'HR Specialist',
    updated_at: timestamp,
  },
];

export const mockPermissions: Permission[] = [
  'users.viewAny',
  'users.create',
  'users.update',
  'users.delete',
  'departments.viewAny',
  'departments.create',
  'departments.update',
  'departments.delete',
  'positions.viewAny',
  'positions.create',
  'positions.update',
  'positions.delete',
  'roles.viewAny',
  'roles.create',
  'roles.update',
  'roles.delete',
  'permissions.viewAny',
  'equipments.viewAny',
  'equipments.create',
  'equipments.update',
  'equipments.delete',
  'attendance-locations.viewAny',
  'attendance-locations.create',
  'attendance-locations.update',
  'attendance-locations.delete',
].map((name, index) => ({
  created_at: timestamp,
  description: `Quyền ${name}`,
  id: `c0000000-0000-4000-8000-${String(index + 1).padStart(12, '0')}`,
  name,
  updated_at: timestamp,
}));

export const mockRoles: Role[] = [
  {
    created_at: timestamp,
    description: 'Toàn quyền quản trị hệ thống.',
    id: 'd0000000-0000-4000-8000-000000000001',
    name: 'admin',
    permissions: mockPermissions,
    updated_at: timestamp,
  },
  {
    created_at: timestamp,
    description: 'Quản lý hoạt động phòng ban.',
    id: 'd0000000-0000-4000-8000-000000000002',
    name: 'manager',
    permissions: mockPermissions.slice(0, 14),
    updated_at: timestamp,
  },
  {
    created_at: timestamp,
    description: 'Nhân viên sử dụng hệ thống.',
    id: 'd0000000-0000-4000-8000-000000000003',
    name: 'employee',
    permissions: mockPermissions.slice(0, 5),
    updated_at: timestamp,
  },
];

const departmentSeed = [
  ['Ban Giám đốc', null],
  ['Phòng Công nghệ', 'e0000000-0000-4000-8000-000000000001'],
  ['Phòng Sản phẩm', 'e0000000-0000-4000-8000-000000000001'],
  ['Phòng Thiết kế', 'e0000000-0000-4000-8000-000000000003'],
  ['Phòng Nhân sự', 'e0000000-0000-4000-8000-000000000001'],
  ['Phòng Kinh doanh', 'e0000000-0000-4000-8000-000000000001'],
] as const;

export const mockDepartments: DepartmentWithRelations[] = departmentSeed.map(
  ([name, parentId], index) => ({
    children: [],
    company: mockCompany,
    company_id: mockCompany.id,
    created_at: timestamp,
    id: `e0000000-0000-4000-8000-${String(index + 1).padStart(12, '0')}`,
    name,
    parent:
      parentId === null
        ? null
        : {
            company_id: mockCompany.id,
            created_at: timestamp,
            id: parentId,
            name: parentId.endsWith('1') ? 'Ban Giám đốc' : 'Phòng Sản phẩm',
            parent_id: null,
            updated_at: timestamp,
          },
    parent_id: parentId,
    updated_at: timestamp,
  }),
);

const userSeed = [
  ['admin', 'Nguyễn Minh Anh', 'admin@obee.vn', 2, 0, 'female'],
  ['quocbao', 'Trần Quốc Bảo', 'quocbao@obee.vn', 1, 1, 'male'],
  ['hoangyen', 'Lê Hoàng Yến', 'hoangyen@obee.vn', 4, 4, 'female'],
  ['giahuy', 'Phạm Gia Huy', 'giahuy@obee.vn', 1, 2, 'male'],
  ['thanhtruc', 'Võ Thanh Trúc', 'thanhtruc@obee.vn', 5, 0, 'female'],
  ['nhatnam', 'Đỗ Nhật Nam', 'nhatnam@obee.vn', 3, 3, 'male'],
  ['khanhlinh', 'Bùi Khánh Linh', 'khanhlinh@obee.vn', 4, 4, 'female'],
  ['duclong', 'Huỳnh Đức Long', 'duclong@obee.vn', 1, 2, 'male'],
] as const;

export const mockUsers: User[] = userSeed.map(
  ([username, name, email, departmentIndex, positionIndex, sex], index) => ({
    avatar: `/avatars/avatar-${index + 1}.svg`,
    company: mockCompany,
    company_id: mockCompany.id,
    created_at: timestamp,
    departments: [requiredItem(mockDepartments, departmentIndex)],
    email,
    email_verified_at: timestamp,
    id: `f0000000-0000-4000-8000-${String(index + 1).padStart(12, '0')}`,
    is_active: true,
    name,
    profile: {
      address: index % 2 === 0 ? 'TP. Hồ Chí Minh' : 'Hà Nội',
      age: 26 + index,
      bank_account_number: `01234567${index}`,
      birthday: `199${index}-0${(index % 8) + 1}-15`,
      citizen_identification_card: `07920${index}00123`,
      code: `OBE-${String(index + 1).padStart(3, '0')}`,
      created_at: timestamp,
      dependent_tax_identification_number: null,
      education_level: 'university',
      employee_type: index > 5 ? 'probation' : 'official',
      health_insurance_card_number: `HI000${index}`,
      joined_at: `202${(index % 5) + 1}-0${(index % 8) + 1}-01`,
      personal_tax_identification_number: `TAX000${index}`,
      phone_number: `09000000${String(index).padStart(2, '0')}`,
      position: requiredItem(mockPositions, positionIndex),
      position_id: requiredItem(mockPositions, positionIndex).id,
      seniority: index + 1,
      sex,
      social_insurance_number: `SI000${index}`,
      starting_date: `202${(index % 5) + 1}-0${(index % 8) + 1}-01`,
      updated_at: timestamp,
    },
    roles: [
      index === 0 ? requiredItem(mockRoles, 0) : requiredItem(mockRoles, 2),
    ],
    supabase_id: null,
    updated_at: timestamp,
    username,
  }),
);

export const mockAuthUser: AuthUser = {
  ...requiredItem(mockUsers, 0),
  permissions: mockPermissions.map((permission) => permission.name),
};

export const mockEquipments: Equipment[] = [
  {
    code: 'ROOM-LOTUS',
    created_at: timestamp,
    id: '11000000-0000-4000-8000-000000000010',
    name: 'Phòng họp Lotus (Tầng 3 - 20 người)',
    updated_at: timestamp,
  },
  {
    code: 'ROOM-ORCHID',
    created_at: timestamp,
    id: '11000000-0000-4000-8000-000000000011',
    name: 'Phòng họp Orchid (Tầng 2 - 10 người)',
    updated_at: timestamp,
  },
  {
    code: 'EQ-PROJECTOR-01',
    created_at: timestamp,
    id: '11000000-0000-4000-8000-000000000012',
    name: 'Máy chiếu Sony 4K Laser',
    updated_at: timestamp,
  },
  {
    code: 'EQ-POLYCOM-01',
    created_at: timestamp,
    id: '11000000-0000-4000-8000-000000000013',
    name: 'Bộ Hội nghị Polycom Group 500',
    updated_at: timestamp,
  },
  {
    code: 'EQ-JABRA-01',
    created_at: timestamp,
    id: '11000000-0000-4000-8000-000000000014',
    name: 'Loa & Micro Jabra Speak 710',
    updated_at: timestamp,
  },
  {
    code: 'OB-MBP-023',
    created_at: timestamp,
    id: '11000000-0000-4000-8000-000000000001',
    name: 'MacBook Pro 14 M3',
    updated_at: timestamp,
  },
  {
    code: 'OB-MON-041',
    created_at: timestamp,
    id: '11000000-0000-4000-8000-000000000002',
    name: 'Dell UltraSharp U2723QE',
    updated_at: timestamp,
  },
  {
    code: 'OB-IP15-008',
    created_at: timestamp,
    id: '11000000-0000-4000-8000-000000000003',
    name: 'iPhone 15 128GB',
    updated_at: timestamp,
  },
  {
    code: 'OB-DELL-017',
    created_at: timestamp,
    id: '11000000-0000-4000-8000-000000000004',
    name: 'Dell Latitude 7440',
    updated_at: timestamp,
  },
];

export const mockLocations: AttendanceLocation[] = [
  {
    created_at: timestamp,
    departments: mockDepartments.slice(0, 3),
    excluded_users: [],
    id: '12000000-0000-4000-8000-000000000001',
    ips: [
      {
        attendance_location_id: '12000000-0000-4000-8000-000000000001',
        created_at: timestamp,
        id: '12100000-0000-4000-8000-000000000001',
        ip_address: '127.0.0.1',
        updated_at: timestamp,
      },
    ],
    is_active: true,
    latitude: 10.7743,
    longitude: 106.7037,
    name: 'Obee HQ - Quận 1',
    radius_meters: 500,
    updated_at: timestamp,
    users: mockUsers.slice(0, 4).map(({ id, name }) => ({ id, name })),
    validation_mode: 'either',
  },
  {
    created_at: timestamp,
    departments: mockDepartments.slice(3),
    excluded_users: [],
    id: '12000000-0000-4000-8000-000000000002',
    ips: [],
    is_active: true,
    latitude: 21.0285,
    longitude: 105.8542,
    name: 'Chi nhánh Hà Nội',
    radius_meters: 300,
    updated_at: timestamp,
    users: mockUsers.slice(4).map(({ id, name }) => ({ id, name })),
    validation_mode: 'location',
  },
];

const notificationMessages = [
  'Lịch đánh giá hiệu suất quý III đã được cập nhật.',
  'Yêu cầu nghỉ phép của bạn đã được phê duyệt.',
  'Hệ thống sẽ bảo trì từ 22:00 đến 23:00 tối nay.',
];

export const mockNotifications: InboxNotification[] = notificationMessages.map(
  (message, index) => ({
    created_at: `2026-10-13T0${8 - index}:00:00+07:00`,
    data: {
      action: { id: `schedule-${index + 1}`, type: 'schedule_event' },
      actor: {
        id: requiredItem(mockUsers, index).id,
        name: requiredItem(mockUsers, index).name,
        username: requiredItem(mockUsers, index).username,
      },
      kind: index === 0 ? 'schedule_event' : 'manual',
      message,
      meta: {},
      subject: { id: `subject-${index + 1}`, type: 'notification' },
      version: 1,
    },
    id: `13000000-0000-4000-8000-${String(index + 1).padStart(12, '0')}`,
    kind: index === 0 ? 'schedule_event' : 'manual',
    read_at: index === 2 ? timestamp : null,
    type:
      index === 0
        ? String.raw`App\Notifications\ScheduleEventNotification`
        : String.raw`App\Notifications\ManualNotification`,
  }),
);

const todayStr = new Date().toISOString().slice(0, 10);

const scheduleSeed = [
  // Events for today (dynamic so timeline and calendar always have today data)
  [
    'Họp Kế hoạch & Chiến lược Sản phẩm',
    `${todayStr}T08:30:00+07:00`,
    `${todayStr}T11:30:00+07:00`,
    'meeting',
  ],
  [
    'Phỏng vấn Ứng viên Senior Frontend',
    `${todayStr}T09:30:00+07:00`,
    `${todayStr}T12:00:00+07:00`,
    'interview',
  ],
  [
    'Hội nghị Khách hàng & Đối tác Doanh nghiệp',
    `${todayStr}T14:00:00+07:00`,
    `${todayStr}T17:30:00+07:00`,
    'seminar',
  ],
  // Fixed demo events in October 2026
  [
    'Họp Sprint Planning',
    '2026-10-13T09:00:00+07:00',
    '2026-10-10T10:00:00+07:00',
    'meeting',
  ],
  [
    'Review giao diện Obee',
    '2026-10-13T14:00:00+07:00',
    '2026-10-13T15:00:00+07:00',
    'meetup',
  ],
  [
    'Workshop nội bộ',
    '2026-10-15T10:00:00+07:00',
    '2026-10-15T11:30:00+07:00',
    'training',
  ],
  [
    'Phỏng vấn Frontend Developer',
    '2026-10-16T14:30:00+07:00',
    '2026-10-16T15:30:00+07:00',
    'interview',
  ],
  [
    'Standup hàng ngày',
    '2026-10-14T08:30:00+07:00',
    '2026-10-14T08:45:00+07:00',
    'meeting',
  ],
  [
    'Hội thảo công nghệ AI',
    '2026-10-14T13:00:00+07:00',
    '2026-10-14T16:00:00+07:00',
    'seminar',
  ],
  [
    'Họp tổng kết quý',
    '2026-10-15T14:00:00+07:00',
    '2026-10-15T16:30:00+07:00',
    'meeting',
  ],
  [
    'Công tác Đà Nẵng',
    '2026-10-12T07:00:00+07:00',
    '2026-10-14T18:00:00+07:00',
    'business_trip',
  ],
  [
    'Nghỉ lễ Quốc khánh',
    '2026-10-17T00:00:00+07:00',
    '2026-10-18T23:59:00+07:00',
    'holiday',
  ],
] as const;

export const mockSchedules: Schedule[] = scheduleSeed.map(
  ([title, start, end, type], index) => {
    const startDate = new Date(start);
    const endDate = new Date(end);
    const isMultiDay =
      startDate.toISOString().slice(0, 10) !==
      endDate.toISOString().slice(0, 10);
    return {
      end,
      event: {
        company_name: mockCompany.name,
        company_phone_number: '02873001234',
        created_at: timestamp,
        created_by: requiredItem(mockUsers, 0).id,
        end_date: end,
        has_reminder: true,
        id: `14000000-0000-4000-8000-${String(index + 1).padStart(12, '0')}`,
        is_general: index === 2,
        note: 'Dữ liệu cố định cho bản demo tương tác.',
        observers: mockUsers.slice(3, 5).map(({ avatar, email, id, name }) => {
          if (email === null) {
            throw new Error(
              `Mock schedule observer ${id} requires an email.`,
            );
          }
          return { avatar, email, id, name };
        }),
        participants: mockUsers
          .slice(0, 3)
          .map(({ avatar, email, id, name }) => {
            if (email === null) {
              throw new Error(
                `Mock schedule participant ${id} requires an email.`,
              );
            }
            return { avatar, email, id, name };
          }),
        equipment_ids:
          index === 0
            ? ['11000000-0000-4000-8000-000000000010', '11000000-0000-4000-8000-000000000012']
            : index === 1
              ? ['11000000-0000-4000-8000-000000000011']
              : index === 2
                ? ['11000000-0000-4000-8000-000000000010', '11000000-0000-4000-8000-000000000013']
                : index === 3
                  ? ['11000000-0000-4000-8000-000000000010', '11000000-0000-4000-8000-000000000012']
                  : index === 4
                    ? ['11000000-0000-4000-8000-000000000011']
                    : [],
        equipments:
          index === 0
            ? [
                {
                  code: 'ROOM-LOTUS',
                  id: '11000000-0000-4000-8000-000000000010',
                  name: 'Phòng họp Lotus (Tầng 3 - 20 người)',
                },
                {
                  code: 'EQ-PROJECTOR-01',
                  id: '11000000-0000-4000-8000-000000000012',
                  name: 'Máy chiếu Sony 4K Laser',
                },
              ]
            : index === 1
              ? [
                  {
                    code: 'ROOM-ORCHID',
                    id: '11000000-0000-4000-8000-000000000011',
                    name: 'Phòng họp Orchid (Tầng 2 - 10 người)',
                  },
                ]
              : index === 2
                ? [
                    {
                      code: 'ROOM-LOTUS',
                      id: '11000000-0000-4000-8000-000000000010',
                      name: 'Phòng họp Lotus (Tầng 3 - 20 người)',
                    },
                    {
                      code: 'EQ-POLYCOM-01',
                      id: '11000000-0000-4000-8000-000000000013',
                      name: 'Bộ Hội nghị Polycom Group 500',
                    },
                  ]
                : index === 3
                  ? [
                      {
                        code: 'ROOM-LOTUS',
                        id: '11000000-0000-4000-8000-000000000010',
                        name: 'Phòng họp Lotus (Tầng 3 - 20 người)',
                      },
                      {
                        code: 'EQ-PROJECTOR-01',
                        id: '11000000-0000-4000-8000-000000000012',
                        name: 'Máy chiếu Sony 4K Laser',
                      },
                    ]
                  : index === 4
                    ? [
                        {
                          code: 'ROOM-ORCHID',
                          id: '11000000-0000-4000-8000-000000000011',
                          name: 'Phòng họp Orchid (Tầng 2 - 10 người)',
                        },
                      ]
                    : [],
        meeting_url:
          index === 0
            ? 'https://meet.google.com/obee-strategy-plan'
            : index === 1
              ? 'https://zoom.us/j/9887766554'
              : index === 2
                ? 'https://teams.microsoft.com/l/meetup-join/obee-partner'
                : index === 3
                  ? 'https://meet.google.com/obee-sprint-plan'
                  : index === 4
                    ? 'https://zoom.us/j/9876543210'
                    : index === 8
                      ? 'https://teams.microsoft.com/l/meetup-join/obee-ai-workshop'
                      : null,
        physical_address:
          index === 0 || index === 2 || index === 3
            ? 'Phòng họp Lotus (Tầng 3 - 20 người)'
            : index === 1 || index === 4
              ? 'Phòng họp Orchid (Tầng 2 - 10 người)'
              : index === 10
                ? 'Chi nhánh Đà Nẵng - 120 Bạch Đằng'
                : 'Phòng họp Lotus',
        privacy: 'public',
        remind_range: 'minute',
        remind_value: 15,
        repeat_end_time: null,
        repeat_pattern: null,
        repeat_start_time: null,
        repeat_type: null,
        schedule_type: isMultiDay ? 'multiple_days' : 'ordinary',
        start_date: start,
        title,
        type,
        updated_at: timestamp,
        updated_by: null,
      },
      event_id: `14000000-0000-4000-8000-${String(index + 1).padStart(12, '0')}`,
      id: `15000000-0000-4000-8000-${String(index + 1).padStart(12, '0')}`,
      one_day: !isMultiDay,
      remind_at: start,
      start,
    };
  },
);

export const mockAttendanceRange = Array.from({ length: 31 }, (_, index) => {
  const day = String(index + 1).padStart(2, '0');
  const isWeekend = [3, 4, 10, 11, 17, 18, 24, 25, 31].includes(index + 1);
  return {
    date: `2026-10-${day}`,
    first_check_in_at: isWeekend
      ? null
      : `2026-10-${day}T08:${index % 4}5:00+07:00`,
    last_check_out_at: isWeekend ? null : `2026-10-${day}T17:30:00+07:00`,
    logs_count: isWeekend ? 0 : 2,
    on_leave: index + 1 === 6,
    total_work_seconds: isWeekend ? 0 : 31_500,
  };
});
