import { Controller } from "@hotwired/stimulus"
import { createMap, createMarker } from "helpers/map_factory"

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

    this.map = createMap({
      container: this.element,
      apiKey: this.protomapsKeyValue,
      center: [this.lngValue, this.latValue],
      interactive: false
    })

    if (this.map) {
      createMarker({ position: [this.lngValue, this.latValue], map: this.map })
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
