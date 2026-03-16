import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { duration: Number }
    static targets = ["message"]

    connect() {
        this.startTimer()
        this.element.addEventListener("mouseenter", this.pauseBound = () => this.pause())
        this.element.addEventListener("mouseleave", this.resumeBound = () => this.resume())
    }

    disconnect() {
        this.clearTimer()
        this.element.removeEventListener("mouseenter", this.pauseBound)
        this.element.removeEventListener("mouseleave", this.resumeBound)
    }

    startTimer() {
        const ms = this.durationValue || 5000
        this.clearTimer()
        this.timer = setTimeout(() => this.dismissAll(), ms)
    }

    clearTimer() {
        if (this.timer) {
            clearTimeout(this.timer)
            this.timer = null
        }
    }

    pause() { this.clearTimer() }
    resume() { this.startTimer() }

    // Called from the close button: data-action="click->flash#close"
    close(event) {
        event.preventDefault()
        const target = event.currentTarget.closest("[data-flash-target='message']")
        if (target) target.remove()
        // restart timer for remaining messages
        if (this.messageTargets.length > 0) this.startTimer()
    }

    dismissAll() {
        this.messageTargets.forEach((m) => m.remove())
    }
}