import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosave"
// Debounced Turbo submit on edit — generic auto-save.
// Can be attached to the form itself, or to a container (e.g. a table row)
// whose inputs point at the form via the HTML `form` attribute.
export default class extends Controller {
  save() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.form?.requestSubmit(), 500)
  }

  get form() {
    if (this.element instanceof HTMLFormElement) return this.element
    return this.element.querySelector("form")
  }
}
