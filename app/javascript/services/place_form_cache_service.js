export default class PlaceFormCacheService {
  constructor(formElement, isAuthenticated) {
    this.formElement = formElement
    this.isAuthenticated = isAuthenticated
    this.cacheKey = "place_form_data"
    this.setupTurboEvents()
  }

  setupTurboEvents() {
    this.formElement.addEventListener("turbo:submit-start", () => {
      this.saveFormData()
    })

    this.formElement.addEventListener("turbo:submit-end", (event) => {
      if (this.isAuthenticated && event.detail.success) {
        this.clearCachedData()
      }
    })
  }

  saveFormData() {
    const data = {}
    const formData = new FormData(this.formElement)

    for (const [name, value] of formData.entries()) {
      if (name === "authenticity_token") {
        continue
      }

      try {
        this.collectFieldValue(name, value, data)
      } catch (e) {
        console.error("Validation: Error collecting field value", name, e)
      }
    }

    if (Object.keys(data).length) {
      sessionStorage.setItem(this.cacheKey, JSON.stringify(data))
    }
  }

  clearCachedData() {
    sessionStorage.removeItem(this.cacheKey)
  }

  collectFieldValue(name, value, data) {
    if (name.endsWith("[]")) {
      data[name] = data[name] || []
      data[name].push(value)
      return
    }

    if (this.isHourFieldName(name)) {
      data[name] = value
      return
    }

    if (this.isBooleanField(name)) {
      data[name] = value === "1" || value === "true"
      return
    }

    if (value) {
      data[name] = value
    }
  }

  isBooleanField(name) {
    const booleanFields = ["place[used_ok]", "place[is_bin]", "place[pickup]", "place[tax_receipt]"]
    return booleanFields.includes(name)
  }

  isHourFieldName(name) {
    return name.startsWith("place[place_hours_attributes]")
  }

  restoreFromCache() {
    let raw
    try {
      raw = sessionStorage.getItem(this.cacheKey)
      if (!raw) {
        return
      }

      const data = JSON.parse(raw)
      this.restoreFields(data)
    } catch {}
  }

  restoreFields(data) {
    this.restoreCategories(data)
    this.restoreBooleanFields(data)
    this.restoreStandardFields(data)
    this.restoreHours(data)
  }

  restoreCategories(data) {
    try {
      const values = Array.isArray(data["place[category_ids][]"]) ? data["place[category_ids][]"] : []
      if (!values.length) {
        return
      }

      const boxes = this.formElement.querySelectorAll('input[name="place[category_ids][]"]')
      boxes.forEach(box => {
        if (values.includes(box.value)) {
          box.checked = true
        }
      })
    } catch {}
  }

  restoreBooleanFields(data) {
    const booleanFields = ["place[used_ok]", "place[is_bin]", "place[pickup]", "place[tax_receipt]"]
    booleanFields.forEach(name => {
      try {
        if (!(name in data)) {
          return
        }

        const input = this.formElement.querySelector(`input[type="checkbox"][name="${name}"]`)
        if (input) {
          input.checked = !!data[name]
        }
      } catch {}
    })
  }

  restoreStandardFields(data) {
    Object.keys(data).forEach(name => {
      if (name === "place[category_ids][]" ||
          this.isBooleanField(name) ||
          this.isHourFieldName(name)) {
        return
      }

      try {
        const els = this.formElement.querySelectorAll(`[name="${name}"]`)
        if (!els || els.length === 0) {
          return
        }

        const el = els[0]
        if (el.tagName === "SELECT") {
          el.value = data[name]
        } else if (el.type !== "checkbox" && el.type !== "radio") {
          el.value = data[name]
        }
      } catch {}
    })
  }

  restoreHours(data) {
    try {
      const hours = Object.keys(data)
        .filter(k => this.isHourFieldName(k))
        .reduce((acc, key) => {
          const match = key.match(/^place\[place_hours_attributes\]\[(\d+)\]\[(day_of_week|from_hour|to_hour)\]$/)
          if (!match) {
            return acc
          }

          const idx = match[1]
          const attr = match[2]
          if (!acc[idx]) {
            acc[idx] = {}
          }

          acc[idx][attr] = data[key]
          return acc
        }, {})

      const container = this.formElement.querySelector('[data-turbo-permanent] [data-hours-target="hiddenFields"]') ||
                       this.formElement.querySelector('[data-hours-target="hiddenFields"]')

      if (!container) {
        return
      }

      Object.keys(hours).forEach(idx => {
        const h = hours[idx]
        if (!h.day_of_week || !h.from_hour || !h.to_hour) {
          return
        }

        const fragment = document.createDocumentFragment()

        const dayInput = document.createElement('input')
        dayInput.type = 'hidden'
        dayInput.name = `place[place_hours_attributes][${idx}][day_of_week]`
        dayInput.value = h.day_of_week

        const fromInput = document.createElement('input')
        fromInput.type = 'hidden'
        fromInput.name = `place[place_hours_attributes][${idx}][from_hour]`
        fromInput.value = h.from_hour

        const toInput = document.createElement('input')
        toInput.type = 'hidden'
        toInput.name = `place[place_hours_attributes][${idx}][to_hour]`
        toInput.value = h.to_hour

        fragment.appendChild(dayInput)
        fragment.appendChild(fromInput)
        fragment.appendChild(toInput)

        container.appendChild(fragment)
      })
    } catch {}
  }
}


