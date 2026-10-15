import { describe, expect, it } from 'vitest';

import {
  createAttendanceLocationPayloadSchema,
  updateAttendanceLocationPayloadSchema,
} from './attendance-location';

const payload = {
  name: 'Worldwide',
  latitude: 10.777,
  longitude: 106.699,
  validation_mode: 'location',
};

describe('attendance location radius contract', () => {
  it.each([1, 10_001, 2_000_000_000])(
    'accepts a radius of %s meters',
    (radius) => {
      expect(
        createAttendanceLocationPayloadSchema.parse({
          ...payload,
          radius_meters: radius,
        }).radius_meters,
      ).toBe(radius);
      expect(
        updateAttendanceLocationPayloadSchema.parse({ radius_meters: radius })
          .radius_meters,
      ).toBe(radius);
    },
  );

  it.each([0, -1, 1.5, 2_000_000_001])(
    'rejects a radius of %s meters',
    (radius) => {
      expect(
        createAttendanceLocationPayloadSchema.safeParse({
          ...payload,
          radius_meters: radius,
        }).success,
      ).toBe(false);
      expect(
        updateAttendanceLocationPayloadSchema.safeParse({
          radius_meters: radius,
        }).success,
      ).toBe(false);
    },
  );
});
