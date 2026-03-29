import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  enterEdit() {
    const url = new URL(window.location)
    url.searchParams.set("edit_mode", "true")
    const enterBtn = document.getElementById("enter-edit-mode")
    const exitBtn = document.getElementById("exit-edit-mode")
    enterBtn.classList.toggle("hidden")
    exitBtn.classList.toggle("hidden")

    Turbo.visit(url.toString(), { frame: "spec-content" })
  }

  exitEdit() {
    const url = new URL(window.location)
    url.searchParams.delete("edit_mode")
    const enterBtn = document.getElementById("enter-edit-mode")
    const exitBtn = document.getElementById("exit-edit-mode")
    enterBtn.classList.toggle("hidden")
    exitBtn.classList.toggle("hidden")

    Turbo.visit(url.toString(), { frame: "spec-content" })
  }
}