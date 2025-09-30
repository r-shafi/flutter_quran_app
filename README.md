# Flutter Quran App

This app is built with Flutter. It is a simple app that shows todays prayer times and can be used to play Quran recitations.

All of the data used in this app comes from public API's.

## Architecture

This app follows **Clean Architecture** principles with clear separation of concerns:

- **Presentation Layer**: UI components (pages, widgets)
- **Domain Layer**: Business logic (entities, use cases, repository interfaces)
- **Data Layer**: Data sources (API clients, models, repository implementations)

For detailed architecture documentation, see [ARCHITECTURE.md](lib/ARCHITECTURE.md).

### Project Structure

```
lib/
├── core/               # Shared utilities and components
│   ├── constants/     # App-wide constants
│   ├── theme/         # Theme configuration
│   ├── utils/         # Utility functions
│   ├── errors/        # Error handling
│   ├── network/       # Network utilities
│   └── presentation/  # Core UI components
│
├── features/          # Feature modules
│   ├── quran/         # Quran reading and audio
│   ├── prayer_times/  # Prayer times display
│   ├── audio/         # Audio playback features
│   ├── bookmarks/     # Bookmarks (future)
│   └── settings/      # App settings
│
└── main.dart
```

## Possible Feature Upgrades

- [ ] Notification for prayer times
- [ ] Location select for prayer times
- [x] Store fetched surah's list locally
- [ ] Download surah's audio
- [ ] Media control from notification bar
- [ ] Add surah's to favorites
- [x] Pick Ka'ri Voice

## Screenshots

<img src="./assets/showcase/1.png" alt="Home Screen" width="300" />
<img src="./assets/showcase/2.png" alt="Drawer" width="300" />
<img src="./assets/showcase/3.png" alt="Voice Picker" width="300" />
<img src="./assets/showcase/4.png" alt="Surah List" width="300" />
<img src="./assets/showcase/5.png" alt="Audio Controls" width="300" />
