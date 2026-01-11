/**
 * Factory for creating MapLibre GL maps.
 */

const PROTOMAPS_STYLE_URL = "https://api.protomaps.com/styles/v5/light/en.json"
const DEFAULT_MARKER_COLOR = "#2A628F"
const DEFAULT_ZOOM = 15

/**
 * Creates a new MapLibre GL map instance.
 *
 * @param {Object} options
 * @param {HTMLElement|string} options.container - The container element or ID
 * @param {string} options.apiKey - The Protomaps API key
 * @param {[number, number]} options.center - [lng, lat] coordinates
 * @param {number} [options.zoom=15] - Initial zoom level
 * @param {boolean} [options.interactive=true] - Whether the map is interactive
 * @returns {maplibregl.Map|null} - The map instance or null if maplibregl is not loaded
 */
export function createMap(options) {
  const maplibregl = window.maplibregl
  if (!maplibregl) {
    console.error("MapFactory: maplibre-gl is not loaded")
    return null
  }

  const {
    container,
    apiKey,
    center,
    zoom = DEFAULT_ZOOM,
    interactive = true
  } = options

  return new maplibregl.Map({
    container,
    style: `${PROTOMAPS_STYLE_URL}?key=${apiKey}`,
    center,
    zoom,
    interactive
  })
}

/**
 * Creates a marker with the default styling.
 *
 * @param {Object} options
 * @param {[number, number]} options.position - [lng, lat] coordinates
 * @param {string} [options.color] - Marker color (uses default if not specified)
 * @param {maplibregl.Map} [options.map] - Map to add the marker to
 * @returns {maplibregl.Marker|null} - The marker instance or null if maplibregl is not loaded
 */
export function createMarker(options) {
  const maplibregl = window.maplibregl
  if (!maplibregl) {
    console.error("MapFactory: maplibre-gl is not loaded")
    return null
  }

  const { position, color = DEFAULT_MARKER_COLOR, map } = options

  const marker = new maplibregl.Marker({ color }).setLngLat(position)

  if (map) {
    marker.addTo(map)
  }

  return marker
}

/**
 * Adds standard navigation controls to a map.
 *
 * @param {maplibregl.Map} map - The map instance
 * @param {Object} [options]
 * @param {boolean} [options.includeGeolocate=false] - Whether to include geolocation control
 */
export function addNavigationControls(map, options = {}) {
  const maplibregl = window.maplibregl
  if (!maplibregl || !map) {
    return
  }

  const { includeGeolocate = false } = options

  map.addControl(new maplibregl.NavigationControl(), "top-right")

  if (includeGeolocate) {
    map.addControl(
      new maplibregl.GeolocateControl({
        positionOptions: { enableHighAccuracy: true },
        trackUserLocation: true
      }),
      "top-right"
    )
  }
}

/**
 * Creates a popup with consistent styling.
 *
 * @param {Object} options
 * @param {string} options.html - The HTML content for the popup
 * @param {number} [options.offset=25] - Offset from the marker
 * @returns {maplibregl.Popup|null} - The popup instance or null if maplibregl is not loaded
 */
export function createPopup(options) {
  const maplibregl = window.maplibregl
  if (!maplibregl) {
    return null
  }

  const { html, offset = 25 } = options

  return new maplibregl.Popup({ offset }).setHTML(html)
}

/**
 * Creates bounds for fitting multiple coordinates.
 *
 * @returns {maplibregl.LngLatBounds|null}
 */
export function createBounds() {
  const maplibregl = window.maplibregl
  if (!maplibregl) {
    return null
  }

  return new maplibregl.LngLatBounds()
}
