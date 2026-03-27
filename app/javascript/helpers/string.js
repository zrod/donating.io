/**
 * Capitalizes a given string
 * @param {string} string - String to capitalize
 * @returns {string} - Capitalized string, or an empty string if the input is empty or undefined.
 */
export function capitalize(string) {
    if (!string) {
        return "";
    }

    return string.charAt(0).toUpperCase() + string.slice(1);
}
