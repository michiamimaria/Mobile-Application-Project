# Mobile Application Project

This repository contains two mobile-oriented clients for luggage-related workflows: a **Flutter** app (**Luggage Checker**) and an **Expo / React Native** app in the repo root.

## Luggage Checker (Flutter)

Located in [`flutter_app/`](flutter_app/).

### Features

- Sign in and create account on a single **Auth** screen
- Bottom navigation: **Home**, **Discover**, **Profile**
- User **profile** (display name, photo, bio) and sign out
- **Discover** with browsing, filters, bookmarks, and detail views
- Material 3 **blue** theme and light/dark support (follows system)

### Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel), Dart SDK as required by `pubspec.yaml`
- Chrome (for `flutter run -d chrome`) or a configured device / emulator

### Run (Flutter)

```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

For web without launching Chrome automatically:

```bash
flutter run -d web-server
```

---

## Expo app (React Native)

Located at the **repository root** (`mobilni` package).

### Features (overview)

- Tab-based navigation, maps, notifications, and luggage-related screens (see `src/`)

### Requirements

- [Node.js](https://nodejs.org/) (LTS recommended)
- [Expo CLI](https://docs.expo.dev/get-started/installation/) via `npx`

### Run (Expo)

```bash
npm install
npm start
```

Use the Expo dev tools to open **Android**, **iOS**, or **web** (`npm run web`).

---

## Repository

- **Remote:** [github.com/michiamimaria/Mobile-Application-Project](https://github.com/michiamimaria/Mobile-Application-Project)
- Default branch: `main`

## License

Private project unless otherwise noted.
