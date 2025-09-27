export default class PlaceFormCacheService {
  constructor(formElement, selectors, isAuthenticated) {
    this.formElement = formElement
    this.selectors = selectors
    this.isAuthenticated = isAuthenticated
    this.cacheKey = "place_form_data"
  }

  saveFormData() {
    const data = {}
    const fields = this.formElement.querySelectorAll(this.selectors.FORM_FIELDS)

    fields.forEach(field => {
      const name = field.name
      if (!name || name === "authenticity_token") {
        return
      }

      try {
        this.collectFieldValue(field, name, data)
      } catch (e) {
        console.error("Validation: Error collecting field value", field, e)
      }
    })

    if (Object.keys(data).length) {
      sessionStorage.setItem(this.cacheKey, JSON.stringify(data))
    }
  }

  clearCachedData() {
    sessionStorage.removeItem(this.cacheKey)
  }

  collectFieldValue(field, name, data) {
    if (field.type === "checkbox") {
      if (name === "place[category_ids][]") {
        data[name] = data[name] || []

        if (field.checked) {
          data[name].push(field.value)
        }
      } else {
        data[name] = field.checked
      }

      return
    }

    if (field.type === "radio" && field.checked) {
      data[name] = field.value
      return
    }

    if (field.tagName === "SELECT") {
      data[name] = field.multiple
        ? Array.from(field.selectedOptions).map(o => o.value).filter(Boolean)
        : field.value

      return
    }

    if (field.type === "hidden" && this.isHourFieldName(name)) {
      data[name] = field.value
      return
    }

    if (field.value) {
      data[name] = field.value
    }
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

      const boxes = this.formElement.querySelectorAll(this.selectors.CATEGORY_INPUT)
      boxes.forEach(box => {
        if (values.includes(box.value)) {
          box.checked = true
        }
      })
    } catch {}
  }

  restoreBooleanFields(data) {
    const names = ["place[used_ok]", "place[is_bin]", "place[pickup]", "place[tax_receipt]"]
    names.forEach(name => {
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
      if (name === "place[category_ids][]") {
        return
      }

      if (["place[used_ok]", "place[is_bin]", "place[pickup]", "place[tax_receipt]"].includes(name)) {
        return
      }

      if (this.isHourFieldName(name)) {
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

      const container = this.formElement.querySelector('[data-hours-target="hiddenFields"]')
      if (!container) {
        return
      }

      Object.keys(hours).forEach(idx => {
        const h = hours[idx]
        if (!h.day_of_week || !h.from_hour || !h.to_hour) {
          return
        }

        container.insertAdjacentHTML("beforeend", `
          <input type="hidden" name="place[place_hours_attributes][${idx}][day_of_week]" value="${h.day_of_week}">
          <input type="hidden" name="place[place_hours_attributes][${idx}][from_hour]" value="${h.from_hour}">
          <input type="hidden" name="place[place_hours_attributes][${idx}][to_hour]" value="${h.to_hour}">
        `)
      })
    } catch {}
  }
}


