import { describe, expect, it } from 'vitest';

import dashboardRoutes from './modules/dashboard';
import employeeRecordsRoutes from './modules/employee-records';
import masterDataRoutes from './modules/master-data';
import systemRoutes from './modules/system';
import timeSetRoutes from './modules/time-set';

describe('workspace navigation routes', () => {
  it('registers overview as the only dashboard menu item', () => {
    const visibleRoutes = dashboardRoutes.filter(
      (route) => route.meta?.hideInMenu !== true,
    );

    expect(visibleRoutes).toHaveLength(1);
    expect(visibleRoutes[0]?.name).toBe('Overview');
    expect(visibleRoutes[0]?.path).toBe('/overview');
    expect(visibleRoutes[0]?.meta?.title).toBe('dashboard.title');
    expect(visibleRoutes[0]?.children).toBeUndefined();
    expect(
      dashboardRoutes.find((route) => route.path === '/analytics')?.redirect,
    ).toBe('/overview');
    expect(
      dashboardRoutes.find((route) => route.path === '/dashboard')?.redirect,
    ).toBe('/overview');
    expect(
      dashboardRoutes.find((route) => route.path === '/workspace')?.redirect,
    ).toBe('/overview');
  });

  it('groups time-related menu items under Time Set', () => {
    expect(timeSetRoutes).toHaveLength(1);
    const timeSetRoute = timeSetRoutes[0];

    expect(timeSetRoute?.name).toBe('TimeSet');
    expect(timeSetRoute?.path).toBe('/time-set');
    expect(timeSetRoute?.meta?.title).toBe('timeSet.routeTitle');
    expect(timeSetRoute?.children).toHaveLength(4);

    const schedulesRoute = timeSetRoute?.children?.find(
      (route) => route.name === 'Schedules',
    );
    const attendanceRoute = timeSetRoute?.children?.find(
      (route) => route.name === 'Attendance',
    );
    const shiftsRoute = timeSetRoute?.children?.find(
      (route) => route.name === 'EmployeeRecordWorkUserShifts',
    );
    const absenceRoute = timeSetRoute?.children?.find(
      (route) => route.name === 'EmployeeRecordAbsenceRequests',
    );

    expect(schedulesRoute?.path).toBe('/schedules');
    expect(schedulesRoute?.meta?.fullPathKey).toBe(false);
    expect(attendanceRoute?.path).toBe('/attendance');
    expect(shiftsRoute?.path).toBe('/employee-records/work-user-shifts');
    expect(shiftsRoute?.meta?.authority).toEqual(['work-user-shifts.viewAny']);
    expect(absenceRoute?.path).toBe('/employee-records/absence-requests');
  });

  it('registers Mutation logs under System with the list permission', () => {
    const systemRoute = systemRoutes[0];
    const logsRoute = systemRoute?.children?.[0];

    expect(systemRoute?.path).toBe('/system');
    expect(systemRoute?.meta?.title).toBe('system.routeTitle');
    expect(logsRoute?.path).toBe('http-mutation-logs');
    expect(logsRoute?.meta?.authority).toEqual(['http-mutation-logs.viewAny']);
  });

  it('registers users under the Masterdata menu', () => {
    const masterDataRoute = masterDataRoutes.find(
      (route) => route.name === 'MasterData',
    );
    const usersRoute = masterDataRoute?.children?.find(
      (route) => route.name === 'MasterDataUsers',
    );

    expect(masterDataRoute?.path).toBe('/master-data');
    expect(masterDataRoute?.meta?.title).toBe('masterData.routeTitle');
    expect(usersRoute).toBeDefined();
    expect(usersRoute?.path).toBe('users');
  });

  it('registers employee records menu with history, shifts, requests, evaluation, and skills', () => {
    expect(employeeRecordsRoutes).toHaveLength(1);
    const employeeRecordRoute = employeeRecordsRoutes[0];

    expect(employeeRecordRoute?.name).toBe('EmployeeRecord');
    expect(employeeRecordRoute?.path).toBe('/employee-records');
    expect(employeeRecordRoute?.meta?.title).toBe('employeeRecord.routeTitle');
    expect(employeeRecordRoute?.children).toHaveLength(4);

    const historyRoute = employeeRecordRoute?.children?.find(
      (route) => route.name === 'EmployeeRecordHistory',
    );
    const historyDetailRoute = employeeRecordRoute?.children?.find(
      (route) => route.name === 'EmployeeRecordHistoryDetail',
    );
    const evaluationRoute = employeeRecordRoute?.children?.find(
      (route) => route.name === 'EmployeeRecordEvaluation',
    );
    const skillsRoute = employeeRecordRoute?.children?.find(
      (route) => route.name === 'EmployeeRecordSkills',
    );

    expect(historyRoute).toBeDefined();
    expect(historyRoute?.path).toBe('history');
    expect(historyRoute?.meta?.title).toBe('employeeRecord.history.routeTitle');

    expect(historyDetailRoute).toBeDefined();
    expect(historyDetailRoute?.path).toBe('history/:user');
    expect(historyDetailRoute?.meta?.hideInMenu).toBe(true);
    expect(historyDetailRoute?.meta?.title).toBe('employeeHistory.pageTitle');

    expect(evaluationRoute).toBeDefined();
    expect(evaluationRoute?.path).toBe('evaluation');
    expect(evaluationRoute?.meta?.title).toBe(
      'employeeRecord.evaluation.routeTitle',
    );

    expect(skillsRoute).toBeDefined();
    expect(skillsRoute?.path).toBe('skills');
    expect(skillsRoute?.meta?.title).toBe('employeeRecord.skills.routeTitle');
  });
});
