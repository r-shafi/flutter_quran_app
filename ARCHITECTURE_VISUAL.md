# Clean Architecture - Visual Guide

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Pages, Widgets, UI Components                            │  │
│  │  - Displays data                                          │  │
│  │  - Handles user interactions                              │  │
│  │  - Future: BLoC/Cubit state management                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Business Logic (Pure Dart, No Flutter Dependencies)     │  │
│  │  - Entities (business objects)                            │  │
│  │  - Use Cases (business operations)                        │  │
│  │  - Repository Interfaces                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Data Sources & Repository Implementations                │  │
│  │  - Models (data transfer objects)                         │  │
│  │  - API clients                                            │  │
│  │  - Database access                                        │  │
│  │  - Repository implementations                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Dependency Rule

```
┌─────────────────────────────────────────────────────────┐
│  Dependencies point INWARD                              │
│                                                          │
│  Presentation ──────────┐                              │
│       │                  ▼                              │
│       └─────────────▶ Domain ◀──────┐                  │
│                                      │                  │
│                        Data ─────────┘                  │
│                                                          │
│  ✅ Presentation can import Domain                      │
│  ✅ Data can import Domain                              │
│  ❌ Domain cannot import Presentation or Data           │
└─────────────────────────────────────────────────────────┘
```

## Feature Structure

```
features/
  └── quran/                    # Feature name
      ├── presentation/         # UI Layer
      │   ├── pages/           # Full screens
      │   │   └── quran.dart
      │   ├── widgets/         # Reusable UI components
      │   └── bloc/            # State management (future)
      │
      ├── domain/              # Business Logic Layer
      │   ├── entities/        # Core business objects
      │   ├── usecases/        # Business operations
      │   └── repositories/    # Repository interfaces
      │
      └── data/                # Data Layer
          ├── models/          # Data transfer objects
          │   ├── surah_list.dart
          │   └── surah_content.dart
          ├── datasources/     # API/DB clients
          └── repositories/    # Repository implementations
```

## Data Flow Example

### Reading Quran Surahs

```
┌──────────────┐
│   User       │
│   Action     │
└──────┬───────┘
       │
       ▼
┌─────────────────────────────────────────────┐
│  PRESENTATION: quran.dart                   │
│  - User taps on Surah                       │
│  - Calls fetchSurahContent()                │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  DATA: Fetches from API                     │
│  - http.get('api.alquran.cloud/...')       │
│  - Converts JSON to SurahContentModel       │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  PRESENTATION: Displays Surah               │
│  - Shows verses                             │
│  - Enables audio playback                   │
└─────────────────────────────────────────────┘
```

### Future Flow (with BLoC & Repository)

```
┌──────────────┐
│   User       │
│   Action     │
└──────┬───────┘
       │
       ▼
┌─────────────────────────────────────────────┐
│  PRESENTATION: QuranPage (Widget)           │
│  - User taps on Surah                       │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  PRESENTATION: QuranBloc                    │
│  - Receives LoadSurahEvent                  │
│  - Calls GetSurahUseCase                    │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  DOMAIN: GetSurahUseCase                    │
│  - Business logic validation                │
│  - Calls QuranRepository                    │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  DATA: QuranRepositoryImpl                  │
│  - Checks cache                             │
│  - Calls RemoteDataSource                   │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  DATA: RemoteDataSource                     │
│  - Makes API call                           │
│  - Returns SurahModel                       │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
         Data flows back up
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  PRESENTATION: QuranPage                    │
│  - Receives SurahLoadedState                │
│  - Renders UI with data                     │
└─────────────────────────────────────────────┘
```

## Testing Strategy

```
┌─────────────────────────────────────────────────────────┐
│  UNIT TESTS                                             │
│  ├─ Domain Layer Tests (Use Cases)                     │
│  │  - Test business logic                              │
│  │  - Mock repositories                                │
│  │                                                      │
│  ├─ Data Layer Tests (Repositories)                    │
│  │  - Test data transformations                        │
│  │  - Mock data sources                                │
│  │                                                      │
│  └─ Presentation Layer Tests (BLoCs)                   │
│     - Test state transitions                           │
│     - Mock use cases                                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  WIDGET TESTS                                           │
│  - Test individual widgets                              │
│  - Mock BLoCs                                           │
│  - Verify UI behavior                                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  INTEGRATION TESTS                                      │
│  - Test complete user flows                             │
│  - Test with real dependencies                          │
│  - Verify end-to-end scenarios                          │
└─────────────────────────────────────────────────────────┘
```

## Benefits Summary

```
┌────────────────────────────────────────────────────────────┐
│  BEFORE                        AFTER                       │
├────────────────────────────────────────────────────────────┤
│  Mixed concerns               Clean separation             │
│  Hard to test                 Easily testable             │
│  Difficult to scale          Scales naturally             │
│  Tight coupling              Loose coupling               │
│  No clear structure          Feature-based modules        │
└────────────────────────────────────────────────────────────┘
```

## Quick Tips

### ✅ DO:
- Keep domain layer pure (no Flutter dependencies)
- Use dependency injection (future)
- Write tests for each layer
- Follow consistent naming conventions
- Document complex business logic

### ❌ DON'T:
- Import presentation in domain layer
- Put business logic in widgets
- Skip the domain layer for "simple" features
- Mix data models with domain entities
- Tightly couple layers

---

**For More Information:**
- See `lib/ARCHITECTURE.md` for detailed documentation
- See `MIGRATION.md` for migration guide
- See `ROADMAP.md` for future plans
