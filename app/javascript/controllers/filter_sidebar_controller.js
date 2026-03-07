import { Controller } from "@hotwired/stimulus"
import FilterCacheService from "services/filter_cache_service"

const ACTIVE_FIELDS = [
  "keyword",
  "is_bin",
  "used_ok",
  "pickup",
  "charity_support",
  "tax_receipt",
  "category_ids"
]
const SKIP_VALUES = ["", "false", "0"]

export default class extends Controller {
  static targets = [
    "form",
    "locationCheckbox",
    "latField",
    "lngField",
    "radiusSelector",
    "radiusRange",
    "radiusField",
    "openingHoursToggle",
    "openingHoursForm",
    "applyButton",
    "sidebar",
    "toggleContainerShow",
    "toggleContainerHide"
  ]

  connect() {
    this.restoreFromCache()
    this.updateState()
    this.element.addEventListener("location-selected", () => this.updateState())
  }

  formChanged() {
    this.updateState()
  }

  submitForm(event) {
    event.preventDefault()
    this.saveToCache()

    const url = this.buildFilterUrl()
    const frame = document.querySelector("turbo-frame#places_list")

    if (frame) {
      frame.src = url
      history.pushState({}, "", url)
    } else {
      Turbo.visit(url, { action: "advance" })
    }
  }

  clearFilters() {
    this.resetForm()
    this.updateButtonState()
    FilterCacheService.clear()
    Turbo.visit(this.baseUrl, { action: "replace" })
  }

  toggleLocation(event) {
    event.target.checked ? this.requestCurrentLocation() : this.clearLocation()
  }

  updateRadius(event) {
    this.radiusFieldTarget.value = event.target.value
    this.saveToCache()
  }

  toggleOpeningHours(event) {
    const isHidden = event.target.checked
    this.setOpeningHoursVisibility(!isHidden)

    if (isHidden) {
      this.openingHoursFormTarget.querySelectorAll("select").forEach(s => s.selectedIndex = 0)
    }
    this.updateState()
  }

  toggleMobileSidebar() {
    if (!this.hasSidebarTarget || window.innerWidth >= 1024) {
      return
    }

    const isHidden = this.sidebarTarget.classList.toggle("hidden")
    this.sidebarTarget.classList.toggle("block", !isHidden)
    this.setToggleContainerVisibility(isHidden)
  }

  restoreFromCache() {
    if (window.location.search) {
      return
    }

    const state = FilterCacheService.restore()
    if (!state) {
      this.resetForm()
      this.updateButtonState()
      return
    }

    this.applyLocationState(state)
    this.applyToggleState(state)
    this.applyFormState(state)
  }

  saveToCache() {
    FilterCacheService.save({
      lat: this.safeValue("latField"),
      lng: this.safeValue("lngField"),
      radius: this.safeValue("radiusField"),
      locationCheckbox: this.safeChecked("locationCheckbox"),
      openingHoursToggle: this.safeChecked("openingHoursToggle", true),
      filterForm: this.hasFormTarget ? FilterCacheService.extractFormData(this.formTarget) : {}
    })
  }

  requestCurrentLocation() {
    this.clearGeoSearchInput()

    if (!navigator.geolocation) {
      this.locationCheckboxTarget.checked = false
      return
    }

    navigator.geolocation.getCurrentPosition(
      (position) => this.setLocation(position.coords.latitude, position.coords.longitude),
      () => this.locationCheckboxTarget.checked = false
    )
  }

  setLocation(lat, lng) {
    this.latFieldTarget.value = lat
    this.lngFieldTarget.value = lng
    this.setRadiusSelectorVisibility(true)
    this.updateState()
  }

  clearLocation() {
    this.latFieldTarget.value = ""
    this.lngFieldTarget.value = ""
    this.setRadiusSelectorVisibility(false)
    this.updateState()
  }

  clearGeoSearchInput() {
    const input = this.element.querySelector('[data-geo-search-target="input"]')
    if (input) {
      input.value = ""
    }
  }

