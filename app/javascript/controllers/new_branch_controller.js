import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  create(event) {
    event.preventDefault()
    const branchName = prompt("New branch name (e.g. feature/user-auth or release/v2):", "feature/")
    if (!branchName || branchName.trim() === "") return

    const url = new URL(window.location)
    url.searchParams.set("branch", branchName.trim())
    Turbo.visit(url.toString())
  }
}