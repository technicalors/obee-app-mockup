import { describe, expect, it } from 'vitest';

import employeeRecordsRoutes from './modules/employee-records';
import masterDataRoutes from './modules/master-data';
import schedulesRoutes from './modules/schedules';

describe('workspace navigation routes', () => {
  it('registers schedules as a top-level menu item', () => {
    expect(schedulesRoutes).toHaveLength(1);
    expect(schedulesRoutes[0]?.name).toBe('Schedules');
    expect(schedulesRoutes[0]?.path).toBe('/schedules');
    expect(schedulesRoutes[0]?.children).toBeUndefined();
  });

  it('registers users under the Masterdata menu', () => {
    const masterDataRoute = masterDataRoutes.find(
      (route) => route.name === 'MasterData',
    );
    const usersRoute = masterDataRoute?.children?.find(
      (route) => route.name === 'MasterDataUsers',
    );

    expect(masterDataRoute?.path).toBe('/master-data');
    expect(masterDataRoute?.meta?.title).toBe('page.masterData.routeTitle');
    expect(usersRoute).toBeDefined();
    expect(usersRoute?.path).toBe('users');
  });

  it('registers employee records menu with history, evaluation, and skills sub-navigation items', () => {
    expect(employeeRecordsRoutes).toHaveLength(1);
    const employeeRecordRoute = employeeRecordsRoutes[0];

    expect(employeeRecordRoute?.name).toBe('EmployeeRecord');
    expect(employeeRecordRoute?.path).toBe('/employee-records');
    expect(employeeRecordRoute?.meta?.title).toBe(
      'page.employeeRecord.routeTitle',
    );
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
    expect(historyRoute?.meta?.title).toBe(
      'page.employeeRecord.history.routeTitle',
    );

    expect(historyDetailRoute).toBeDefined();
    expect(historyDetailRoute?.path).toBe('history/:user');
    expect(historyDetailRoute?.meta?.hideInMenu).toBe(true);
    expect(historyDetailRoute?.meta?.title).toBe(
      'page.employeeHistory.pageTitle',
    );

    expect(evaluationRoute).toBeDefined();
    expect(evaluationRoute?.path).toBe('evaluation');
    expect(evaluationRoute?.meta?.title).toBe(
      'page.employeeRecord.evaluation.routeTitle',
    );

    expect(skillsRoute).toBeDefined();
    expect(skillsRoute?.path).toBe('skills');
    expect(skillsRoute?.meta?.title).toBe(
      'page.employeeRecord.skills.routeTitle',
    );
  });
});
