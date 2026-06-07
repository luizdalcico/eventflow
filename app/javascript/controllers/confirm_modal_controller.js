import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirm-modal"
// Modal padrão de confirmação do sistema. Substitui o confirm() nativo do Turbo,
// então qualquer `data-turbo-confirm="..."` passa a usar este modal.
export default class extends Controller {
  static targets = ["message", "confirmButton"]

  connect() {
    this.onClose = this.onClose.bind(this)
    this.element.addEventListener("close", this.onClose)
    if (window.Turbo) {
      window.Turbo.setConfirmMethod((message, _formElement, submitter) => this.ask(message, submitter))
    }
  }

  disconnect() {
    this.element.removeEventListener("close", this.onClose)
  }

  ask(message, submitter) {
    this.messageTarget.textContent = message
    // Permite customizar o rótulo do botão de confirmação via data-confirm-label.
    const label = submitter?.dataset?.confirmLabel
    if (this.hasConfirmButtonTarget) {
      this.confirmButtonTarget.textContent = label || "Confirmar"
    }
    this.result = false
    this.element.showModal()
    return new Promise((resolve) => { this.resolve = resolve })
  }

  confirm() {
    this.result = true
    this.element.close()
  }

  cancel() {
    this.element.close() // result permanece false
  }

  // Clique fora do card (no backdrop) cancela.
  backdrop(event) {
    if (event.target === this.element) this.element.close()
  }

  onClose() {
    if (this.resolve) {
      this.resolve(this.result)
      this.resolve = null
    }
  }
}
