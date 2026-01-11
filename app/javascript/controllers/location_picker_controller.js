import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "searchButton", "loading", "error", "results", "mapContainer", "mapPlaceholder", "useLocationButton"]
  static values = {
    protomapsKey: String,
    pollInterval: Number,
    maxRetries: Number,
    searchTookTooLong: String,
    searchFailed: String,
    noResultsFound: String
  }

  connect() {
    this.map = null
    this.marker = null
    this.selectedLocation = null
    this.pollTimer = null
    this.retryCount = 0
  }

  disconnect() {
    this.stopPolling()
    this.destroyMap()
  }

  open() {
    this.element.showModal()
    this.reset()
  }

  close() {
    this.element.close()
    this.reset()
  }

  reset() {
    this.searchInputTarget.value = ""
    this.hideLoading()
    this.hideError()
    this.hideResults()
    this.selectedLocation = null
    this.useLocationButtonTarget.disabled = true
    this.destroyMap()
    this.showMapPlaceholder()
  }

  async search(event) {
    event.preventDefault()

    const term = this.searchInputTarget.value.trim()
    if (!term) {
      return
    }

    this.showLoading()
    this.hideError()
    this.hideResults()
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
      return
    }

    this.resultsTarget.innerHTML = results.map((result, index) => {
      const parts = [result.city, result.state, result.country].filter(Boolean)
      const displayName = parts.length > 0 ? parts.join(", ") : "Unknown"

      const address = result.address || result.formatted_address || ""
      const lat = result.latitude ?? result.lat ?? ""
      const lng = result.longitude ?? result.lng ?? ""
      const city = result.city || ""
      const state = result.state || ""
      const country = result.country || ""
      const postalCode = result.postal_code || result.postalCode || ""
      const isLast = index === results.length - 1

      return `
        <div class="cursor-pointer hover:bg-base-200 transition-colors p-3 ${!isLast ? 'border-b border-base-300' : ''}"
             data-action="click->location-picker#selectResult"
             data-lat="${this.escapeHtml(String(lat))}"
             data-lng="${this.escapeHtml(String(lng))}"
             data-address="${this.escapeHtml(String(address))}"
             data-city="${this.escapeHtml(String(city))}"
             data-state="${this.escapeHtml(String(state))}"
             data-country="${this.escapeHtml(String(country))}"
             data-postal-code="${this.escapeHtml(String(postalCode))}">
          <h3 class="font-semibold">${this.escapeHtml(displayName)}</h3>
          ${address ? `<p class="text-sm opacity-70">${this.escapeHtml(String(address))}</p>` : ""}
        </div>
      `
    }).join("")

    this.showResults()
  }

  selectResult(event) {
    const element = event.currentTarget
    const lat = parseFloat(element.dataset.lat)
    const lng = parseFloat(element.dataset.lng)

    if (isNaN(lat) || isNaN(lng)) {
      return
    }

    this.selectedLocation = {
      lat,
      lng,
      address: element.dataset.address,
      city: element.dataset.city,
      state: element.dataset.state,
      country: element.dataset.country,
      postalCode: element.dataset.postalCode
    }

    this.hideResults()
    this.updateMap(lat, lng)
    this.useLocationButtonTarget.disabled = false
  }

  updateMap(lat, lng) {
    this.hideMapPlaceholder()

    const maplibregl = window.maplibregl
    if (!maplibregl) {
      console.error("Location picker: maplibre-gl is not loaded")
      return
    }

    if (this.map) {
      this.map.setCenter([lng, lat])

      if (this.marker) {
        this.marker.setLngLat([lng, lat])
      } else {
        this.marker = new maplibregl.Marker({ color: "#2A628F" })
          .setLngLat([lng, lat])
          .addTo(this.map)
      }
    } else {
      this.map = new maplibregl.Map({
        container: this.mapContainerTarget,
        style: `https://api.protomaps.com/styles/v5/light/en.json?key=${this.protomapsKeyValue}`,
        center: [lng, lat],
        zoom: 15,
        interactive: true
      })

      this.marker = new maplibregl.Marker({ color: "#2A628F" })
        .setLngLat([lng, lat])
        .addTo(this.map)
    }
  }

  destroyMap() {
    if (this.marker) {
      this.marker.remove()
      this.marker = null
    }

    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  useLocation() {
    if (!this.selectedLocation) {
      return
    }

    const fields = {
      "place_lat": this.selectedLocation.lat,
      "place_lng": this.selectedLocation.lng,
      "place_address": this.selectedLocation.address,
      "place_city": this.selectedLocation.city,
      "place_region": this.selectedLocation.state,
      "place_postal_code": this.selectedLocation.postalCode
    }

    for (const [id, value] of Object.entries(fields)) {
      const field = document.getElementById(id)
      if (field && value) {
        field.value = value
      }
    }

    const countryField = document.getElementById("place_country_id")

    if (countryField && this.selectedLocation.country) {
      const countryName = this.selectedLocation.country.toLowerCase()
      const options = countryField.options

      for (let i = 0; i < options.length; i++) {
        if (options[i].text.toLowerCase() === countryName) {
          countryField.value = options[i].value
          countryField.dispatchEvent(new Event('change', { bubbles: true }))
          break
        }
      }
    }

    this.close()
  }

  showLoading() {
    this.loadingTarget.classList.remove("hidden")
    this.searchButtonTarget.disabled = true
  }

  hideLoading() {
    this.loadingTarget.classList.add("hidden")
    this.searchButtonTarget.disabled = false
  }

  showError(message) {
    this.hideLoading()
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }

  hideError() {
    this.errorTarget.classList.add("hidden")
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
  }

  showMapPlaceholder() {
    this.mapPlaceholderTarget.classList.remove("hidden")
  }

  hideMapPlaceholder() {
    this.mapPlaceholderTarget.classList.add("hidden")
  }

  escapeHtml(text) {
    if (text == null) {
      return ""
    }

    const div = document.createElement("div")
    div.textContent = String(text)

    return div.innerHTML
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ""
  }
}
