import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "results", "loading", "error"]
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
  }

  disconnect() {
    this.stopPolling()
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
      return
    }

    this.resultsTarget.innerHTML = results.map(result => {
      const displayName = this.escapeHtml(String(result.display_name || result.name || this.unknownLocationValue))
      const address = this.escapeHtml(String(result.address || result.formatted_address || ""))
      const lat = String(result.lat || "")
      const lng = String(result.lng || "")

      return `
        <div class="card bg-base-100 shadow-sm mb-2">
          <div class="card-body p-4">
            <h3 class="font-semibold">${displayName}</h3>
            ${address ? `<p class="text-sm opacity-70">${address}</p>` : ""}
            ${lat && lng ? `<div class="text-xs opacity-60 mt-1">${this.escapeHtml(lat)}, ${this.escapeHtml(lng)}</div>` : ""}
          </div>
        </div>
      `
    }).join("")
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
  }

  hideError() {
    this.errorTarget.classList.add("hidden")
  }

  clearResults() {
    this.resultsTarget.innerHTML = ""
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ""
  }
}
