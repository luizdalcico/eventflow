import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="godparent-row"
// Auto-salva a linha (par) ao editar uma célula: junta os campos `pair[...]` da
// linha e envia um PATCH com debounce. Nenhuma lib de terceiros.
export default class extends Controller {
  static values = { id: Number, token: String }

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
    // Só os campos do par (exclui o form do botão remover).
    this.element.querySelectorAll('[name^="pair["]').forEach((el) => {
      params.append(el.name, el.value)
    })

    try {
      await fetch(`/padrinhos/${this.tokenValue}/pairs/${this.idValue}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: params
      })
    } catch (_e) {
      // silencioso: a pessoa continua editando; tenta de novo no próximo change.
    }
  }
}
