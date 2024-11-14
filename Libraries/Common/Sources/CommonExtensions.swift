//
// CommonExtensions.swift
//

import Foundation

// MARK: - String Extensions

public extension String {
  /// Checks if the string is a valid email address
  var isValidEmail: Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: self)
  }

  /// Removes whitespace and newlines from both ends of the string
  var trimmed: String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// Checks if the string contains only digits
  var isNumeric: Bool {
    !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
  }

  /// Capitalizes first letter of each word in the string
  var capitalizedWords: String {
    components(separatedBy: .whitespaces)
      .map(\.capitalized)
      .joined(separator: " ")
  }
}
