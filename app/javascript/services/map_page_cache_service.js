export default class MapPageCacheService {
  constructor(controller) {
    this.controller = controller
    this.cacheKey = "map_page_state"
  }

  saveState() {
    const state = {
      lat: this.controller.hasLatFieldTarget ? this.controller.latFieldTarget.value : "",
      lng: this.controller.hasLngFieldTarget ? this.controller.lngFieldTarget.value : "",
      radius: this.controller.hasRadiusFieldTarget ? this.controller.radiusFieldTarget.value : "",
      searchInput: this.controller.hasSearchInputTarget ? this.controller.searchInputTarget.value : "",
      locationCheckbox: this.controller.hasLocationCheckboxTarget ? this.controller.locationCheckboxTarget.checked : false,
      isMapActive: this.controller.isMapActive || false,
      filterForm: {}
    }

    if (this.controller.hasFilterFormTarget) {
      const formData = new FormData(this.controller.filterFormTarget)

      for (const [key, value] of formData.entries()) {
        if (key !== "authenticity_token" && key !== "commit") {
          if (key.endsWith("[]")) {
            state.filterForm[key] = state.filterForm[key] || []
            state.filterForm[key].push(value)
          } else {
            state.filterForm[key] = value
          }
        }
      }
    }

    if (this.controller.hasOpeningHoursToggleTarget) {
      state.openingHoursToggle = this.controller.openingHoursToggleTarget.checked
    }

    if (state.lat || state.lng || state.searchInput || Object.keys(state.filterForm).length > 0) {
      sessionStorage.setItem(this.cacheKey, JSON.stringify(state))
    }
  }

  restoreState() {
    try {
      const raw = sessionStorage.getItem(this.cacheKey)
      if (!raw) {
        return null
      }

      const state = JSON.parse(raw)
      return state
    } catch (e) {
      console.error("Error restoring map page state:", e)
      return null
    }
  }

  clearState() {
    sessionStorage.removeItem(this.cacheKey)
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
    if (state.radius && this.controller.hasRadiusFieldTarget) {
      this.controller.radiusFieldTarget.value = state.radius
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

    const form = this.controller.filterFormTarget

    // Restore standard fields
    Object.keys(state.filterForm).forEach(name => {
      if (name.endsWith("[]")) {
        const values = Array.isArray(state.filterForm[name]) ? state.filterForm[name] : [state.filterForm[name]]
        const inputs = form.querySelectorAll(`[name="${name}"]`)
        
        inputs.forEach(input => {
          if (values.includes(input.value)) {
            if (input.type === "checkbox") {
              input.checked = true
            } else if (input.tagName === "SELECT") {
              // For multi-select, we'd need to handle differently
              // For now, just set the first matching value
              if (values.includes(input.value)) {
                input.value = values[0]
              }
            }
          }
        })
      } else {
        const input = form.querySelector(`[name="${name}"]`)
        if (input) {
          if (input.type === "checkbox") {
            input.checked = state.filterForm[name] === "true" || state.filterForm[name] === true
          } else if (input.tagName === "SELECT") {
            input.value = state.filterForm[name]
          } else {
            input.value = state.filterForm[name]
          }
        }
      }
    })
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
