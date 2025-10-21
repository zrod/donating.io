import { Controller } from "@hotwired/stimulus"

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
    "applyButton"
  ]

  connect() {
    this.updateButtonState()
  }

  toggleLocation(event) {
    if (event.target.checked) {
      this.getCurrentLocation()
    } else {
      this.clearLocation()
    }
  }

  getCurrentLocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.latFieldTarget.value = position.coords.latitude
          this.lngFieldTarget.value = position.coords.longitude
          this.radiusSelectorTarget.style.display = 'block'
          this.updateButtonState()
        },
        () => {
          this.locationCheckboxTarget.checked = false
          console.log('Unable to retrieve your location. Please try again.')
        }
      )
    } else {
      this.locationCheckboxTarget.checked = false
      console.log('Geolocation is not supported by your browser.')
    }
  }

  clearLocation() {
    this.latFieldTarget.value = ''
    this.lngFieldTarget.value = ''
    this.radiusSelectorTarget.style.display = 'none'
    this.updateButtonState()
  }

  updateRadius(event) {
    this.radiusFieldTarget.value = event.target.value
  }

  toggleOpeningHours(event) {
    if (event.target.checked) {
      this.openingHoursFormTarget.style.display = 'none'
      this.openingHoursFormTarget.querySelectorAll('select').forEach(select => select.selectedIndex = 0)
    } else {
      this.openingHoursFormTarget.style.display = 'block'
    }

    this.updateButtonState()
  }

  clearFilters() {
    this.formTarget.querySelectorAll('input[type="text"], input[type="search"]').forEach(input => input.value = '')
    this.formTarget.querySelectorAll('input[type="checkbox"]').forEach(checkbox => checkbox.checked = false)
    this.formTarget.querySelectorAll('input[type="radio"]').forEach(radio => radio.checked = false)
    this.formTarget.querySelectorAll('select').forEach(select => select.selectedIndex = 0)
    this.latFieldTarget.value = ''
    this.lngFieldTarget.value = ''
    this.radiusFieldTarget.value = ''
    this.radiusRangeTarget.value = 10
    this.radiusSelectorTarget.style.display = 'none'
    this.openingHoursToggleTarget.checked = true
    this.openingHoursFormTarget.style.display = 'none'

    this.updateButtonState()

    const placesUrl = this.formTarget.action.split('?')[0]
    Turbo.visit(placesUrl, { action: 'replace' })
  }

  updateButtonState() {
    if (!this.hasApplyButtonTarget) {
      return
    }

    const hasLocation = this.latFieldTarget.value
    const hasFormFields = this.hasActiveFormFields()
    const hasOpeningHours = this.openingHoursToggleTarget && !this.openingHoursToggleTarget.checked

    this.applyButtonTarget.disabled = !(hasLocation || hasFormFields || hasOpeningHours)
  }

  hasActiveFormFields() {
    const filterFields = ['keyword', 'is_bin', 'used_ok', 'pickup', 'charity_support', 'tax_receipt', 'category_ids']

    return filterFields.some(field => {
      const element = this.formTarget.querySelector(`[name="${field}"]`)
      return element && (element.type === 'checkbox' ? element.checked : element.value)
    })
  }

  formChanged() {
    this.updateButtonState()
  }

  submitForm(event) {
    event.preventDefault()

    const formData = new FormData(this.formTarget)
    formData.delete('commit')

    const checkboxFields = ['tax_receipt', 'opening_hours_filter', 'near_me']
    const params = new URLSearchParams()

    for (const [key, value] of formData.entries()) {
      if (value === '' || (checkboxFields.includes(key) && (value === 'false' || value === '0'))) {
        continue
      }

      params.append(key, value)
    }

    const url = `${this.formTarget.action}?${params.toString()}`
    Turbo.visit(url, { frame: 'places_list', action: 'advance' })
  }
}
