import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tooltip"]

  show(event) {
    const bar = event.currentTarget
    const label = bar.dataset.label
    const value = bar.dataset.value
    const tooltip = this.tooltipTarget

    tooltip.textContent = `${label}: ${value}`
    tooltip.classList.remove("hidden")

    const barRect = bar.getBoundingClientRect()
    const chartRect = this.element.getBoundingClientRect()
    tooltip.style.left = `${barRect.left - chartRect.left + barRect.width / 2}px`
    tooltip.style.top = `${barRect.top - chartRect.top - 8}px`
  }

  hide() {
    this.tooltipTarget.classList.add("hidden")
  }
}
