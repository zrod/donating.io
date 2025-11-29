import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "loading", "error", "searchButton", "resultsOverlay", "searchContainer"]
  static values = {
    pollInterval: Number,
    maxRetries: Number,
    searchTookTooLong: String,
    searchFailed: String,
    noResultsFound: String,
    unknownLocation: String
  }

  connect() {
    this.pollTimer = null
    this.retryCount = 0
    this.clickOutsideHandler = null
  }

  disconnect() {
    this.stopPolling()
    this.removeClickOutsideListener()
  }

  handleClickOutside(event) {
    if (!this.hasResultsOverlayTarget || !this.hasSearchContainerTarget) {
      return
    }

    if (!this.searchContainerTarget.contains(event.target)) {
      this.hideResultsOverlay()
    }
  }

  addClickOutsideListener() {
    this.removeClickOutsideListener()
    this.clickOutsideHandler = this.handleClickOutside.bind(this)
    document.addEventListener('click', this.clickOutsideHandler, true)
  }

  removeClickOutsideListener() {
    if (this.clickOutsideHandler) {
      document.removeEventListener('click', this.clickOutsideHandler, true)
      this.clickOutsideHandler = null
    }
  }

  async search(event) {
    event.preventDefault()

    const term = this.inputTarget.value.trim()
    if (!term) {
      return
    }

    this.showLoading()
    this.clearResults()
    this.hideError()
    this.stopPolling()
    this.retryCount = 0

    await this.performSearch(term)
  }

  async performSearch(term) {
    if (this.retryCount >= this.maxRetriesValue) {
      this.stopPolling()
      this.showError(this.searchTookTooLongValue)
      return
    }

    this.retryCount++

    try {
      const response = await fetch("/geo_terms/search", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.getCSRFToken()
        },
        body: JSON.stringify({ term })
      })

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}))
        this.stopPolling()
        this.showError(errorData.error || this.searchFailedValue)
        return
      }

      const data = await response.json()

      if (data.status === "complete") {
        this.stopPolling()
        this.displayResults(data.results, data.term || term)
      } else if (data.status === "pending") {
        this.startPolling(term)
      } else if (data.error) {
        this.stopPolling()
        this.showError(data.error)
      }
    } catch (error) {
      this.stopPolling()
      this.showError(this.searchFailedValue)
    }
  }

  startPolling(term) {
    this.pollTimer = setTimeout(() => {
      this.performSearch(term)
    }, this.pollIntervalValue)
  }

  stopPolling() {
    if (this.pollTimer) {
      clearTimeout(this.pollTimer)
      this.pollTimer = null
    }
  }

  displayResults(results, term) {
    this.hideLoading()

    if (!results || results.length === 0) {
      this.showError(this.noResultsFoundValue.replace("%{term}", this.escapeHtml(term)))
      this.hideResultsOverlay()
      return
    }

    this.resultsTarget.innerHTML = results.map((result, index) => {
      const parts = [result.city, result.state, result.country].filter(Boolean)
      const displayName = parts.length > 0 ? parts.join(", ") : this.unknownLocationValue

      const address = result.address || result.formatted_address || ""
      const lat = result.latitude ?? result.lat ?? ""
      const lng = result.longitude ?? result.lng ?? ""
      const isLast = index === results.length - 1

      return `
        <div class="cursor-pointer hover:bg-base-200 transition-colors p-3 ${!isLast ? 'border-b border-base-300' : ''}"
             data-action="click->geo-search#selectResult"
             data-geo-search-lat="${this.escapeHtml(String(lat))}"
             data-geo-search-lng="${this.escapeHtml(String(lng))}"
             data-geo-search-display-name="${this.escapeHtml(displayName)}">
          <h3 class="font-semibold">${this.escapeHtml(displayName)}</h3>
          ${address ? `<p class="text-sm opacity-70">${this.escapeHtml(String(address))}</p>` : ""}
        </div>
      `
    }).join("")

    this.showResultsOverlay()
  }

  showResultsOverlay() {
    if (this.hasResultsOverlayTarget) {
      this.resultsOverlayTarget.classList.remove("hidden")
      this.addClickOutsideListener()
    }
  }

  hideResultsOverlay() {
    if (this.hasResultsOverlayTarget) {
      this.resultsOverlayTarget.classList.add("hidden")
      this.removeClickOutsideListener()
    }
  }

  selectResult(event) {
    const element = event.currentTarget
    const lat = element.dataset.geoSearchLat
    const lng = element.dataset.geoSearchLng
    const displayName = element.dataset.geoSearchDisplayName

    if (!lat || !lng) {
      return
    }

    const latField = document.getElementById("location_lat")
    const lngField = document.getElementById("location_lng")

    if (latField) {
      latField.value = lat
    }
    if (lngField) {
      lngField.value = lng
    }

    const radiusSelector = document.querySelector('[data-filter-sidebar-target="radiusSelector"]')
    const locationCheckbox = document.getElementById("use_current_location")

    if (radiusSelector) {
      radiusSelector.style.display = 'block'
    }
    if (locationCheckbox) {
      locationCheckbox.checked = false
    }

    this.inputTarget.value = displayName || ""
    this.clearResults()
    this.element.dispatchEvent(new CustomEvent('location-selected', {
      detail: { lat, lng },
      bubbles: true
    }))
  }

  escapeHtml(text) {
    if (text == null) {
      return ""
    }
    const div = document.createElement("div")
    div.textContent = String(text)
    return div.innerHTML
  }

  showLoading() {
    this.loadingTarget.classList.remove("hidden")
  }

  hideLoading() {
    this.loadingTarget.classList.add("hidden")
  }

  showError(message) {
    this.hideLoading()
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
    this.hideResultsOverlay()
  }

  hideError() {
    this.errorTarget.classList.add("hidden")
  }

  clearResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = ""
    }
    this.hideResultsOverlay()
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ""
  }
}
