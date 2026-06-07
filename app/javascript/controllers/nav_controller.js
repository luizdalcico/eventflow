import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nav"
// Abre/fecha o menu de navegação no mobile (hamburguer).
export default class extends Controller {
  static targets = ["menu", "open", "close"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    if (this.hasOpenTarget) this.openTarget.classList.toggle("hidden")
    if (this.hasCloseTarget) this.closeTarget.classList.toggle("hidden")
  }
}
