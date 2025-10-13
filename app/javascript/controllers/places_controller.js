import { Controller } from "@hotwired/stimulus"
import PlaceFormCacheService from "services/place_form_cache_service"
import PlaceFormValidationService from "services/place_form_validation_service"

export default class extends Controller {
  static targets = ["form", "submitButton"]
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

      this.cacheService.restoreFromCache()
    }
  }

  initializeFormServices() {
    this.cacheService = new PlaceFormCacheService(
      this.formTarget,
      this.isAuthenticatedValue
    )

    this.validationService = new PlaceFormValidationService(
      this.formTarget,
      this.validationMessagesValue,
      this.validationConstantsValue
    )
  }
}
