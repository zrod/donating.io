import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["daySelector", "fromTime", "toTime", "selectionInfo", "hoursList", "hiddenFields"]
  static values = { messages: Object, dayNames: Object, dayNamesShort: Object }

  connect() {
    this.selectedDays = []
    this.addedHours = []
    this.updateSelectionDisplay()

    this.fromTimeTarget.value = '0900'
    this.toTimeTarget.value = '1700'

    this.rebuildHoursFromHiddenFields()
  }

  toggleDay(event) {
    const element = event.currentTarget
    const day = parseInt(element.dataset.day)
    const index = this.selectedDays.indexOf(day)

    if (index > -1) {
      this.selectedDays.splice(index, 1)
      element.classList.remove('selected')
    } else {
      this.selectedDays.push(day)
      element.classList.add('selected')
    }

    this.updateSelectionDisplay()
  }

  updateSelectionDisplay() {
    if (this.selectedDays.length === 0) {
      this.selectionInfoTarget.textContent = this.messagesValue.select_days_instruction
      this.selectionInfoTarget.className = 'text-sm text-base-content/60 mt-2'
    } else {
      const selectedDayNames = this.selectedDays.sort().map(day => this.dayNamesShortValue[day]).join(', ')
      this.selectionInfoTarget.textContent = `${this.messagesValue.selected_label}: ${selectedDayNames}`
      this.selectionInfoTarget.className = 'text-sm text-primary font-medium mt-2'
    }
  }

  includeSelectedHours() {
    const fromTime = this.fromTimeTarget.value
    const toTime = this.toTimeTarget.value

    if (this.selectedDays.length === 0) {
      alert(this.messagesValue.select_days_error)
      return
    }

    if (parseInt(fromTime) >= parseInt(toTime)) {
      alert(this.messagesValue.invalid_time_range)
      return
    }

    this.selectedDays.forEach(day => {
      const existingIndex = this.addedHours.findIndex(h => h.day === day)
      if (existingIndex > -1) {
        this.addedHours[existingIndex] = { day, from: fromTime, to: toTime }
      } else {
        this.addedHours.push({ day, from: fromTime, to: toTime })
      }
    })

    this.updateHoursList()
    this.updateHiddenFields()

    // Reset selection
    this.selectedDays = []
    this.daySelectorTargets.forEach(el => {
      el.classList.remove('selected')
    })
    this.updateSelectionDisplay()
  }

  removeHour(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.addedHours.splice(index, 1)
    this.updateHoursList()
    this.updateHiddenFields()
  }

  updateHoursList() {
    if (this.addedHours.length === 0) {
      this.hoursListTarget.innerHTML = `<p class="text-sm text-base-content/60">${this.messagesValue.no_hours_added}</p>`
      return
    }

    const template = document.getElementById('hour-block-template')

    this.hoursListTarget.innerHTML = ''

    this.addedHours.forEach((hour, index) => {
      const clone = template.content.cloneNode(true)
      const fromFormatted = this.formatTimeForDisplay(hour.from)
      const toFormatted = this.formatTimeForDisplay(hour.to)

      clone.querySelector('.hour-display').textContent = `${this.dayNamesValue[hour.day]}: ${fromFormatted} - ${toFormatted}`
      clone.querySelector('.hour-remove-btn').dataset.index = index
      clone.querySelector('.hour-remove-btn').dataset.action = 'click->hours#removeHour'

      this.hoursListTarget.appendChild(clone)
    })
  }

  updateHiddenFields() {
    this.hiddenFieldsTarget.innerHTML = ''

    this.addedHours.forEach((hour, index) => {
      this.hiddenFieldsTarget.innerHTML += `
        <input type="hidden" name="place[place_hours_attributes][${index}][day_of_week]" value="${hour.day}">
        <input type="hidden" name="place[place_hours_attributes][${index}][from_hour]" value="${hour.from}">
        <input type="hidden" name="place[place_hours_attributes][${index}][to_hour]" value="${hour.to}">
      `
    })
  }

  formatTimeForDisplay(time24) {
    const hour = Math.floor(time24 / 100)
    const minute = time24 % 100
    const date = new Date()

    date.setHours(hour, minute)
    return date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true })
  }

  applyPreset(event) {
    const preset = event.currentTarget.dataset.preset
    this.addedHours = []

    switch(preset) {
      case '24hours':
        for (let day = 1; day <= 7; day++) {
          this.addedHours.push({ day, from: '0000', to: '2359' })
        }
        break
      case 'working':
        for (let day = 1; day <= 5; day++) {
          this.addedHours.push({ day, from: '0900', to: '1700' })
        }
        break
      case 'weekend':
        this.addedHours.push({ day: 6, from: '0900', to: '1700' })
        this.addedHours.push({ day: 7, from: '0900', to: '1700' })
        break
    }

    this.updateHoursList()
    this.updateHiddenFields()
  }

  rebuildHoursFromHiddenFields() {
    const hiddenInputs = this.hiddenFieldsTarget.querySelectorAll('input[type="hidden"]')
    const hoursData = {}

    hiddenInputs.forEach(input => {
      const match = input.name.match(/^place\[place_hours_attributes\]\[(\d+)\]\[(day_of_week|from_hour|to_hour)\]$/)
      if (match) {
        const index = match[1]
        const attribute = match[2]

        if (!hoursData[index]) {
          hoursData[index] = {}
        }

        hoursData[index][attribute] = input.value
      }
    })

    this.addedHours = Object.values(hoursData)
      .filter(hour => hour.day_of_week && hour.from_hour && hour.to_hour)
      .map(hour => ({
        day: parseInt(hour.day_of_week),
        from: hour.from_hour,
        to: hour.to_hour
      }))

    if (this.addedHours.length > 0) {
      this.updateHoursList()
    }
  }
}
