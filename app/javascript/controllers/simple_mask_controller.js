import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="simple-mask"
export default class extends Controller {
  static values = { pattern: String }

  connect() {
    this.element.addEventListener('input', this.handleInput.bind(this))
    this.element.addEventListener('keydown', this.handleKeydown.bind(this))
    this.formatExisting()
  }

  // Formata o valor já preenchido ao carregar (ex.: telefone vindo do banco).
  formatExisting() {
    const digits = this.element.value.replace(/\D/g, '')
    if (!digits) return
    if (this.patternValue === '(00) 00000-0000') this.element.value = this.formatPhone(digits)
    else if (this.patternValue === '000.000.000-00') this.element.value = this.formatCpf(digits)
  }

  disconnect() {
    this.element.removeEventListener('input', this.handleInput.bind(this))
    this.element.removeEventListener('keydown', this.handleKeydown.bind(this))
  }

  handleInput(event) {
    const pattern = this.patternValue
    if (!pattern) return

    const digits = event.target.value.replace(/\D/g, '')
    let maskedValue = event.target.value

    if (pattern === '(00) 00000-0000') {
      maskedValue = this.formatPhone(digits)
    } else if (pattern === '000.000.000-00') {
      maskedValue = this.formatCpf(digits)
    }

    if (maskedValue !== event.target.value) {
      event.target.value = maskedValue
    }
  }

  // Telefone BR: fixo (10 díg.) "(XX) XXXX-XXXX" e celular (11 díg.) "(XX) XXXXX-XXXX".
  formatPhone(digits) {
    digits = digits.substring(0, 11)
    const len = digits.length
    if (len === 0) return ''
    if (len < 3) return `(${digits}`
    if (len <= 6) return `(${digits.slice(0, 2)}) ${digits.slice(2)}`
    if (len <= 10) return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}-${digits.slice(6)}`
    return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7)}`
  }

  formatCpf(digits) {
    digits = digits.substring(0, 11)
    const len = digits.length
    if (len <= 3) return digits
    if (len <= 6) return `${digits.slice(0, 3)}.${digits.slice(3)}`
    if (len <= 9) return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6)}`
    return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9)}`
  }

  handleKeydown(event) {
    // Allow backspace, delete, tab, escape, enter
    if ([8, 9, 27, 13, 46].indexOf(event.keyCode) !== -1 ||
        // Allow Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X
        (event.keyCode === 65 && event.ctrlKey === true) ||
        (event.keyCode === 67 && event.ctrlKey === true) ||
        (event.keyCode === 86 && event.ctrlKey === true) ||
        (event.keyCode === 88 && event.ctrlKey === true) ||
        // Allow home, end, left, right
        (event.keyCode >= 35 && event.keyCode <= 39)) {
      return
    }
    // Ensure that it is a number and stop the keypress
    if ((event.shiftKey || (event.keyCode < 48 || event.keyCode > 57)) && (event.keyCode < 96 || event.keyCode > 105)) {
      event.preventDefault()
    }
  }
}