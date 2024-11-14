//
// CommonExtensionsTests.swift
//

import Common
import Testing

@Suite("Common Extensions Tests")
struct CommonExtensionsTests {
  @Test("Email validation - valid emails")
  func testValidEmails() {
    // Given
    let validEmails = [
      "test@example.com",
      "user.name@domain.com",
      "user+label@domain.co.uk",
    ]

    // Then
    for email in validEmails {
      #expect(email.isValidEmail)
    }
  }

  @Test("Email validation - invalid emails")
  func testInvalidEmails() {
    // Given
    let invalidEmails = [
      "not-an-email",
      "@missing-username.com",
      "missing-domain@",
      "spaces in@email.com",
      "missing.domain@.com",
    ]

    // Then
    for email in invalidEmails {
      #expect(!email.isValidEmail)
    }
  }

  @Test("String trimming")
  func testTrimming() {
    // Given
    let stringsToTrim = [
      ("  hello  ", "hello"),
      ("\n\ntest\n", "test"),
      (" mixed \n spaces ", "mixed \n spaces"),
      ("no-trim-needed", "no-trim-needed"),
    ]

    // Then
    for (input, expected) in stringsToTrim {
      #expect(input.trimmed == expected)
    }
  }

  @Test("Numeric string validation")
  func testNumericStrings() {
    // Given
    let numericTests = [
      ("123", true),
      ("0", true),
      ("12.34", false),
      ("abc", false),
      ("123abc", false),
      ("", false),
    ]

    // Then
    for (input, expected) in numericTests {
      #expect(input.isNumeric == expected)
    }
  }

  @Test("Word capitalization")
  func testWordCapitalization() {
    // Given
    let capitalizationTests = [
      ("hello world", "Hello World"),
      ("ALREADY CAPS", "Already Caps"),
      ("mixed CASE text", "Mixed Case Text"),
      ("single", "Single"),
    ]

    // Then
    for (input, expected) in capitalizationTests {
      #expect(input.capitalizedWords == expected)
    }
  }
}
