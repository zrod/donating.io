export default class PlaceFormValidationService {
  constructor(formElement, validationMessages, validationConstants) {
    this.formElement = formElement
    this.validationMessages = validationMessages
    this.validationConstants = validationConstants
    this.setupTurboEvents()
  }

  setupTurboEvents() {
    this.formElement.addEventListener("submit", (event) => {
      if (!this.validateForm()) {
        event.preventDefault()
        this.showValidationErrors()
      }
    })
  }

  validateForm() {
    let isValid = true
    const formData = new FormData(this.formElement)

    for (const [name, value] of formData.entries()) {
      if (name === "authenticity_token") {
        continue
      }

      const field = this.formElement.querySelector(`[name="${name}"]`)
      if (field && !this.validateField(field, value)) {
        isValid = false
      }
    }

    if (!this.validateCategories()) {
      isValid = false
    }

    return isValid
  }

  validateField(field, value) {
    const fieldName = field.name
    if (!fieldName) {
      return true
    }

    this.clearFieldError(field)

    const validation = this.getFieldValidation(fieldName, field)
    if (!validation) {
      return true
    }

    const { isValid, message } = validation(value)

    if (!isValid) {
      this.showFieldError(field, message)
    }

    return isValid
  }

  getFieldValidation(fieldName, field) {
    const validations = {
      "place[name]": v => ({
        isValid: v.trim().length >= this.validationConstants.name_min_length,
        message: this.validationMessages.name_min_length
      }),
      "place[description]": v => ({
        isValid: v.trim().length > 0,
        message: this.validationMessages.description_required
      }),
      "place[address]": v => ({
        isValid: v.trim().length >= this.validationConstants.address_min_length,
        message: this.validationMessages.address_min_length
      }),
      "place[city]": v => ({
        isValid: v.trim().length >= this.validationConstants.city_min_length,
        message: this.validationMessages.city_min_length
      }),
      "place[postal_code]": v => ({
        isValid: v.trim().length <= this.validationConstants.postal_code_max_length,
        message: this.validationMessages.postal_code_max_length
      }),
      "place[email]": v => ({
        isValid: !v.trim() || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v.trim()),
        message: this.validationMessages.email_invalid
      }),
      "place[url]": v => ({
        isValid: !v.trim() || this.isValidUrl(v.trim()),
        message: this.validationMessages.url_invalid
      }),
      "place[lat]": v => ({
        isValid: this.isValidCoordinate(v, -90, 90),
        message: this.validationMessages.latitude_invalid
      }),
      "place[lng]": v => ({
        isValid: this.isValidCoordinate(v, -180, 180),
        message: this.validationMessages.longitude_invalid
      })
    }

    const validation = validations[fieldName]
    if (!validation) {
      return null
    }

    if (field.hasAttribute('required') && !field.value.trim()) {
      return () => ({
        isValid: false,
        message: this.validationMessages.field_required.replace('{field}', this.getFieldLabel(field))
      })
    }

    return validation
  }

  getFieldLabel(field) {
    const label = field.closest('.form-control')?.querySelector('label')
    return label ? label.textContent.replace(/\s*\*\s*$/, '').trim() : "This field"
  }

  isValidUrl(value) {
    try {
      new URL(value)
      return true
    } catch {
      return false
    }
  }

  isValidCoordinate(value, min, max) {
    if (!value.trim()) {
      return false
    }

    const coord = parseFloat(value)
    return !isNaN(coord) && coord >= min && coord <= max
  }

  validateCategories() {
    const categoryCheckboxes = this.formElement.querySelectorAll('input[name="place[category_ids][]"]:checked')
    if (categoryCheckboxes.length === 0) {
      this.showCategoryError()
      return false
    }

    this.clearCategoryError()
    return true
  }

  showError(container, message, field = null) {
    if (field) {
      field.classList.add("input-error")
    }

    let errorElement = container.querySelector('.field-error')
    if (!errorElement) {
      errorElement = document.createElement("div")
      errorElement.className = "field-error text-error text-sm mt-1"
      container.appendChild(errorElement)
    }

    errorElement.textContent = message
  }

  clearError(container, field = null) {
    if (field) {
      field.classList.remove("input-error")
    }

    const errorElement = container.querySelector('.field-error')
    if (errorElement) {
      errorElement.remove()
    }
  }

  showFieldError(field, message) {
    this.showError(field.parentNode, message, field)
  }

  clearFieldError(field) {
    this.clearError(field.parentNode, field)
  }

  showCategoryError() {
    const categorySection = this.formElement.querySelector('input[name="place[category_ids][]"]')?.closest('.form-control')
    if (categorySection) {
      this.showError(categorySection, this.validationMessages.categories_required)
    }
  }

  clearCategoryError() {
    const categorySection = this.formElement.querySelector('input[name="place[category_ids][]"]')?.closest('.form-control')
    if (categorySection) {
      this.clearError(categorySection)
    }
  }

  showValidationErrors() {
    const firstError = this.formElement.querySelector('.input-error')

    if (firstError) {
      firstError.scrollIntoView({ behavior: "smooth", block: "center" })
      firstError.focus()
    }
  }
}


