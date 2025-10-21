import { Controller } from "@hotwired/stimulus"
import PlaceFormCacheService from "services/place_form_cache_service"
import PlaceFormValidationService from "services/place_form_validation_service"

export default class extends Controller {
  static targets = ["form"]
  static values = {
    isAuthenticated: Boolean,
    validationMessages: Object,
    validationConstants: Object
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
