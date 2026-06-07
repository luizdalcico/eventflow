import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
// Copia o conteúdo do input alvo para a área de transferência.
export default class extends Controller {
  static targets = ["source", "label"]

  copy(event) {
    event.preventDefault()
    const text = this.sourceTarget.value

    // Seleciona o texto (dá feedback visual e habilita o fallback).
    this.sourceTarget.focus()
    this.sourceTarget.select()
    this.sourceTarget.setSelectionRange(0, text.length)

    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(() => this.flash()).catch(() => this.fallback())
    } else {
      this.fallback()
    }
  }

  fallback() {
    try {
      const ok = document.execCommand("copy")
      if (ok) this.flash()
    } catch (_e) {
      // Sem suporte a cópia automática — o texto já está selecionado para cópia manual.
    }
  }

  flash() {
    if (!this.hasLabelTarget) return
    const original = this.labelTarget.textContent
    this.labelTarget.textContent = "Copiado!"
    setTimeout(() => { this.labelTarget.textContent = original }, 1500)
  }
}
