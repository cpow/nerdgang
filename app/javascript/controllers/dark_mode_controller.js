import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.applyTheme()
  }

  toggle() {
    const isDark = document.documentElement.classList.contains("dark")
    if (isDark) {
      this.setLight()
    } else {
      this.setDark()
    }
  }

  setDark() {
    document.documentElement.classList.add("dark")
    localStorage.setItem("theme", "dark")
    this.updateIcon()
  }

  setLight() {
    document.documentElement.classList.remove("dark")
    localStorage.setItem("theme", "light")
    this.updateIcon()
  }

  applyTheme() {
    const theme = localStorage.getItem("theme")

    // Default to dark mode if no preference is set
    if (theme === "light") {
      document.documentElement.classList.remove("dark")
    } else {
      document.documentElement.classList.add("dark")
      // Ensure the default is saved
      if (!theme) {
        localStorage.setItem("theme", "dark")
      }
    }

    this.updateIcon()
  }

  updateIcon() {
    if (!this.hasIconTarget) return

    const isDark = document.documentElement.classList.contains("dark")
    // Sun icon for dark mode (click to go light), Moon icon for light mode (click to go dark)
    this.iconTarget.innerHTML = isDark ? this.sunIcon : this.moonIcon
  }

  get sunIcon() {
    return `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
      <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386-1.591 1.591M21 12h-2.25m-.386 6.364-1.591-1.591M12 18.75V21m-4.773-4.227-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z" />
    </svg>`
  }

  get moonIcon() {
    return `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
      <path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.72 9.72 0 0 1 18 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 0 0 3 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 0 0 9.002-5.998Z" />
    </svg>`
  }
}
