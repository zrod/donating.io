import { Controller } from "@hotwired/stimulus"
import FormCacheService from "services/form_cache_service"
import FormValidationService from "services/form_validation_service"

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
    this.initializeServices()
    this.setupFormCaching()
    this.cacheService.restoreFromCache()
    this.setupValidation()
  }

  initializeServices() {
    this.cacheService = new FormCacheService(
      this.formTarget,
      this.SELECTORS,
      this.isAuthenticatedValue
    )

    this.validationService = new FormValidationService(
      this.formTarget,
      this.SELECTORS,
      this.validationMessagesValue,
      this.validationConstantsValue
    )
  }

  setupFormCaching() {
    this.formTarget.addEventListener("submit", () => {
      console.log("Saving form data")
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
}
