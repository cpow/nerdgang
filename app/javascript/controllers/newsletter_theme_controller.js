import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body"]

  connect() {
    this.loadTheme()
  }

  loadTheme() {
    const savedTheme = localStorage.getItem("newsletter-theme")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches

    if (savedTheme) {
      this.setTheme(savedTheme)
    } else if (prefersDark) {
      this.setTheme("dark")
    } else {
      this.setTheme("light")
    }
  }

  toggle() {
    const currentTheme = document.documentElement.getAttribute("data-theme")
    const newTheme = currentTheme === "dark" ? "light" : "dark"
    this.setTheme(newTheme)
    localStorage.setItem("newsletter-theme", newTheme)
  }

  setTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
  }
}
