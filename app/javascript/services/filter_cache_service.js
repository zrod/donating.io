/**
 * Shared service for caching filter state between map and directory pages.
 * Uses sessionStorage to persist filter selections across page navigations.
 */
export default class FilterCacheService {
  static CACHE_KEY = "shared_filter_state"

  /**
   * Save filter state to sessionStorage
   * @param {Object} state - The filter state to save
   */
  static save(state) {
    const existingState = this.restore() || {}
    const mergedState = { ...existingState, ...state }

    if (this.hasData(mergedState)) {
      sessionStorage.setItem(this.CACHE_KEY, JSON.stringify(mergedState))
    }
  }

  /**
   * Restore filter state from sessionStorage
   * @returns {Object|null} The restored state or null if not found
   */
  static restore() {
    try {
      const raw = sessionStorage.getItem(this.CACHE_KEY)
      if (!raw) {
        return null
      }

      return JSON.parse(raw)
    } catch (e) {
      console.error("Error restoring filter state:", e)
      return null
    }
  }

  /**
   * Clear the cached filter state
   */
  static clear() {
    sessionStorage.removeItem(this.CACHE_KEY)
  }

  /**
   * Check if the state has any meaningful data
   * @param {Object} state - The state to check
   * @returns {boolean}
   */
  static hasData(state) {
    if (!state) {
      return false
    }

    return (
      state.lat ||
      state.lng ||
      state.searchInput ||
      state.radius ||
      (state.filterForm && Object.keys(state.filterForm).length > 0) ||
      (state.categoryIds && state.categoryIds.length > 0)
    )
  }

  /**
   * Extract filter form data from a form element
   * @param {HTMLFormElement} form - The form to extract data from
   * @returns {Object} The extracted filter form data
   */
  static extractFormData(form) {
    const filterForm = {}
    const formData = new FormData(form)

    for (const [key, value] of formData.entries()) {
      if (key === "authenticity_token" || key === "commit") {
        continue
      }

      if (key.endsWith("[]")) {
        filterForm[key] = filterForm[key] || []
        if (value) {
          filterForm[key].push(value)
        }
      } else if (value) {
        filterForm[key] = value
      }
    }

    return filterForm
  }

  /**
   * Apply cached filter form data to a form element
   * @param {HTMLFormElement} form - The form to apply data to
   * @param {Object} filterForm - The filter form data to apply
   */
  static applyFormData(form, filterForm) {
    if (!form || !filterForm) {
      return
    }

    Object.keys(filterForm).forEach(name => {
      if (name.endsWith("[]")) {
        const values = Array.isArray(filterForm[name]) ? filterForm[name] : [filterForm[name]]
        const inputs = form.querySelectorAll(`[name="${name}"]`)

        inputs.forEach(input => {
          if (input.type === "checkbox") {
            input.checked = values.includes(input.value)
          } else if (input.tagName === "SELECT" && input.multiple) {
            Array.from(input.options).forEach(option => {
              option.selected = values.includes(option.value)
            })
          }
        })
      } else {
        const checkbox = form.querySelector(`input[type="checkbox"][name="${name}"]`)
        if (checkbox) {
          checkbox.checked = filterForm[name] === "true" || filterForm[name] === true || filterForm[name] === "1"
          return
        }

        const radioButtons = form.querySelectorAll(`input[type="radio"][name="${name}"]`)
        if (radioButtons.length > 0) {
          radioButtons.forEach(radio => {
            radio.checked = radio.value === filterForm[name]
          })
          return
        }

        const input = form.querySelector(`[name="${name}"]`)
        if (input && (input.tagName === "SELECT" || input.type !== "hidden")) {
          input.value = filterForm[name]
        }
      }
    })
  }
}
