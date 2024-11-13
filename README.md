# iOS Project Template with Tuist + TCA

Ready-to-use template for iOS apps using Tuist for project management and The Composable Architecture (TCA) for state management.

## Setup

1. Install required tools:
```bash
# Install mise (manages tool versions)
curl https://mise.jdx.dev/install.sh | sh

# Install project dependencies
make bootstrap
```

2. Generate the Xcode project:
```bash
make generate
```

## Project Structure

```
TCATuistBoilerplate/     # Main app
├── Sources/             # App source code
└── Resources/           # Assets, etc.

Features/               # Feature modules
├── ListScreen/         # Example feature
│   ├── Sources/        # Implementation
│   ├── Interface/      # Public API
│   ├── Testing/        # Test helpers
│   └── Tests/          # Unit tests
└── [Other Features]/   # Same structure

Tuist/                 # Project generation
├── Templates/         # Feature templates
└── ProjectDescriptionHelpers/  # Shared config
```

## Feature Template

The template generates a complete feature module with:

### Generated Files
- `Project.swift` - Feature module configuration
- `Sources/`
  - `[Feature]Feature.swift` - TCA reducer & logic
  - `[Feature]View.swift` - Main SwiftUI view
  - `[Feature]ItemView.swift` - List item view
  - `[Feature]Client.swift` - API client
- `Interface/Sources/[Feature]Interface.swift` - Public API
- `Testing/Sources/[Feature]Testing.swift` - Test helpers
- `Tests/[Feature]Tests.swift` - Unit tests

### Using the Template

1. Generate feature:
```bash
tuist scaffold feature --name YourFeature
```

2. Add to main app's dependencies in `TCATuistBoilerplate/Project.swift`:
```swift
dependencies: [
  .project(target: "YourFeature", path: "../Features/YourFeature")
]
```

## Common Tasks

### Update Dependencies

```bash
make update
```

### Run Tests

```bash
# All tests
make test

# Just unit tests
make unit_test
```

### Format Code

```bash
make format
```

### Clean Build Files

```bash
make clean
```

## Pre-commit Hooks

The project includes pre-commit hooks for code formatting. Install them:

```bash
pip install pre-commit
pre-commit install
```

## Tools & Versions

- Tuist: 4.33.0
- SwiftLint: 0.54.0
- SwiftFormat: 0.53.3

All tool versions are managed by mise and defined in `.mise.toml`.
