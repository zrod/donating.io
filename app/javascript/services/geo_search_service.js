import { getCSRFToken } from "helpers/html_utils"

/**
 * Service for performing geo term searches with polling support.
 * Handles the async nature of geocoding requests that may be pending.
 */
export class GeoSearchService {
  /**
   * @param {Object} options
   * @param {number} options.pollInterval - Interval between polling requests (ms)
   * @param {number} options.maxRetries - Maximum number of retry attempts
   * @param {string} options.searchTookTooLongMessage - Message when max retries exceeded
   * @param {string} options.searchFailedMessage - Message for generic search failures
   */
  constructor(options = {}) {
    this.pollInterval = options.pollInterval || 2000
    this.maxRetries = options.maxRetries || 10
    this.searchTookTooLongMessage = options.searchTookTooLongMessage || "Search took too long. Please try again."
    this.searchFailedMessage = options.searchFailedMessage || "Search failed. Please try again."

    this.pollTimer = null
    this.retryCount = 0
    this.aborted = false
  }

  /**
   * Perform a search for the given term.
   * @param {string} term - The search term
   * @param {Object} callbacks
   * @param {Function} callbacks.onComplete - Called with (results, term) when search completes
   * @param {Function} callbacks.onError - Called with (errorMessage) on error
   * @returns {Promise<void>}
   */
  async search(term, callbacks) {
    this.stopPolling()
    this.retryCount = 0
    this.aborted = false
    this.callbacks = callbacks

    await this.performSearch(term)
  }

  /**
   * Stop any ongoing polling and abort the search.
   */
  abort() {
    this.aborted = true
    this.stopPolling()
  }

  async performSearch(term) {
    if (this.aborted) {
      return
    }

    if (this.retryCount >= this.maxRetries) {
      this.stopPolling()
      this.callbacks.onError?.(this.searchTookTooLongMessage)
      return
    }

    this.retryCount++

    try {
      const response = await fetch("/geo_terms/search", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": getCSRFToken()
        },
        body: JSON.stringify({ term })
      })

      if (this.aborted) {
        return
      }

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}))
        this.stopPolling()
        this.callbacks.onError?.(errorData.error || this.searchFailedMessage)
        return
      }

      const data = await response.json()

      if (data.status === "complete") {
        this.stopPolling()
        this.callbacks.onComplete?.(data.results, data.term || term)
      } else if (data.status === "pending") {
        this.startPolling(term)
      } else if (data.error) {
        this.stopPolling()
        this.callbacks.onError?.(data.error)
      }
    } catch (error) {
      if (!this.aborted) {
        this.stopPolling()
        this.callbacks.onError?.(this.searchFailedMessage)
      }
    }
  }

  startPolling(term) {
    this.pollTimer = setTimeout(() => {
      this.performSearch(term)
    }, this.pollInterval)
  }

  stopPolling() {
    if (this.pollTimer) {
      clearTimeout(this.pollTimer)
      this.pollTimer = null
    }
  }
}
