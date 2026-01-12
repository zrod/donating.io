import { Controller } from "@hotwired/stimulus"
import { escapeHtml } from "helpers/html_utils"
import { createMap, createMarker, createPopup, createBounds, addNavigationControls } from "helpers/map_factory"
import { GeoSearchService } from "services/geo_search_service"
import MapPageCacheService from "services/map_page_cache_service"

export default class extends Controller {
  static targets = [
    "map",
    "mapOverlay",
    "sidebar",
    "searchInput",
    "searchButton",
    "searchLoading",
    "searchError",
    "searchResults",
    "searchResultsOverlay",
    "searchContainer",
    "locationStatus",
    "locateButton",
    "resultsContainer",
    "resultsList",
    "resultsCount",
    "resultsLoading",
    "resultsEmpty",
    "showFiltersButton",
    "filtersDrawerCheckbox",
    "filterForm",
    "latField",
    "lngField",
    "radiusField",
    "radiusSelector",
    "locationCheckbox",
    "openingHoursToggle",
    "openingHoursForm"
  ]

  static values = {
    protomapsKey: String,
    pollInterval: Number,
    maxRetries: Number,
    searchTookTooLong: String,
    searchFailed: String,
    noResultsFound: String,
    unknownLocation: String,
    geolocationError: String,
    geolocationUnsupported: String,
    gettingLocation: String,
    placesFoundOne: String,
    placesFoundOther: String
  }

  connect() {
    this.map = null
    this.markers = []
    this.isMapActive = false
    this.clickOutsideHandler = null

    this.geoSearchService = new GeoSearchService({
      pollInterval: this.pollIntervalValue,
      maxRetries: this.maxRetriesValue,
      searchTookTooLongMessage: this.searchTookTooLongValue,
      searchFailedMessage: this.searchFailedValue
    })

    this.cacheService = new MapPageCacheService(this)
    this.restoreFromCache()
  }

  restoreFromCache() {
    const state = this.cacheService.restoreState()
    if (!state) {
      return
    }

    this.cacheService.restoreSearchInput(state)
    this.cacheService.restoreFilterForm(state)
    this.cacheService.restoreOpeningHours(state)
    this.cacheService.restoreLocationCheckbox(state)
    this.cacheService.restoreRadius(state)

    const hasLocation = this.cacheService.restoreLocation(state)

    if (hasLocation) {
      const lat = parseFloat(state.lat)
      const lng = parseFloat(state.lng)

      if (this.hasShowFiltersButtonTarget) {
        this.showFiltersButtonTarget.classList.remove("hidden")
      }
      if (this.hasResultsContainerTarget) {
        this.resultsContainerTarget.classList.remove("hidden")
      }
      this.hideLocateButton()

      // Initialize map if it was active before, or if we have location data
      // This ensures the map is ready when user returns
      if (state.isMapActive || (state.lat && state.lng)) {
        this.initializeMap(lat, lng, 12)
        this.loadPlaces()
      }
    }
  }

  disconnect() {
    this.geoSearchService?.abort()
    this.removeClickOutsideListener()
    this.destroyMap()
    this.cacheService?.saveState()
  }

  // Map activation
  activateMap() {
    if (this.isMapActive) {
      return
    }
    this.promptForLocation()
    this.cacheService?.saveState()
  }

