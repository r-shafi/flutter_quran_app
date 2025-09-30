# Clean Architecture Implementation

This document describes the Clean Architecture structure implemented in the Flutter Quran App.

## Folder Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── theme/             # Theme and styling
│   ├── utils/             # Utility functions
│   ├── errors/            # Error handling
│   ├── network/           # Network utilities
│   └── presentation/      # Core/shared UI components
│       └── pages/         # App-level pages (e.g., Home)
│
├── features/              # Feature modules
│   ├── quran/
│   │   ├── presentation/  # UI layer (widgets, pages, state)
│   │   │   ├── pages/     # Quran-related pages
│   │   │   └── widgets/   # Quran-related widgets
│   │   ├── domain/        # Business logic layer
│   │   │   ├── entities/  # Core business objects
│   │   │   ├── usecases/  # Business use cases
│   │   │   └── repositories/ # Repository interfaces
│   │   └── data/          # Data layer
│   │       ├── models/    # Data models
│   │       ├── datasources/ # API clients, local DB
│   │       └── repositories/ # Repository implementations
│   │
│   ├── prayer_times/
│   │   ├── presentation/
│   │   │   └── widgets/
│   │   ├── domain/
│   │   └── data/
│   │       └── models/
│   │
│   ├── audio/
│   │   ├── presentation/
│   │   │   └── pages/
│   │   ├── domain/
│   │   └── data/
│   │       └── models/
│   │
│   ├── bookmarks/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   └── settings/
│       ├── presentation/
│       │   ├── pages/
│       │   └── widgets/
│       ├── domain/
│       └── data/
│
└── main.dart

```

## Layer Responsibilities

### 1. Presentation Layer
- **Location**: `features/*/presentation/`
- **Responsibility**: UI components, user interactions, state management
- **Contents**:
  - Pages: Full screen views
  - Widgets: Reusable UI components
  - State management (when implemented: BLoCs/Cubits)

### 2. Domain Layer
- **Location**: `features/*/domain/`
- **Responsibility**: Business logic, independent of UI and data sources
- **Contents**:
  - Entities: Core business objects
  - Use cases: Single-purpose business operations
  - Repository interfaces: Contracts for data access

### 3. Data Layer
- **Location**: `features/*/data/`
- **Responsibility**: Data retrieval and storage
- **Contents**:
  - Models: Data transfer objects
  - Data sources: API clients, database access
  - Repository implementations: Concrete implementations of domain repositories

### 4. Core Layer
- **Location**: `core/`
- **Responsibility**: Shared utilities, constants, and configurations
- **Contents**:
  - Constants: App-wide constant values
  - Theme: Styling and theming
  - Utils: Helper functions
  - Errors: Error handling
  - Network: Network-related utilities

## Benefits

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Testability**: Layers can be tested independently
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features following the same structure
5. **Team Collaboration**: Clear structure helps multiple developers work together

## Migration Status

✅ **Completed:**
- Created folder structure following Clean Architecture
- Moved models to data layer
- Organized pages and widgets by feature
- Updated all imports

⏳ **Future Work:**
- Implement domain entities
- Create use cases
- Add repository interfaces and implementations
- Migrate to BLoC state management
- Add dependency injection

## Guidelines

### Adding a New Feature
1. Create feature folder in `features/`
2. Add subfolders: `presentation/`, `domain/`, `data/`
3. Implement from domain to data to presentation
4. Keep dependencies pointing inward (presentation → domain ← data)

### Importing Files
- Use absolute imports for cross-feature dependencies
- Use relative imports within the same feature
- Never import from presentation in domain or data layers
