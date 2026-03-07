import FilterCacheService from "services/filter_cache_service"

export default class MapPageCacheService {
  constructor(controller) {
    this.controller = controller
    this.mapStateKey = "map_page_ui_state"
  }

  saveState() {
    // Save shared filter state using FilterCacheService
    const filterState = {
      lat: this.controller.hasLatFieldTarget ? this.controller.latFieldTarget.value : "",
      lng: this.controller.hasLngFieldTarget ? this.controller.lngFieldTarget.value : "",
      radius: this.controller.hasRadiusFieldTarget ? this.controller.radiusFieldTarget.value : "",
      searchInput: this.controller.hasSearchInputTarget ? this.controller.searchInputTarget.value : "",
      locationCheckbox: this.controller.hasLocationCheckboxTarget ? this.controller.locationCheckboxTarget.checked : false,
      openingHoursToggle: this.controller.hasOpeningHoursToggleTarget ? this.controller.openingHoursToggleTarget.checked : true,
      filterForm: {}
    }

    if (this.controller.hasFilterFormTarget) {
      filterState.filterForm = FilterCacheService.extractFormData(this.controller.filterFormTarget)
    }

    FilterCacheService.save(filterState)

    // Save map-specific UI state separately
    const mapUiState = {
      isMapActive: this.controller.isMapActive || false
    }

    sessionStorage.setItem(this.mapStateKey, JSON.stringify(mapUiState))
  }

  restoreState() {
    // Get shared filter state
    const filterState = FilterCacheService.restore()

    // Get map-specific UI state
    let mapUiState = {}
    try {
      const raw = sessionStorage.getItem(this.mapStateKey)
      if (raw) {
        mapUiState = JSON.parse(raw)
      }
    } catch (e) {
      console.error("Error restoring map UI state:", e)
    }

    if (!filterState && !mapUiState.isMapActive) {
      return null
    }

    return { ...filterState, ...mapUiState }
  }

  clearState() {
    FilterCacheService.clear()
    sessionStorage.removeItem(this.mapStateKey)
  }

  restoreLocation(state) {
    if (!state.lat || !state.lng) {
      return false
    }

    const lat = parseFloat(state.lat)
    const lng = parseFloat(state.lng)

    if (isNaN(lat) || isNaN(lng)) {
      return false
    }

    this.controller.setLocation(lat, lng)
    return true
  }

  restoreSearchInput(state) {
    if (state.searchInput && this.controller.hasSearchInputTarget) {
      this.controller.searchInputTarget.value = state.searchInput
    }
  }

  restoreRadius(state) {
    if (state.radius) {
      if (this.controller.hasRadiusFieldTarget) {
        this.controller.radiusFieldTarget.value = state.radius
      }

      const radiusRange = this.controller.element.querySelector('[data-map-page-target="radiusRange"]')
      if (radiusRange) {
        radiusRange.value = state.radius
      }
    }

    if (this.controller.hasRadiusSelectorTarget && (state.lat || state.lng)) {
      this.controller.radiusSelectorTarget.style.display = "block"
    }
  }

  restoreLocationCheckbox(state) {
    if (this.controller.hasLocationCheckboxTarget) {
      this.controller.locationCheckboxTarget.checked = state.locationCheckbox || false
    }
  }

  restoreFilterForm(state) {
    if (!this.controller.hasFilterFormTarget || !state.filterForm) {
      return
    }

    FilterCacheService.applyFormData(this.controller.filterFormTarget, state.filterForm)
  }

  restoreOpeningHours(state) {
    if (this.controller.hasOpeningHoursToggleTarget) {
      const toggleChecked = state.openingHoursToggle !== undefined ? state.openingHoursToggle : true
      this.controller.openingHoursToggleTarget.checked = toggleChecked

      if (this.controller.hasOpeningHoursFormTarget) {
        if (toggleChecked) {
          this.controller.openingHoursFormTarget.style.display = "none"
          this.controller.openingHoursFormTarget.querySelectorAll("select").forEach(select => select.selectedIndex = 0)
        } else {
          this.controller.openingHoursFormTarget.style.display = "block"
        }
      }
    }
  }
}
