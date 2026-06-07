import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
// Mostra um painel por vez e destaca a aba ativa.
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: String }

  connect() {
    this.show(this.activeValue || this.tabTargets[0]?.dataset.tabsName)
  }

  select(event) {
    this.show(event.currentTarget.dataset.tabsName)
  }

  show(name) {
    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.tabsName !== name)
    })
    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.tabsName === name
      tab.classList.toggle("border-blue-600", active)
      tab.classList.toggle("text-blue-600", active)
      tab.classList.toggle("border-transparent", !active)
      tab.classList.toggle("text-gray-500", !active)
      tab.setAttribute("aria-selected", active)
    })
  }
}