  promptForLocation() {
    if (!navigator.geolocation) {
      this.showLocationStatus(this.geolocationUnsupportedValue, "error")
      this.initializeMapWithoutLocation()
      return
    }

    this.showLocationStatus(this.gettingLocationValue, "loading")

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude
        const lng = position.coords.longitude
        this.setLocation(lat, lng)
        this.hideLocationStatus()
        this.initializeMap(lat, lng, 12)
        this.loadPlaces()
      },
      () => {
        this.showLocationStatus(this.geolocationErrorValue, "error")
        this.initializeMapWithoutLocation()
      }
    )
  }

  initializeMapWithoutLocation() {
    this.initializeMap(45.4215, -75.6972, 4)
    this.isMapActive = true
    this.hideMapOverlay()
    this.hideLocateButton()
    this.cacheService?.saveState()
  }

  initializeMap(lat, lng, zoom = 12) {
    if (this.map) {
      this.map.setCenter([lng, lat])
      this.map.setZoom(zoom)
      return
    }

    this.map = createMap({
      container: this.mapTarget,
      apiKey: this.protomapsKeyValue,
      center: [lng, lat],
      zoom
    })

    if (!this.map) {
      return
    }

    addNavigationControls(this.map, { includeGeolocate: true })

    this.isMapActive = true
    this.hideMapOverlay()
    this.cacheService?.saveState()
  }

  destroyMap() {
    this.clearMarkers()
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  hideMapOverlay() {
    if (this.hasMapOverlayTarget) {
      this.mapOverlayTarget.classList.add("hidden")
    }
  }

  hideLocateButton() {
    if (this.hasLocateButtonTarget) {
      this.locateButtonTarget.classList.add("hidden")
    }
  }

  // Location handling
  setLocation(lat, lng) {
    if (this.hasLatFieldTarget) {
      this.latFieldTarget.value = lat
    }
    if (this.hasLngFieldTarget) {
      this.lngFieldTarget.value = lng
    }
    if (this.hasShowFiltersButtonTarget) {
      this.showFiltersButtonTarget.classList.remove("hidden")
    }
    if (this.hasResultsContainerTarget) {
      this.resultsContainerTarget.classList.remove("hidden")
    }
    this.hideLocateButton()
    this.cacheService?.saveState()
  }

  clearLocation() {
    if (this.hasLatFieldTarget) {
      this.latFieldTarget.value = ""
    }
    if (this.hasLngFieldTarget) {
      this.lngFieldTarget.value = ""
    }
  }

  showLocationStatus(message, type) {
    if (!this.hasLocationStatusTarget) {
      return
    }

    this.locationStatusTarget.textContent = message
    this.locationStatusTarget.classList.remove("hidden", "alert-error", "alert-info")

    if (type === "error") {
      this.locationStatusTarget.classList.add("alert-error")
    } else if (type === "loading") {
      this.locationStatusTarget.classList.add("alert-info")
    }
  }

  hideLocationStatus() {
    if (this.hasLocationStatusTarget) {
      this.locationStatusTarget.classList.add("hidden")
    }
  }

  // Geo search
  async search(event) {
    event.preventDefault()

    const term = this.searchInputTarget.value.trim()
    if (!term) {
      return
    }

    this.showSearchLoading()
    this.clearSearchResults()
    this.hideSearchError()

    await this.geoSearchService.search(term, {
      onComplete: (results, searchTerm) => this.displaySearchResults(results, searchTerm),
      onError: (message) => this.showSearchError(message)
    })
  }

  displaySearchResults(results, term) {
    this.hideSearchLoading()

    if (!results || results.length === 0) {
      this.showSearchError(this.noResultsFoundValue.replace("%{term}", escapeHtml(term)))
      this.hideSearchResultsOverlay()
      return
    }

    this.searchResultsTarget.innerHTML = results.map((result, index) => {
      const parts = [result.city, result.state, result.country].filter(Boolean)
      const displayName = parts.length > 0 ? parts.join(", ") : this.unknownLocationValue
      const address = result.address || result.formatted_address || ""
      const lat = result.latitude ?? result.lat ?? ""
      const lng = result.longitude ?? result.lng ?? ""
      const isLast = index === results.length - 1

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
    }).join("")

    this.showSearchResultsOverlay()
  }

  selectSearchResult(event) {
    const element = event.currentTarget
    const lat = parseFloat(element.dataset.lat)
    const lng = parseFloat(element.dataset.lng)
    const displayName = element.dataset.displayName

    if (isNaN(lat) || isNaN(lng)) {
      return
    }

    this.searchInputTarget.value = displayName || ""
    this.setLocation(lat, lng)
    this.hideSearchResultsOverlay()

    if (!this.isMapActive) {
      this.initializeMap(lat, lng, 12)
    } else {
      this.map.flyTo({ center: [lng, lat], zoom: 12 })
    }

    if (this.hasRadiusSelectorTarget) {
      this.radiusSelectorTarget.style.display = "block"
    }

    if (this.hasLocationCheckboxTarget) {
      this.locationCheckboxTarget.checked = false
    }

    this.cacheService?.saveState()
    this.loadPlaces()
  }

  handleClickOutside(event) {
    if (!this.hasSearchResultsOverlayTarget || !this.hasSearchContainerTarget) {
      return
    }

    if (!this.searchContainerTarget.contains(event.target)) {
      this.hideSearchResultsOverlay()
    }
  }

  addClickOutsideListener() {
    this.removeClickOutsideListener()
    this.clickOutsideHandler = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.clickOutsideHandler, true)
  }

  removeClickOutsideListener() {
    if (this.clickOutsideHandler) {
      document.removeEventListener("click", this.clickOutsideHandler, true)
      this.clickOutsideHandler = null
    }
  }

  showSearchResultsOverlay() {
    if (this.hasSearchResultsOverlayTarget) {
      this.searchResultsOverlayTarget.classList.remove("hidden")
      this.addClickOutsideListener()
    }
  }

  hideSearchResultsOverlay() {
    if (this.hasSearchResultsOverlayTarget) {
      this.searchResultsOverlayTarget.classList.add("hidden")
      this.removeClickOutsideListener()
    }
  }

  showSearchLoading() {
    if (this.hasSearchLoadingTarget) {
      this.searchLoadingTarget.classList.remove("hidden")
    }
    if (this.hasSearchButtonTarget) {
      this.searchButtonTarget.disabled = true
    }
  }

  hideSearchLoading() {
    if (this.hasSearchLoadingTarget) {
      this.searchLoadingTarget.classList.add("hidden")
    }
    if (this.hasSearchButtonTarget) {
      this.searchButtonTarget.disabled = false
    }
  }

  showSearchError(message) {
    this.hideSearchLoading()
    if (this.hasSearchErrorTarget) {
      this.searchErrorTarget.textContent = message
      this.searchErrorTarget.classList.remove("hidden")
    }
  }

  hideSearchError() {
    if (this.hasSearchErrorTarget) {
      this.searchErrorTarget.classList.add("hidden")
    }
  }

  clearSearchResults() {
    if (this.hasSearchResultsTarget) {
      this.searchResultsTarget.innerHTML = ""
    }
    this.hideSearchResultsOverlay()
  }

  // Locate me button
  locateMe() {
    if (!navigator.geolocation) {
      this.showLocationStatus(this.geolocationUnsupportedValue, "error")
      return
    }

    this.showLocationStatus(this.gettingLocationValue, "loading")

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude
        const lng = position.coords.longitude
        this.setLocation(lat, lng)
        this.hideLocationStatus()
        this.searchInputTarget.value = ""

        if (!this.isMapActive) {
          this.initializeMap(lat, lng, 12)
        } else {
          this.map.flyTo({ center: [lng, lat], zoom: 12 })
        }

        if (this.hasRadiusSelectorTarget) {
          this.radiusSelectorTarget.style.display = "block"
        }

        if (this.hasLocationCheckboxTarget) {
          this.locationCheckboxTarget.checked = true
        }

        this.cacheService?.saveState()
        this.loadPlaces()
      },
      () => {
        this.showLocationStatus(this.geolocationErrorValue, "error")
      }
    )
  }

  // Load places
  async loadPlaces() {
    if (!this.hasLatFieldTarget || !this.latFieldTarget.value) {
      return
    }

    this.showResultsLoading()

    const params = new URLSearchParams()
    params.append("lat", this.latFieldTarget.value)
    params.append("lng", this.lngFieldTarget.value)

    if (this.hasRadiusFieldTarget && this.radiusFieldTarget.value) {
      params.append("radius", this.radiusFieldTarget.value)
    }

    if (this.hasFilterFormTarget) {
      const formData = new FormData(this.filterFormTarget)
      for (const [key, value] of formData.entries()) {
        if (value && key !== "lat" && key !== "lng" && key !== "radius" && key !== "commit") {
          params.append(key, value)
        }
      }
    }

    try {
      const response = await fetch(`/places.json?${params.toString()}`)
      if (!response.ok) {
        throw new Error("Failed to load places")
      }

      const data = await response.json()
      this.displayPlaces(data.places)
      this.updateMapMarkers(data.places)
    } catch (error) {
      console.error("Error loading places:", error)
      this.showResultsEmpty()
    }
  }

  displayPlaces(places) {
    this.hideResultsLoading()

    if (!places || places.length === 0) {
      this.showResultsEmpty()
      return
    }

    this.hideResultsEmpty()
    this.showResultsList()

    if (this.hasResultsCountTarget) {
      const countText = places.length === 1
        ? this.placesFoundOneValue
        : this.placesFoundOtherValue.replace("%{count}", places.length)
      this.resultsCountTarget.textContent = countText
    }

    this.resultsListTarget.innerHTML = places.map((place, index) => `
      <div class="card bg-base-100 shadow hover:shadow-lg transition-shadow cursor-pointer border-b last:border-b-0"
           data-action="click->map-page#focusPlace"
           data-lat="${place.lat}"
           data-lng="${place.lng}"
           data-index="${index}">
        <div class="card-body p-4">
          <h3 class="card-title text-base">
            <a href="/places/${place.slug}" class="link link-hover" data-turbo-frame="_top">${escapeHtml(place.name)}</a>
          </h3>
          <p class="text-sm opacity-80">${escapeHtml(place.address)}</p>
          <div class="flex flex-wrap gap-1 mt-2">
            ${place.is_bin ? '<span class="badge badge-ghost badge-sm">📦 Donation Bin</span>' : '<span class="badge badge-ghost badge-sm">🏢 Organization</span>'}
            ${place.tax_receipt ? '<span class="badge badge-ghost badge-sm">📄 Tax Receipt</span>' : ''}
            ${place.used_ok ? '<span class="badge badge-ghost badge-sm">♻️ Used OK</span>' : ''}
            ${place.pickup ? '<span class="badge badge-ghost badge-sm">🚚 Pickup</span>' : ''}
          </div>
        </div>
      </div>
    `).join("")
  }

  focusPlace(event) {
    if (event.target.tagName === "A") {
      return
    }

    const lat = parseFloat(event.currentTarget.dataset.lat)
    const lng = parseFloat(event.currentTarget.dataset.lng)
    const index = parseInt(event.currentTarget.dataset.index)

    if (isNaN(lat) || isNaN(lng)) {
      return
    }

    if (this.map) {
      this.map.flyTo({ center: [lng, lat], zoom: 15 })

      if (this.markers[index]) {
        this.markers[index].getElement()?.classList.add("marker-active")
        setTimeout(() => {
          this.markers[index].getElement()?.classList.remove("marker-active")
        }, 2000)
      }
    }
  }

  updateMapMarkers(places) {
    if (!this.map) {
      return
    }

    this.clearMarkers()

    const bounds = createBounds()
    if (!bounds) {
      return
    }

    places.forEach((place) => {
      const popup = createPopup({
        html: `
          <div class="p-2">
            <h3 class="font-semibold">${escapeHtml(place.name)}</h3>
            <p class="text-sm opacity-70">${escapeHtml(place.address)}</p>
            <a href="/places/${place.slug}" class="link link-primary text-sm">View details</a>
          </div>
        `
      })

      const marker = createMarker({ position: [place.lng, place.lat], map: this.map })
      if (marker && popup) {
        marker.setPopup(popup)
      }

      if (marker) {
        this.markers.push(marker)
      }
      bounds.extend([place.lng, place.lat])
    })

    if (places.length > 0) {
      this.map.fitBounds(bounds, { padding: 50, maxZoom: 14 })
    }
  }

  clearMarkers() {
    this.markers.forEach(marker => marker.remove())
    this.markers = []
  }

  // Results display helpers
  showResultsLoading() {
    this.hideResultsEmpty()
    this.hideResultsList()
    if (this.hasResultsLoadingTarget) {
      this.resultsLoadingTarget.classList.remove("hidden")
    }
  }

  hideResultsLoading() {
    if (this.hasResultsLoadingTarget) {
      this.resultsLoadingTarget.classList.add("hidden")
    }
  }

  showResultsEmpty() {
    this.hideResultsLoading()
    this.hideResultsList()
    if (this.hasResultsEmptyTarget) {
      this.resultsEmptyTarget.classList.remove("hidden")
    }
  }

  hideResultsEmpty() {
    if (this.hasResultsEmptyTarget) {
      this.resultsEmptyTarget.classList.add("hidden")
    }
  }

  showResultsList() {
    if (this.hasResultsListTarget) {
      this.resultsListTarget.classList.remove("hidden")
    }
    if (this.hasResultsCountTarget) {
      this.resultsCountTarget.classList.remove("hidden")
    }
  }

  hideResultsList() {
    if (this.hasResultsListTarget) {
      this.resultsListTarget.classList.add("hidden")
    }
    if (this.hasResultsCountTarget) {
      this.resultsCountTarget.classList.add("hidden")
    }
  }

  // Filters
  openFiltersDrawer() {
    if (this.hasFiltersDrawerCheckboxTarget) {
      this.filtersDrawerCheckboxTarget.checked = true
    }
  }

  closeFiltersDrawer() {
    if (this.hasFiltersDrawerCheckboxTarget) {
      this.filtersDrawerCheckboxTarget.checked = false
    }
  }

  toggleLocation(event) {
    if (event.target.checked) {
      this.locateMe()
    } else {
      this.clearLocation()
      if (this.hasRadiusSelectorTarget) {
        this.radiusSelectorTarget.style.display = "none"
      }
    }
    this.cacheService?.saveState()
  }

  updateRadius(event) {
    if (this.hasRadiusFieldTarget) {
      this.radiusFieldTarget.value = event.target.value
    }
    this.cacheService?.saveState()
  }

  toggleOpeningHours(event) {
    if (!this.hasOpeningHoursFormTarget) {
      return
    }

    if (event.target.checked) {
      this.openingHoursFormTarget.style.display = "none"
      this.openingHoursFormTarget.querySelectorAll("select").forEach(select => select.selectedIndex = 0)
    } else {
      this.openingHoursFormTarget.style.display = "block"
    }
  }

  applyFilters(event) {
    event.preventDefault()
    this.closeFiltersDrawer()
    this.cacheService?.saveState()
    this.loadPlaces()
  }

  clearFilters() {
    if (!this.hasFilterFormTarget) {
      return
    }

    this.filterFormTarget.querySelectorAll('input[type="text"], input[type="search"]').forEach(input => input.value = "")
    this.filterFormTarget.querySelectorAll('input[type="checkbox"]').forEach(checkbox => checkbox.checked = false)
    this.filterFormTarget.querySelectorAll('select').forEach(select => select.selectedIndex = 0)

    if (this.hasOpeningHoursToggleTarget) {
      this.openingHoursToggleTarget.checked = true
    }
    if (this.hasOpeningHoursFormTarget) {
      this.openingHoursFormTarget.style.display = "none"
    }

    this.cacheService?.saveState()
    this.loadPlaces()
  }

}
