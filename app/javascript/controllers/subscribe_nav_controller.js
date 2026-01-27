import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (localStorage.getItem("power_dev_subscribed")) {
      this.element.remove()
    }
  }
}
