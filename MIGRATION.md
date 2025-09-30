# Clean Architecture Migration Guide

## Summary of Changes

This guide helps developers understand the architectural changes made to the Flutter Quran App.

## What Changed?

### Before (Old Structure)
```
lib/
├── models/
│   ├── audio_list.dart
│   ├── prayer_time.dart
│   ├── surah_content.dart
│   └── surah_list.dart
├── pages/
│   ├── home.dart
│   ├── location_setter.dart
│   ├── quran.dart
│   └── voice_picker.dart
├── widgets/
│   ├── drawer.dart
│   └── prayer_time.dart
└── main.dart
```

### After (New Clean Architecture)
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── presentation/
│   │   └── pages/
│   │       └── home.dart
│   ├── theme/
│   └── utils/
├── features/
│   ├── audio/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── audio_list.dart
│   │   ├── domain/
│   │   └── presentation/
│   │       └── pages/
│   │           └── voice_picker.dart
│   ├── bookmarks/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── prayer_times/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── prayer_time.dart
│   │   ├── domain/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── prayer_time.dart
│   ├── quran/
│   │   ├── data/
│   │   │   └── models/
│   │   │       ├── surah_content.dart
│   │   │       └── surah_list.dart
│   │   ├── domain/
│   │   └── presentation/
│   │       └── pages/
│   │           └── quran.dart
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── pages/
│           │   └── location_setter.dart
│           └── widgets/
│               └── drawer.dart
└── main.dart
```

## Import Path Changes

### Old Imports → New Imports

#### Main App
```dart
// OLD
import 'package:quran_app/pages/home.dart';

// NEW
import 'package:quran_app/core/presentation/pages/home.dart';
```

#### Home Page
```dart
// OLD
import 'package:quran_app/pages/quran.dart';
import 'package:quran_app/widgets/drawer.dart';
import 'package:quran_app/widgets/prayer_time.dart';

// NEW
import 'package:quran_app/features/quran/presentation/pages/quran.dart';
import 'package:quran_app/features/settings/presentation/widgets/drawer.dart';
import 'package:quran_app/features/prayer_times/presentation/widgets/prayer_time.dart';
```

#### Quran Page
```dart
// OLD
import './../models/surah_content.dart';
import './../models/surah_list.dart';

// NEW
import '../../data/models/surah_content.dart';
import '../../data/models/surah_list.dart';
```

#### Voice Picker
```dart
// OLD
import 'package:quran_app/models/audio_list.dart';

// NEW
import 'package:quran_app/features/audio/data/models/audio_list.dart';
```

#### Prayer Time Widget
```dart
// OLD
import './../models/prayer_time.dart';

// NEW
import '../../data/models/prayer_time.dart';
```

#### Settings Drawer
```dart
// OLD
import 'package:quran_app/pages/location_setter.dart';
import 'package:quran_app/pages/voice_picker.dart';

// NEW
import 'package:quran_app/features/settings/presentation/pages/location_setter.dart';
import 'package:quran_app/features/audio/presentation/pages/voice_picker.dart';
```

## File Mappings

| Old Path | New Path |
|----------|----------|
| `lib/models/surah_list.dart` | `lib/features/quran/data/models/surah_list.dart` |
| `lib/models/surah_content.dart` | `lib/features/quran/data/models/surah_content.dart` |
| `lib/models/prayer_time.dart` | `lib/features/prayer_times/data/models/prayer_time.dart` |
| `lib/models/audio_list.dart` | `lib/features/audio/data/models/audio_list.dart` |
| `lib/pages/quran.dart` | `lib/features/quran/presentation/pages/quran.dart` |
| `lib/pages/voice_picker.dart` | `lib/features/audio/presentation/pages/voice_picker.dart` |
| `lib/pages/location_setter.dart` | `lib/features/settings/presentation/pages/location_setter.dart` |
| `lib/pages/home.dart` | `lib/core/presentation/pages/home.dart` |
| `lib/widgets/prayer_time.dart` | `lib/features/prayer_times/presentation/widgets/prayer_time.dart` |
| `lib/widgets/drawer.dart` | `lib/features/settings/presentation/widgets/drawer.dart` |

## For Developers

### If you have local changes:
1. **Backup your changes**: `git stash` or create a temporary branch
2. **Pull the latest changes**: `git pull origin main`
3. **Update your imports** according to the mapping table above
4. **Test your changes**: Run `flutter pub get && flutter run`

### When adding new features:
1. Create a new folder in `features/` for your feature
2. Add three subfolders: `presentation/`, `domain/`, `data/`
3. Place your code in the appropriate layer:
   - **UI components** → `presentation/`
   - **Business logic** → `domain/`
   - **Data models & API calls** → `data/`

### Best Practices:
- Use absolute imports for cross-feature references
- Use relative imports within the same feature
- Keep dependencies pointing inward: `presentation → domain ← data`
- Never import presentation layer in domain or data layers

## Why This Change?

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Testability**: Layers can be tested independently
3. **Maintainability**: Changes are isolated to specific layers
4. **Scalability**: Easy to add new features without breaking existing code
5. **Team Collaboration**: Clear structure helps multiple developers work together

## Questions?

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.
