import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab"]
  static values = { form: String }

  switch(event) {
    const mode = this.formValue

    // Update URL without full navigation
    const url = new URL(window.location)
    url.searchParams.set("mode", mode)

    // Trigger Turbo to reload the frame with new mode
    Turbo.visit(url.toString(), {
      action: "replace",
      frame: "revision-form"   // <-- this is the key: target the frame
    })

    // Optional: visually update active tab (CSS handles most of it)
    this.element.querySelectorAll("[data-action^='click->tab#switch']").forEach(btn => {
      btn.classList.remove("border-b-2", "border-emerald-500", "text-emerald-400")
      btn.classList.add("text-zinc-400", "hover:text-zinc-200")
    })
    this.tabTarget.classList.add("border-b-2", "border-emerald-500", "text-emerald-400")
    this.tabTarget.classList.remove("text-zinc-400", "hover:text-zinc-200")
  }
}