import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="simple-document-mask"
export default class extends Controller {
  connect() {
    console.log("Simple document mask controller connected", this.element)
    this.element.addEventListener('input', this.handleInput.bind(this))
    this.element.addEventListener('keydown', this.handleKeydown.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('input', this.handleInput.bind(this))
    this.element.removeEventListener('keydown', this.handleKeydown.bind(this))
  }

  handleInput(event) {
    let value = event.target.value.replace(/\D/g, '')
    let maskedValue = value

    if (value.length <= 11) {
      // CPF format
      if (value.length > 11) {
        value = value.substring(0, 11)
      }
      
      if (value.length >= 3) {
        maskedValue = value.substring(0, 3)
        if (value.length > 3) {
          maskedValue += '.' + value.substring(3, 6)
          if (value.length > 6) {
            maskedValue += '.' + value.substring(6, 9)
            if (value.length > 9) {
              maskedValue += '-' + value.substring(9, 11)
            }
          }
        }
      }
    } else {
      // CNPJ format
      if (value.length > 14) {
        value = value.substring(0, 14)
      }
      
      if (value.length >= 2) {
        maskedValue = value.substring(0, 2)
        if (value.length > 2) {
          maskedValue += '.' + value.substring(2, 5)
          if (value.length > 5) {
            maskedValue += '.' + value.substring(5, 8)
            if (value.length > 8) {
              maskedValue += '/' + value.substring(8, 12)
              if (value.length > 12) {
                maskedValue += '-' + value.substring(12, 14)
              }
            }
          }
        }
      }
    }

    if (maskedValue !== event.target.value) {
      event.target.value = maskedValue
    }
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