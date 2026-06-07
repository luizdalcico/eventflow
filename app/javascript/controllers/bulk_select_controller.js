import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bulk-select"
// Barra contextual: mostra a contagem de selecionados e revela as ações de
// envio só quando há pelo menos um convidado marcado.
export default class extends Controller {
  static targets = ["bar", "default", "count", "checkbox"]

  connect() {
    this.refresh()
  }

  refresh() {
    const n = this.checkboxTargets.filter((c) => c.checked).length
    if (this.hasCountTarget) this.countTarget.textContent = n

    const active = n > 0
    if (this.hasBarTarget) this.barTarget.classList.toggle("hidden", !active)
    if (this.hasDefaultTarget) this.defaultTarget.classList.toggle("hidden", active)
  }

  clear() {
    this.checkboxTargets.forEach((c) => { c.checked = false })
    this.refresh()
  }
}
