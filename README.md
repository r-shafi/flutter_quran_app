# Flutter Quran App

This app is built with Flutter. It is a simple app that shows todays prayer times and can be used to play Quran recitations.

All of the data used in this app comes from public API's.

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

## Releases

This project uses a tag-based GitHub Actions release workflow at `.github/workflows/release.yml`.

### Versioning

- Use tags in `vMAJOR.MINOR.PATCH` format (example: `v1.7.0`).
- Before creating the tag, update `version:` in `pubspec.yaml` to match the same semantic version.
- Keep incrementing the build number manually using `+N` (example: `1.7.0+7`, then `1.7.1+8`).

### Release Steps

1. Update `version:` in `pubspec.yaml`.
2. Commit and push the version change.
3. Create a tag, for example: `git tag v1.7.0`.
4. Push the tag: `git push origin v1.7.0`.
5. GitHub Actions will run the release workflow automatically.

### What the Workflow Does

- Runs `flutter pub get`.
- Runs `flutter analyze --fatal-warnings`.
- Builds release APKs with `flutter build apk --release --split-per-abi`.
- Uploads and publishes these APKs to the GitHub Release:
  - `app-arm64-v8a-release.apk`
  - `app-armeabi-v7a-release.apk`
  - `app-x86_64-release.apk`
