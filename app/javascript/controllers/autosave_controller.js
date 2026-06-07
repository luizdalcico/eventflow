import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosave"
// Submete o form (Turbo) com debounce ao editar — auto-save genérico.
export default class extends Controller {
  save() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.element.requestSubmit(), 500)
  }
}
