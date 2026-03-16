import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  switchRevision(event) {
    const revisionId = event.target.value
    const url = new URL(window.location)
    url.searchParams.set("revision_id", revisionId)
    Turbo.visit(url.toString(), { frame: "documentation-frame" })
  }
}