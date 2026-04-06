import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  switchBranch(event) {
    const branch = event.target.value
    const url = new URL(window.location)
    url.searchParams.set("branch", branch)
    Turbo.visit(url.toString())
  }
}