<script setup lang="ts">
import type { MapboxHTMLEvent, MapboxSearchBox } from '@mapbox/search-js-web';

import { computed, onMounted, onUnmounted, ref, watch } from 'vue';

import mapboxgl from 'mapbox-gl';

import { $t } from '#/locales';

import '@mapbox/search-js-web';

import 'mapbox-gl/dist/mapbox-gl.css';

type SearchBoxElement = HTMLElement & MapboxSearchBox;

interface Props {
  latitude: number;
  longitude: number;
  radius?: number;
  disabled?: boolean;
  useCurrentLocationOnMount?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  radius: 100,
  disabled: false,
  useCurrentLocationOnMount: true,
});

const emit = defineEmits<{
  (e: 'change', value: { latitude: number; longitude: number }): void;
}>();

const STANDARD_STYLE = 'mapbox://styles/mapbox/standard';
const SATELLITE_STYLE = 'mapbox://styles/mapbox/standard-satellite';

const mapboxAccessToken = computed(() => {
  const value = import.meta.env.VITE_MAPBOX_ACCESS_TOKEN;
  return typeof value === 'string' && value !== '' ? value : null;
});

const mapContainer = ref<HTMLDivElement | null>(null);
const mapInstance = ref<mapboxgl.Map | null>(null);
const markerInstance = ref<mapboxgl.Marker | null>(null);
const searchBoxContainer = ref<HTMLDivElement | null>(null);
const searchBoxElement = ref<null | SearchBoxElement>(null);
const mapUnavailable = ref(false);

class MoveMarkerToCenterControl implements mapboxgl.IControl {
  private container: HTMLDivElement | null = null;

  constructor(private readonly onMoveMarkerToCenter: () => void) {}

  public onAdd(): HTMLElement {
    const container = document.createElement('div');
    container.className =
      'mapboxgl-ctrl mapboxgl-ctrl-group obee-map-control-group';

    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'obee-map-control-button';
    button.setAttribute(
      'aria-label',
      $t('page.attendanceLocations.actions.locateCurrent'),
    );
    button.setAttribute(
      'title',
      $t('page.attendanceLocations.actions.locateCurrent'),
    );
    button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="obee-map-control-icon"><circle cx="12" cy="12" r="10"/><line x1="22" x2="18" y1="12" y2="12"/><line x1="6" x2="2" y1="12" y2="12"/><line x1="12" x2="12" y1="6" y2="2"/><line x1="12" x2="12" y1="22" y2="18"/></svg>`;
    button.addEventListener('click', this.onMoveMarkerToCenter);

    container.append(button);
    this.container = container;
    return container;
  }

  public onRemove(): void {
    this.container?.remove();
    this.container = null;
  }
}

class StyleToggleControl implements mapboxgl.IControl {
  private button: HTMLButtonElement | null = null;
  private container: HTMLDivElement | null = null;

  constructor(
    private readonly getLabel: () => string,
    private readonly onToggleStyle: () => void,
  ) {}

  public onAdd(): HTMLElement {
    const container = document.createElement('div');
    container.className =
      'mapboxgl-ctrl mapboxgl-ctrl-group obee-map-control-group';

    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'obee-map-control-button';
    const label = this.getLabel();
    button.setAttribute('aria-label', label);
    button.setAttribute('title', label);
    button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="obee-map-control-icon"><path d="m12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.91a1 1 0 0 0 0-1.83Z"/><path d="m22 12.5-9.17 4.18a2 2 0 0 1-1.66 0L2 12.5"/><path d="m22 17.5-9.17 4.18a2 2 0 0 1-1.66 0L2 17.5"/></svg>`;

    button.addEventListener('click', () => {
      this.onToggleStyle();
      this.updateLabel();
    });

    container.append(button);
    this.container = container;
    this.button = button;
    return container;
  }

  public onRemove(): void {
    this.container?.remove();
    this.container = null;
    this.button = null;
  }

  private updateLabel(): void {
    if (this.button) {
      const label = this.getLabel();
      this.button.setAttribute('aria-label', label);
      this.button.setAttribute('title', label);
    }
  }
}

