import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bulkActions", "selectedCount", "row"]

  connect() {
    this.updateDisplay()
  }

  sort(event) {
    const column = event.currentTarget.dataset.column
    const currentSortBy = new URLSearchParams(window.location.search).get('sort_by')
    const currentOrder = new URLSearchParams(window.location.search).get('order')

    let newOrder = 'asc'
    if (currentSortBy === column && currentOrder === 'asc') {
      newOrder = 'desc'
    }

    const url = new URL(window.location)
    url.searchParams.set('sort_by', column)
    url.searchParams.set('order', newOrder)
    url.searchParams.set('page', '1')

    window.location.href = url.toString()
  }

  toggleAll(event) {
    const isChecked = event.target.checked
    const checkboxes = this.element.querySelectorAll('.place-checkbox')

    checkboxes.forEach(checkbox => {
      checkbox.checked = isChecked
    })

    this.updateDisplay()
  }

  toggleRow() {
    this.updateDisplay()
    this.updateSelectAllState()
  }

  clearSelection() {
    const checkboxes = this.element.querySelectorAll('.place-checkbox')
    const selectAllCheckbox = this.element.querySelector('input[name="select_all"]')

    checkboxes.forEach(checkbox => {
      checkbox.checked = false
    })

    if (selectAllCheckbox) {
      selectAllCheckbox.checked = false
      selectAllCheckbox.indeterminate = false
    }

    this.updateDisplay()
  }

  getSelectedIds() {
    const checkedBoxes = this.element.querySelectorAll('.place-checkbox:checked')
    return Array.from(checkedBoxes).map(cb => cb.value)
  }

  updateDisplay() {
    if (!this.hasBulkActionsTarget || !this.hasSelectedCountTarget) {
      return
    }

    const checkedBoxes = this.element.querySelectorAll('.place-checkbox:checked')
    const count = checkedBoxes.length

    if (count > 0) {
      this.bulkActionsTarget.style.display = 'block'
      this.selectedCountTarget.textContent = `${count} place${count === 1 ? '' : 's'} selected`
    } else {
      this.bulkActionsTarget.style.display = 'none'
    }
  }

  updateSelectAllState() {
    const selectAllCheckbox = this.element.querySelector('input[name="select_all"]')
    if (!selectAllCheckbox) {
      return
    }

    const checkboxes = this.element.querySelectorAll('.place-checkbox')
    const checkedBoxes = this.element.querySelectorAll('.place-checkbox:checked')

    selectAllCheckbox.checked = checkboxes.length === checkedBoxes.length
    selectAllCheckbox.indeterminate = checkedBoxes.length > 0 && checkedBoxes.length < checkboxes.length
  }

  bulkDelete(event) {
    event.preventDefault()

    const selectedIds = this.getSelectedIds()
    const form = document.getElementById('bulk-delete-form')

    if (selectedIds.length === 0 || !form) {
      return
    }

    form.querySelectorAll('input[name="place_ids[]"]').forEach(input => input.remove())

    selectedIds.forEach(id => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'place_ids[]'
      input.value = id
      form.appendChild(input)
    })

    form.requestSubmit()
  }
}
