/**
 * Escapes HTML special characters in a string to prevent XSS attacks.
 * @param {*} text - The text to escape
 * @returns {string} - The escaped HTML string
 */
export function escapeHtml(text) {
  if (text == null) {
    return ""
  }
  const div = document.createElement("div")
  div.textContent = String(text)
  return div.innerHTML
}

/**
 * Gets the CSRF token from the meta tag.
 * @returns {string} - The CSRF token or empty string if not found
 */
export function getCSRFToken() {
  const token = document.querySelector('meta[name="csrf-token"]')
  return token ? token.getAttribute("content") : ""
}
