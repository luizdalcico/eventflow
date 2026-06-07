import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cpf-lookup"
// Ao digitar um CPF completo (11 dígitos), busca um responsável já cadastrado
// com aquele CPF e preenche os campos vazios do formulário com os dados dele.
// O CPF é a chave: o mesmo cliente é reutilizado entre eventos.
export default class extends Controller {
  static values = { url: String }
  static targets = ["cpf", "field"]

  connect() {
    this.lastLookup = null
  }

  // Disparado no input/blur do campo de CPF.
  async lookup() {
    const digits = this.cpfTarget.value.replace(/\D/g, "")
    if (digits.length !== 11 || digits === this.lastLookup) return

    this.lastLookup = digits

    let data
    try {
      const response = await fetch(`${this.urlValue}?cpf=${digits}`, {
        headers: { Accept: "application/json" }
      })
      if (!response.ok) return
      data = await response.json()
    } catch (_e) {
      return // silencioso: falha de rede não atrapalha o preenchimento manual
    }

    if (!data?.found) return
    this.fillEmptyFields(data.owner)
  }

  // Preenche apenas os campos ainda vazios — nunca sobrescreve o que o usuário já digitou.
  fillEmptyFields(owner) {
    this.fieldTargets.forEach((field) => {
      const key = field.dataset.cpfLookupField
      const value = owner?.[key]
      if (value && !field.value) {
        field.value = value
        field.dispatchEvent(new Event("input", { bubbles: true }))
      }
    })
  }
}
