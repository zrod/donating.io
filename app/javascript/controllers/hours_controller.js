import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["daySelector", "fromTime", "toTime", "selectionInfo", "hoursList", "hiddenFields"]

  connect() {
    this.selectedDays = []
    this.addedHours = []
    this.updateSelectionDisplay()

    // Set default times
    this.fromTimeTarget.value = '0900'
    this.toTimeTarget.value = '1700'
  }

  toggleDay(event) {
    const element = event.currentTarget
    const day = parseInt(element.dataset.day)
    const index = this.selectedDays.indexOf(day)

    if (index > -1) {
      // Remove from selection
      this.selectedDays.splice(index, 1)
      element.classList.remove('selected')
    } else {
      // Add to selection
      this.selectedDays.push(day)
      element.classList.add('selected')
    }

    // Update visual feedback
    this.updateSelectionDisplay()
  }

  updateSelectionDisplay() {
    if (this.selectedDays.length === 0) {
      this.selectionInfoTarget.textContent = 'Select days to add hours'
      this.selectionInfoTarget.className = 'text-sm text-base-content/60 mt-2'
    } else {
      const dayNames = {
        1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'
      }
      const selectedDayNames = this.selectedDays.sort().map(day => dayNames[day]).join(', ')
      this.selectionInfoTarget.textContent = `Selected: ${selectedDayNames}`
      this.selectionInfoTarget.className = 'text-sm text-primary font-medium mt-2'
    }
  }

  includeSelectedHours() {
    const fromTime = this.fromTimeTarget.value
    const toTime = this.toTimeTarget.value

    if (this.selectedDays.length === 0) {
      alert('Please select at least one day')
      return
    }

    if (parseInt(fromTime) >= parseInt(toTime)) {
      alert('From time must be before to time')
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
      this.hoursListTarget.innerHTML = '<p class="text-sm text-base-content/60">No hours added yet</p>'
      return
    }

    const dayNames = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday'
    }

    this.hoursListTarget.innerHTML = this.addedHours.map((hour, index) => {
      const fromFormatted = this.formatTimeForDisplay(hour.from)
      const toFormatted = this.formatTimeForDisplay(hour.to)
      return `
        <div class="flex justify-between items-center p-3 bg-base-200 rounded-lg">
          <span>${dayNames[hour.day]}: ${fromFormatted} - ${toFormatted}</span>
          <button type="button" class="btn btn-sm btn-ghost" data-index="${index}" data-action="click->hours#removeHour">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      `
    }).join('')
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
}