function createCircleGeoJSON(
  center: [number, number],
  radiusInMeters: number,
  points = 64,
): GeoJSON.FeatureCollection<GeoJSON.Polygon> {
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

const CURRENT_LOCATION_OPTIONS: PositionOptions = {
  enableHighAccuracy: true,
  timeout: 15_000,
  maximumAge: 30_000,
};

interface GeolocateResult {
  coords: {
    latitude: number;
    longitude: number;
  };
}

function requestCurrentLocation(
  onPosition: (position: { latitude: number; longitude: number }) => void,
): void {
  if (typeof navigator === 'undefined' || !navigator.geolocation) {
    return;
  }
  navigator.geolocation.getCurrentPosition(
    (currentPosition) => {
      onPosition({
        latitude: currentPosition.coords.latitude,
        longitude: currentPosition.coords.longitude,
      });
    },
    () => undefined,
    CURRENT_LOCATION_OPTIONS,
  );
}

const currentStyle = ref(STANDARD_STYLE);

function updatePosition(position: { latitude: number; longitude: number }) {
  emit('change', position);
}

function handleSearchRetrieve(
  event: MapboxHTMLEvent<{
    features: Array<GeoJSON.Feature<GeoJSON.Point>>;
  }>,
): void {
  const feature = event.detail.features[0];
  if (feature === undefined) {
    return;
  }

  const longitude = feature.geometry.coordinates[0];
  const latitude = feature.geometry.coordinates[1];
  if (longitude === undefined || latitude === undefined) {
    return;
  }

  updatePosition({ latitude, longitude });
  markerInstance.value?.setLngLat([longitude, latitude]);
  mapInstance.value?.flyTo({ center: [longitude, latitude], zoom: 17 });
}

function handleSearchRetrieveEvent(event: Event): void {
  handleSearchRetrieve(
    event as MapboxHTMLEvent<{
      features: Array<GeoJSON.Feature<GeoJSON.Point>>;
    }>,
  );
}

function configureSearchBox(): void {
  if (searchBoxElement.value === null || mapboxAccessToken.value === null) {
    return;
  }

  searchBoxElement.value.accessToken = mapboxAccessToken.value;
  searchBoxElement.value.options = {
    country: 'vn',
    language: 'vi',
    limit: 5,
    proximity: [props.longitude, props.latitude],
    types: 'address,poi',
  };
  searchBoxElement.value.componentOptions = {
    allowReverse: true,
    flipCoordinates: true,
    flyTo: false,
  };
  searchBoxElement.value.marker = false;
  searchBoxElement.value.placeholder = $t(
    'page.attendanceLocations.placeholders.mapSearch',
  );
}

onMounted(() => {
  if (
    !mapboxAccessToken.value ||
    !mapContainer.value ||
    !searchBoxContainer.value
  ) {
    return;
  }

  mapboxgl.accessToken = mapboxAccessToken.value;

  const searchBox = document.createElement(
    'mapbox-search-box',
  ) as SearchBoxElement;
  searchBox.className = 'search-box';
  searchBox.addEventListener('retrieve', handleSearchRetrieveEvent);
  searchBoxContainer.value.append(searchBox);
  searchBoxElement.value = searchBox;

  try {
    Object.defineProperty(mapboxgl.config, 'EVENTS_URL', {
      configurable: true,
      enumerable: true,
      value: null,
    });
  } catch {
    // Some Mapbox builds expose config through non-writable descriptors.
  }

  try {
    const map = new mapboxgl.Map({
      container: mapContainer.value,
      style: currentStyle.value,
      center: [props.longitude, props.latitude],
      zoom: 15,
      localIdeographFontFamily: "'Noto Sans', sans-serif",
      performanceMetricsCollection: false,
    });

    mapInstance.value = map;
    configureSearchBox();

    map.addControl(new mapboxgl.NavigationControl(), 'top-right');
    map.addControl(new mapboxgl.FullscreenControl(), 'top-right');

    const geolocate = new mapboxgl.GeolocateControl({
      positionOptions: { enableHighAccuracy: true },
      trackUserLocation: true,
      showAccuracyCircle: false,
      showUserLocation: false,
      showUserHeading: true,
    });
    geolocate.on('geolocate', (event: GeolocateResult) => {
      const position = {
        latitude: event.coords.latitude,
        longitude: event.coords.longitude,
      };
      updatePosition(position);
      markerInstance.value?.setLngLat([position.longitude, position.latitude]);
    });
    map.addControl(geolocate, 'top-right');

    const moveMarker = new MoveMarkerToCenterControl(() => {
      const center = map.getCenter();
      const position = { latitude: center.lat, longitude: center.lng };
      updatePosition(position);
      markerInstance.value?.setLngLat([position.longitude, position.latitude]);
    });
    map.addControl(moveMarker, 'top-right');

    const styleToggle = new StyleToggleControl(
      () =>
        currentStyle.value === STANDARD_STYLE
          ? $t('page.attendanceLocations.actions.switchToSatellite')
          : $t('page.attendanceLocations.actions.switchToStandard'),
      () => {
        const nextStyle =
          currentStyle.value === STANDARD_STYLE
            ? SATELLITE_STYLE
            : STANDARD_STYLE;
        currentStyle.value = nextStyle;
        map.setStyle(nextStyle);
      },
    );
    map.addControl(styleToggle, 'top-right');

    const markerEl = document.createElement('div');
    markerEl.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" class="size-8 fill-primary text-primary" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: hsl(var(--primary)); fill: hsl(var(--primary));"><path d="M20 10c0 4.993-5.539 10.193-7.399 11.799a1 1 0 0 1-1.202 0C9.539 20.193 4 14.993 4 10a8 8 0 0 1 16 0"/><circle cx="12" cy="10" r="3" fill="white"/></svg>`;

    const marker = new mapboxgl.Marker({
      element: markerEl,
      anchor: 'bottom',
      draggable: !props.disabled,
    })
      .setLngLat([props.longitude, props.latitude])
      .addTo(map);

    markerInstance.value = marker;

    marker.on('dragend', () => {
      const lngLat = marker.getLngLat();
      updatePosition({ latitude: lngLat.lat, longitude: lngLat.lng });
    });

    map.on('style.load', () => {
      map.addSource('circle-source', {
        type: 'geojson',
        data: createCircleGeoJSON(
          [props.longitude, props.latitude],
          props.radius,
        ),
      });

      map.addLayer({
        id: 'circle-layer',
        type: 'fill',
        source: 'circle-source',
        paint: {
          'fill-color': '#1890ff',
          'fill-opacity': 0.15,
        },
      });

      map.addLayer({
        id: 'circle-outline-layer',
        type: 'line',
        source: 'circle-source',
        paint: {
          'line-color': '#1890ff',
          'line-width': 2,
        },
      });
    });

    if (!props.disabled) {
      map.on('click', (e) => {
        const position = { latitude: e.lngLat.lat, longitude: e.lngLat.lng };
        updatePosition(position);
        marker.setLngLat([position.longitude, position.latitude]);
      });
    }

    if (props.useCurrentLocationOnMount && !props.disabled) {
      requestCurrentLocation((pos) => {
        updatePosition(pos);
        marker.setLngLat([pos.longitude, pos.latitude]);
        map.setCenter([pos.longitude, pos.latitude]);
      });
    }
  } catch (error) {
    console.error('Failed to initialize mapbox-gl map:', error);
    mapUnavailable.value = true;
  }
});

onUnmounted(() => {
  searchBoxElement.value?.removeEventListener(
    'retrieve',
    handleSearchRetrieveEvent,
  );
  searchBoxElement.value?.remove();
  searchBoxElement.value = null;

  if (mapInstance.value) {
    mapInstance.value.remove();
    mapInstance.value = null;
  }
  markerInstance.value = null;
});

watch(
  () => [props.latitude, props.longitude],
  () => {
    if (searchBoxElement.value) {
      searchBoxElement.value.options = {
        ...searchBoxElement.value.options,
        proximity: [props.longitude, props.latitude],
      };
    }

    if (markerInstance.value) {
      markerInstance.value.setLngLat([props.longitude, props.latitude]);
    }
    if (mapInstance.value && mapInstance.value.isStyleLoaded()) {
      const source = mapInstance.value.getSource(
        'circle-source',
      ) as mapboxgl.GeoJSONSource;
      if (source) {
        source.setData(
          createCircleGeoJSON([props.longitude, props.latitude], props.radius),
        );
      }
    }
  },
);

watch(
  () => props.radius,
  (newRadius) => {
    if (mapInstance.value && mapInstance.value.isStyleLoaded()) {
      const source = mapInstance.value.getSource(
        'circle-source',
      ) as mapboxgl.GeoJSONSource;
      if (source) {
        source.setData(
          createCircleGeoJSON([props.longitude, props.latitude], newRadius),
        );
      }
    }
  },
);
</script>

<template>
  <div
    v-if="!mapboxAccessToken"
    class="flex min-h-56 items-center justify-center rounded-md border border-dashed bg-muted/30 p-6 text-center text-sm text-muted-foreground"
  >
    {{ $t('page.attendanceLocations.messages.mapboxKeyMissing') }}
  </div>
  <div
    v-else-if="mapUnavailable"
    class="flex min-h-56 items-center justify-center rounded-md border border-dashed bg-muted/30 p-6 text-center text-sm text-muted-foreground"
  >
    {{ $t('page.attendanceLocations.messages.mapboxUnavailable') }}
  </div>
  <div v-else class="relative overflow-hidden rounded-md border border-border">
    <!-- Map Container -->
    <div ref="mapContainer" class="h-[420px] w-full"></div>

    <!-- Floating Address Search (not disabled) -->
    <div
      v-if="!disabled"
      class="absolute left-3 top-3 z-10 w-80 max-w-[calc(100%-4.75rem)]"
    >
      <div
        ref="searchBoxContainer"
        class="relative rounded-md bg-background shadow-md"
      ></div>
    </div>
  </div>
</template>

<style scoped>
.search-box {
  display: block;
  width: 100%;
}

:deep(.obee-map-control-group) {
  color: #333;
}

:deep(.obee-map-control-group button + button) {
  border-top-color: #ddd;
}

:deep(.obee-map-control-button) {
  display: flex;
  align-items: center;
  justify-content: center;
  color: inherit;
  background-color: transparent;
}

:deep(.obee-map-control-icon) {
  display: block;
  width: 18px;
  height: 18px;
  pointer-events: none;
}
</style>
