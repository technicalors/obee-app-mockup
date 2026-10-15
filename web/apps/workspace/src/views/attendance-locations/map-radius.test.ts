import { describe, expect, it } from 'vitest';

import { createCircleGeoJSON, MAX_MAP_RADIUS_METERS } from './map-radius';

describe('attendance location radius on the map', () => {
  it('keeps a closed coverage polygon for ordinary radii', () => {
    const geometry = createCircleGeoJSON(
      [106.699, 10.777],
      MAX_MAP_RADIUS_METERS,
    );
    const ring = geometry.features[0]?.geometry.coordinates[0];
    expect(ring).toHaveLength(65);
    expect(ring?.[0]).toEqual(ring?.at(-1));
    for (const [longitude, latitude] of ring ?? []) {
      expect(longitude).toBeGreaterThanOrEqual(-180);
      expect(longitude).toBeLessThanOrEqual(180);
      expect(latitude).toBeGreaterThanOrEqual(-90);
      expect(latitude).toBeLessThanOrEqual(90);
    }
  });

  it.each([MAX_MAP_RADIUS_METERS + 1, 2_000_000_000])(
    'omits coverage geometry for a radius of %s meters',
    (radius) => {
      expect(createCircleGeoJSON([106.699, 10.777], radius)).toEqual({
        type: 'FeatureCollection',
        features: [],
      });
    },
  );
});
