import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="guest-row"
// Auto-salva a linha do convidado (nome, pessoas, telefone, observações) ao editar.
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.timer = null
  }

  disconnect() {
    if (this.timer) clearTimeout(this.timer)
  }

  save() {
    if (this.timer) clearTimeout(this.timer)
    this.timer = setTimeout(() => this.submit(), 600)
  }

  async submit() {
    const params = new URLSearchParams()
    this.element.querySelectorAll('[name^="guest["]').forEach((el) => {
      params.append(el.name, el.value)
    })

    try {
      await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: params
      })
    } catch (_e) {
      // silencioso
    }
  }
}
