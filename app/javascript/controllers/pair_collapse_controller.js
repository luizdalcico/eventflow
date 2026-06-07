import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pair-collapse"
// Mostra/esconde os campos da linha no celular (no desktop ficam sempre visíveis).
// Ao adicionar uma nova linha (append no container alvo), colapsa as já existentes.
// Reutilizado por padrinhos (pairs_body) e convidados (guests_body).
export default class extends Controller {
  static targets = ["detail", "chevron"]
  static values = { appendTarget: { type: String, default: "pairs_body" } }

  connect() {
    this.onStream = (event) => {
      const stream = event.target
      if (stream.getAttribute("action") === "append" && stream.getAttribute("target") === this.appendTargetValue) {
        this.collapse()
      }
    }
    document.addEventListener("turbo:before-stream-render", this.onStream)
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.onStream)
  }

  toggle() {
    this.detailTargets.forEach((el) => {
      el.classList.toggle("hidden")
      el.classList.toggle("block")
    })
    if (this.hasChevronTarget) this.chevronTarget.classList.toggle("rotate-180")
  }

  collapse() {
    this.detailTargets.forEach((el) => {
      el.classList.add("hidden")
      el.classList.remove("block")
    })
    if (this.hasChevronTarget) this.chevronTarget.classList.remove("rotate-180")
  }
}
