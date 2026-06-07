import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="contract-modal"
// Bloqueia o download do contrato quando faltam campos: ao clicar no gatilho,
// abre o <dialog> listando os pendentes em vez de navegar para o PDF.
export default class extends Controller {
  static targets = ["dialog"]

  open(event) {
    event.preventDefault()
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  // Clique no backdrop (fora do card) fecha o modal.
  backdrop(event) {
    if (event.target === this.dialogTarget) this.dialogTarget.close()
  }
}
