import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { subscribed: Boolean }

  connect() {
    if (this.subscribedValue) {
      localStorage.setItem("power_dev_subscribed", "true")
    } else if (localStorage.getItem("power_dev_subscribed")) {
      this.element.innerHTML = '<p class="nl-subscribed-message">You\'re subscribed! Thanks, nerd.</p>'
    }
  }
}
