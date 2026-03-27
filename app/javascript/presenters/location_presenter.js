import { escapeHtml } from "helpers/html";

/**
 * Formats raw location data into a view object for UI rendering.
 * @param location
 * @param index
 * @param collectionSize
 * @param unknownLocationValue
 * @returns {{displayName: string|*, address, lat, lng, isLast: boolean}}
 */
function buildLocationObject(location, index, collectionSize, unknownLocationValue) {
  const parts = [location.city, location.state, location.country].filter(Boolean)

  return {
    displayName: parts.length > 0 ? parts.join(", ") : unknownLocationValue,
    address: location.address || location.formatted_address || "",
    lat: location.latitude ?? location.lat ?? "",
    lng: location.longitude ?? location.lng ?? "",
    isLast: index === collectionSize - 1
  }
}

/**
 * Renders a UI block for the geo search results view
 * @param location
 * @param index
 * @param locationsLength
 * @param unknownLocationValue
 * @returns {string}
 */
export function renderGeoResultLocation(location, index, locationsLength, unknownLocationValue) {
  const {
    displayName,
    address,
    lat,
    lng,
    isLast
  } = buildLocationObject(location, index, locationsLength, unknownLocationValue);

  return `
        <div class="cursor-pointer hover:bg-base-200 transition-colors p-3 ${!isLast ? 'border-b border-base-300' : ''}"
             data-action="click->geo-search#selectResult"
             data-geo-search-lat="${escapeHtml(String(lat))}"
             data-geo-search-lng="${escapeHtml(String(lng))}"
             data-geo-search-display-name="${escapeHtml(displayName)}">
          <h3 class="font-semibold">${escapeHtml(displayName)}</h3>
          ${address ? `<p class="text-sm opacity-70">${escapeHtml(String(address))}</p>` : ""}
        </div>
      `
}

/**
 * Renders a UI block for the map page search results view
 * @param location
 * @param index
 * @param locationsLength
 * @param unknownLocationValue
 * @returns {string}
 */
export function renderMapPageResultLocation(location, index, locationsLength, unknownLocationValue) {
  const {
    displayName,
    address,
    lat,
    lng,
    isLast
  } = buildLocationObject(location, index, locationsLength, unknownLocationValue);

  return `
        <div class="cursor-pointer hover:bg-base-200 transition-colors p-3 ${!isLast ? 'border-b border-base-300' : ''}"
             data-action="click->map-page#selectSearchResult"
             data-lat="${escapeHtml(String(lat))}"
             data-lng="${escapeHtml(String(lng))}"
             data-display-name="${escapeHtml(displayName)}">
          <h3 class="font-semibold">${escapeHtml(displayName)}</h3>
          ${address ? `<p class="text-sm opacity-70">${escapeHtml(String(address))}</p>` : ""}
        </div>
      `
}
