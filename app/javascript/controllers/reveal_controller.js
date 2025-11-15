import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link"]
  static values = { content: String }

  reveal(event) {
    event.preventDefault()

    const span = document.createElement("span")
    span.textContent = this.contentValue
    span.className = this.linkTarget.className.replace("link link-secondary", "")

    this.linkTarget.replaceWith(span)
  }
}