  updateState() {
    this.updateButtonState()
    this.saveToCache()
  }

  updateButtonState() {
    if (!this.hasApplyButtonTarget) {
      return
    }

    const hasFilters = this.latFieldTarget.value ||
      this.hasActiveFormFields() ||
      (this.hasOpeningHoursToggleTarget && !this.openingHoursToggleTarget.checked)

    this.applyButtonTarget.disabled = !hasFilters
  }

  hasActiveFormFields() {
    return ACTIVE_FIELDS.some(name => {
      const el = this.formTarget.querySelector(`[name="${name}"]`)
      return el && (el.type === "checkbox" ? el.checked : el.value)
    })
  }

  applyLocationState(state) {
    if (!state.lat || !state.lng) {
      return
    }

    this.latFieldTarget.value = state.lat
    this.lngFieldTarget.value = state.lng
    this.setRadiusSelectorVisibility(true)

    if (state.radius) {
      this.setSafeValue("radiusField", state.radius)
      this.setSafeValue("radiusRange", state.radius)
    }
  }

  applyToggleState(state) {
    this.setSafeChecked("locationCheckbox", state.locationCheckbox)
    this.setSafeChecked("openingHoursToggle", state.openingHoursToggle)

    if (this.hasOpeningHoursFormTarget) {
      this.setOpeningHoursVisibility(!state.openingHoursToggle)
    }
  }

  applyFormState(state) {
    if (state.filterForm && this.hasFormTarget) {
      FilterCacheService.applyFormData(this.formTarget, state.filterForm)
    }
  }

  resetForm() {
    this.formTarget.reset()
    this.latFieldTarget.value = ""
    this.lngFieldTarget.value = ""
    this.radiusFieldTarget.value = ""
    this.radiusRangeTarget.value = 10
    this.setRadiusSelectorVisibility(false)
    this.openingHoursToggleTarget.checked = true
    this.setOpeningHoursVisibility(false)
  }

  buildFilterUrl() {
    const params = new URLSearchParams()

    for (const [key, value] of new FormData(this.formTarget).entries()) {
      if (key !== "commit" && !SKIP_VALUES.includes(value)) {
        params.append(key, value)
      }
    }

    return params.toString() ? `${this.baseUrl}?${params}` : this.baseUrl
  }

  get baseUrl() {
    return this.formTarget.action.split("?")[0]
  }

  setRadiusSelectorVisibility(visible) {
    if (this.hasRadiusSelectorTarget) {
      this.radiusSelectorTarget.style.display = visible ? "block" : "none"
    }
  }

  setOpeningHoursVisibility(visible) {
    this.openingHoursFormTarget.style.display = visible ? "block" : "none"
  }

  setToggleContainerVisibility(sidebarHidden) {
    if (this.hasToggleContainerShowTarget) {
      this.toggleContainerShowTarget.style.display = sidebarHidden ? "block" : "none"
    }
    if (this.hasToggleContainerHideTarget) {
      this.toggleContainerHideTarget.style.display = sidebarHidden ? "none" : "block"
    }
  }

  safeValue(name, defaultValue = "") {
    const key = name.charAt(0).toUpperCase() + name.slice(1)
    return this[`has${key}Target`] ? this[`${name}Target`].value : defaultValue
  }

  setSafeValue(name, value) {
    const key = name.charAt(0).toUpperCase() + name.slice(1)
    if (this[`has${key}Target`]) {
      this[`${name}Target`].value = value
    }
  }

  safeChecked(name, defaultValue = false) {
    const key = name.charAt(0).toUpperCase() + name.slice(1)
    return this[`has${key}Target`] ? this[`${name}Target`].checked : defaultValue
  }

  setSafeChecked(name, value) {
    const key = name.charAt(0).toUpperCase() + name.slice(1)
    if (value !== undefined && this[`has${key}Target`]) {
      this[`${name}Target`].checked = value
    }
  }
}
