import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nested-owners"
// Adiciona/remove linhas de "Responsáveis pelo Evento" (nested attributes),
// funcionando após navegações do Turbo (não depende de DOMContentLoaded).
export default class extends Controller {
  static targets = ["container", "template"]
  static values = { index: Number }

  connect() {
    this.updateRemoveButtons()
  }

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/__INDEX__/g, this.indexValue)
    this.containerTarget.insertAdjacentHTML("beforeend", html)
    this.indexValue++
    this.updateRemoveButtons()
  }

  remove(event) {
    event.preventDefault()
    const row = event.target.closest(".event-owner-fields")
    const destroyField = row.querySelector('input[name*="[_destroy]"]')

    if (destroyField) {
      // Registro existente: marca para exclusão e oculta a linha.
      destroyField.value = "1"
      row.style.display = "none"
    } else {
      // Registro novo: remove do DOM.
      row.remove()
    }
    this.updateRemoveButtons()
  }

  updateRemoveButtons() {
    const rows = [...this.containerTarget.querySelectorAll(".event-owner-fields")]
      .filter((r) => r.style.display !== "none")
    rows.forEach((row) => {
      const btn = row.querySelector(".remove-owner")
      if (btn) btn.style.display = rows.length > 1 ? "block" : "none"
    })
  }
}
