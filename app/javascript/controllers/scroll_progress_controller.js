import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar"]

  connect() {
    this.updateProgress = this.updateProgress.bind(this)
    window.addEventListener("scroll", this.updateProgress, { passive: true })
    this.updateProgress()
  }

  disconnect() {
    window.removeEventListener("scroll", this.updateProgress)
  }

  updateProgress() {
    const scrollTop = window.scrollY
    const docHeight = document.documentElement.scrollHeight - window.innerHeight
    const progress = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0

    this.barTarget.style.width = `${Math.min(progress, 100)}%`
  }
}
