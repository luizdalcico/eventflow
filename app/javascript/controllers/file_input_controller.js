import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-input"
// Esconde o input de arquivo nativo e mostra o nome do arquivo escolhido.
export default class extends Controller {
  static targets = ["input", "name"]

  display() {
    const file = this.inputTarget.files[0]
    this.nameTarget.textContent = file ? file.name : "Nenhum arquivo selecionado"
  }
}
