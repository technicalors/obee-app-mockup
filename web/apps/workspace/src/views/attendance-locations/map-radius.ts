export const MAX_MAP_RADIUS_METERS = 10_000;

export function createCircleGeoJSON(
  center: [number, number],
  radiusInMeters: number,
  points = 64,
): GeoJSON.FeatureCollection<GeoJSON.Polygon> {
  if (radiusInMeters > MAX_MAP_RADIUS_METERS) {
    return { type: 'FeatureCollection', features: [] };
  }

  const longitude = center[0];
  const latitude = center[1];
  const km = radiusInMeters / 1000;
  const coordinates: GeoJSON.Position[] = [];
  const distanceX = km / (111.32 * Math.cos((latitude * Math.PI) / 180));
  const distanceY = km / 110.574;

  for (let i = 0; i < points; i++) {
    const theta = (i / points) * (2 * Math.PI);
    const x = distanceX * Math.cos(theta);
    const y = distanceY * Math.sin(theta);
    coordinates.push([longitude + x, latitude + y]);
  }

  const firstCoordinate = coordinates[0];
  if (firstCoordinate === undefined) {
    throw new Error('Circle GeoJSON requires at least one coordinate.');
  }
  coordinates.push(firstCoordinate);

  return {
    type: 'FeatureCollection',
    features: [
      {
        type: 'Feature',
        geometry: {
          type: 'Polygon',
          coordinates: [coordinates],
        },
        properties: {},
      },
    ],
  };
}
