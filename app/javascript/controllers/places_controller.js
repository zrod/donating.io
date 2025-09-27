import { Controller } from "@hotwired/stimulus"
import PlaceFormCacheService from "services/place_form_cache_service"
import PlaceFormValidationService from "services/place_form_validation_service"
import PlaceListService from "services/places_list_service"

export default class extends Controller {
  static targets = ["form", "submitButton", "bulkActions", "selectedCount", "row"]
  static values = {
    isAuthenticated: Boolean,
    validationMessages: Object,
    validationConstants: Object
  }

  get SELECTORS() {
    return {
      FORM_FIELDS: "input, textarea, select",
      CATEGORY_CHECKBOXES: 'input[name="place[category_ids][]"]:checked',
      CATEGORY_INPUT: 'input[name="place[category_ids][]"]',
      FIELD_ERROR: ".field-error",
      INPUT_ERROR: ".input-error",
      FORM_CONTROL: ".form-control",
      LABEL: "label"
    }
  }

  connect() {
    if (this.hasFormTarget) {
      this.initializeFormServices()
      this.setupFormCaching()
      this.setupValidation()

      this.cacheService.restoreFromCache()
    }

    if (this.hasBulkActionsTarget) {
      this.placesService = new PlaceListService(this.element, this.bulkActionsTarget, this.selectedCountTarget)
      this.placesService.updateDisplay()
    }
  }

  initializeFormServices() {
    this.cacheService = new PlaceFormCacheService(
      this.formTarget,
      this.SELECTORS,
      this.isAuthenticatedValue
    )

    this.validationService = new PlaceFormValidationService(
      this.formTarget,
      this.SELECTORS,
      this.validationMessagesValue,
      this.validationConstantsValue
    )
  }

  setupFormCaching() {
    this.formTarget.addEventListener("submit", () => {
      this.cacheService.saveFormData()
    })
  }

  setupValidation() {
    this.formTarget.addEventListener("submit", (event) => {
      if (!this.validationService.validateForm()) {
        event.preventDefault()
        this.validationService.showValidationErrors()
      }

      if (this.isAuthenticatedValue) {
        this.cacheService.clearCachedData()
      }
    })
  }

  toggleAll(event) {
    this.placesService.toggleAll(event)
  }

  toggleRow(event) {
    this.placesService.toggleRow(event)
  }

  clearSelection() {
    this.placesService.clearSelection()
  }

  bulkDelete(event) {
    this.placesService.bulkDelete(event)
  }

  sort(event) {
    this.placesService.sort(event)
  }
}
