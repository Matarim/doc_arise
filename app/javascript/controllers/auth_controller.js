// app/javascript/controllers/auth_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]

  switchToSignUp() {
    this.frameTarget.src = "/sign-up"
  }

  switchToSignIn() {
    this.frameTarget.src = "/sign-in"
  }
}