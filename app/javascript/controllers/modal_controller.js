import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleSubmitEnd(event) {
    if (event.detail.success) {
      this.element.close()
      const form = this.element.querySelector("form")
      if (form) {
        form.reset()
      }
    }
  }
}
