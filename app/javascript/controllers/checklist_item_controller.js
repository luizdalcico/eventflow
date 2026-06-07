import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checklist-item"
// Auto-salva (debounce) a tarefa e aplica o risco ao marcar como concluída.
export default class extends Controller {
  static targets = ["task"]

  save() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.element.requestSubmit(), 500)
  }

  toggleAndSave(event) {
    const done = event.target.checked
    this.taskTarget.classList.toggle("line-through", done)
    this.taskTarget.classList.toggle("text-gray-400", done)
    this.save()
  }
}
