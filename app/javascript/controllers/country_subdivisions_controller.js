import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["countrySelect"]

  connect() {
    if (this.hasCountrySelectTarget && this.countrySelectTarget.value) {
      this.loadSubdivisions()
    }
  }

  countryChanged() {
    this.loadSubdivisions()
  }

  loadSubdivisions() {
    const countryId = this.countrySelectTarget.value || ""
    const regionInput = document.querySelector('input[name="place[region]"], select[name="place[region]"]')
    const regionValue = regionInput?.value || ""

    fetch(`/country_subdivisions?country_id=${countryId}&region_value=${encodeURIComponent(regionValue)}`, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.text()
      })
      .then(html => Turbo.renderStreamMessage(html))
      .catch(error => {
        console.error("Error loading subdivisions:", error)
        // On error, server will return empty subdivisions array, which shows text input
      })
  }
}

