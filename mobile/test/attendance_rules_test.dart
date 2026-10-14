import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_rules.dart';

void main() {
  test(
    'worldwide radius permits distant GPS while preserving GPS and IP requirements',
    () {
      const location = AttendanceLocation(
        id: 'worldwide',
        name: 'Worldwide',
        latitude: 10.777,
        longitude: 106.699,
        radiusMeters: 2000000000,
        validationMode: 'location',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );
      const coordinates = AttendanceCoordinates(
        latitude: -10.777,
        longitude: -73.301,
      );
      expect(
        evaluateAttendanceEligibility(
          location,
          coordinates,
          '192.0.2.1',
        ).eligible,
        isTrue,
      );
      expect(
        evaluateAttendanceEligibility(location, null, '192.0.2.1').eligible,
        isFalse,
      );
      expect(
        evaluateAttendanceEligibility(
          location.copyWith(validationMode: 'both'),
          coordinates,
          '192.0.2.1',
        ).eligible,
        isFalse,
      );
    },
  );

  for (final mode in ['location', 'ip', 'both', 'either']) {
    for (final gpsMatched in [true, false]) {
      for (final ipMatched in [true, false]) {
        test(
          '$mode evaluates GPS=$gpsMatched, IP=$ipMatched independently',
          () {
            const ip = AttendanceLocationIp(
              id: 'ip-1',
              attendanceLocationId: 'loc-1',
              ipAddress: '14.224.216.180',
              createdAt: '2026-01-01T00:00:00Z',
              updatedAt: '2026-01-01T00:00:00Z',
            );
            final location = AttendanceLocation(
              id: 'loc-1',
              name: 'Office',
              latitude: 20.8605173,
              longitude: 106.6972049,
              radiusMeters: 250,
              validationMode: mode,
              ips: [ip],
              createdAt: '2026-01-01T00:00:00Z',
              updatedAt: '2026-01-01T00:00:00Z',
            );
            final result = evaluateAttendanceEligibility(
              location,
              gpsMatched
                  ? const AttendanceCoordinates(
                      latitude: 20.8605173,
                      longitude: 106.6972049,
                    )
                  : null,
              ipMatched ? '14.224.216.180' : '14.224.216.181',
            );
            final expected = {
              'location': gpsMatched,
              'ip': ipMatched,
              'both': gpsMatched && ipMatched,
              'either': gpsMatched || ipMatched,
            };
            expect(result.eligible, expected[mode]);
            expect(result.locationMatched, gpsMatched);
            expect(result.ipMatched, ipMatched);
          },
        );
      }
    }
  }

  test(
    'distance is in meters and remains finite around the date line and antipodes',
    () {
      const origin = AttendanceCoordinates(latitude: 0, longitude: 0);
      expect(haversineMeters(origin, origin), 0);
      expect(
        haversineMeters(
          origin,
          const AttendanceCoordinates(latitude: 0, longitude: 1),
        ),
        closeTo(111194.926645, 0.001),
      );
      expect(
        haversineMeters(
          const AttendanceCoordinates(latitude: 0, longitude: 179.999),
          const AttendanceCoordinates(latitude: 0, longitude: -179.999),
        ),
        closeTo(222.389853, 0.001),
      );
      expect(
        haversineMeters(
          const AttendanceCoordinates(
            latitude: -51.30327826634217,
            longitude: 20,
          ),
          const AttendanceCoordinates(
            latitude: 51.30327826634217,
            longitude: -160,
          ),
        ).isFinite,
        true,
      );
    },
  );

  test('evaluates location validation mode', () {
    const location = AttendanceLocation(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'loc-1',
      name: 'Office',
      latitude: 10.777,
      longitude: 106.699,
      radiusMeters: 200,
      validationMode: 'location',
      ips: [],
    );

    final eligibility = evaluateAttendanceEligibility(
      location,
      const AttendanceCoordinates(latitude: 10.777, longitude: 106.699),
      '127.0.0.1',
    );

    expect(eligibility.locationMatched, isTrue);
    expect(eligibility.eligible, isTrue);
  });

  test('selects nearest eligible location', () {
    const near = AttendanceLocation(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'near',
      name: 'Near',
      latitude: 10.777,
      longitude: 106.699,
      radiusMeters: 200,
      validationMode: 'location',
    );
    const far = AttendanceLocation(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'far',
      name: 'Far',
      latitude: 11.0,
      longitude: 107.0,
      radiusMeters: 200,
      validationMode: 'location',
    );

    final evaluation = selectBestEvaluation(
      const [far, near],
      const AttendanceCoordinates(latitude: 10.7771, longitude: 106.6991),
      null,
    );

    expect(evaluation?.location.id, 'near');
  });

  test('formats work seconds', () {
    expect(formatWorkSeconds(3661), '1:01');
  });

  test('only allows punch when user is assigned a shift', () {
    expect(
      canPunchAttendance(hasShiftToday: false, locationOrIpEligible: true),
      isFalse,
    );
    expect(
      canPunchAttendance(hasShiftToday: true, locationOrIpEligible: false),
      isFalse,
    );
    expect(
      canPunchAttendance(hasShiftToday: true, locationOrIpEligible: true),
      isTrue,
    );
  });

  test('determines late punch when checked in after shift start', () {
    final shiftStart = DateTime(2026, 10, 5, 8, 0);

    // Checked in at 08:05 -> Late
    expect(
      isAttendanceLate(
        checkInAt: DateTime(2026, 10, 5, 8, 5),
        shiftStartAt: shiftStart,
      ),
      isTrue,
    );

    // Checked in at 08:00 -> On time (not late)
    expect(
      isAttendanceLate(
        checkInAt: DateTime(2026, 10, 5, 8, 0),
        shiftStartAt: shiftStart,
      ),
      isFalse,
    );

    // Checked in at 07:50 -> Early (not late)
    expect(
      isAttendanceLate(
        checkInAt: DateTime(2026, 10, 5, 7, 50),
        shiftStartAt: shiftStart,
      ),
      isFalse,
    );
  });

  test('calculates total work time as last punch minus first punch', () {
    // 0 or 1 log -> 0 seconds
    expect(calculateTotalWorkSeconds(logs: []), 0);
    expect(
      calculateTotalWorkSeconds(
        logs: const [
          AttendanceLog(
            id: '1',
            checkedAt: '2026-10-05T08:00:00Z',
            source: 'mobile',
          ),
        ],
      ),
      0,
    );

    // 2 logs: 08:00 to 17:30 -> 9.5 hours = 34200 seconds
    expect(
      calculateTotalWorkSeconds(
        logs: const [
          AttendanceLog(
            id: '1',
            checkedAt: '2026-10-05T08:00:00Z',
            source: 'mobile',
          ),
          AttendanceLog(
            id: '2',
            checkedAt: '2026-10-05T17:30:00Z',
            source: 'mobile',
          ),
        ],
      ),
      34200,
    );

    // 3 logs: 08:00, 12:00, 17:30 -> last (17:30) minus first (08:00) = 34200 seconds
    expect(
      calculateTotalWorkSeconds(
        logs: const [
          AttendanceLog(
            id: '1',
            checkedAt: '2026-10-05T08:00:00Z',
            source: 'mobile',
          ),
          AttendanceLog(
            id: '2',
            checkedAt: '2026-10-05T12:00:00Z',
            source: 'mobile',
          ),
          AttendanceLog(
            id: '3',
            checkedAt: '2026-10-05T17:30:00Z',
            source: 'mobile',
          ),
        ],
      ),
      34200,
    );
  });

  test('calendarDayAttendanceState recognizes late state', () {
    const onTimeSummary = AttendanceRangeSummary(
      date: '2026-10-05',
      logsCount: 2,
      totalWorkSeconds: 34200,
      isLate: false,
    );
    expect(
      calendarDayAttendanceState(onTimeSummary),
      CalendarDayAttendanceState.checked,
    );

    const lateSummary = AttendanceRangeSummary(
      date: '2026-10-05',
      logsCount: 2,
      totalWorkSeconds: 33000,
      isLate: true,
    );
    expect(
      calendarDayAttendanceState(lateSummary),
      CalendarDayAttendanceState.late,
    );
  });
}
