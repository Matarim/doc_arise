import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.toggle.bind(this))
  }

  toggle(e) {
    const dropdown = document.getElementById("org-dropdown")
    dropdown.classList.toggle("hidden")
    e.stopPropagation()
  }
}