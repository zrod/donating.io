import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    lat: Number,
    lng: Number,
    protomapsKey: String
  }

  connect() {
    if (this.latValue == null || this.lngValue == null) {
      console.error("Map controller: lat and lng values are required")
      return
    }

    const maplibregl = window.maplibregl

    if (!maplibregl) {
      console.error("Map controller: maplibre-gl is not loaded")
      return
    }

    this.map = new maplibregl.Map({
      container: this.element,
      style: `https://api.protomaps.com/styles/v5/light/en.json?key=${this.protomapsKeyValue}`,
      center: [this.lngValue, this.latValue],
      zoom: 15,
      interactive: false
    })

    new maplibregl.Marker({ color: "#2A628F" })
      .setLngLat([this.lngValue, this.latValue])
      .addTo(this.map)
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
