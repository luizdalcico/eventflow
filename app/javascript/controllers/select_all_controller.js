import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="select-all"
// Marca/desmarca todos os checkboxes de convidados de uma vez.
export default class extends Controller {
  static targets = ["item"]

  toggle(event) {
    this.itemTargets.forEach((item) => { item.checked = event.target.checked })
  }
}
