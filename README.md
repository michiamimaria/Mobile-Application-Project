# Mobile Application Project

This repository contains two mobile-oriented clients for luggage-related workflows: a **Flutter** app (**Luggage Checker**) and an **Expo / React Native** app in the repo root.

## Localhost (local URLs)

When you run the apps on your machine, use the addresses below. **Exact ports are printed in the terminal** if yours differ.

| App | Command | Typical URL |
|-----|---------|-------------|
| **Flutter (Chrome)** | `flutter run -d chrome` | Opens a browser tab; dev server URL is printed in the terminal (`http://localhost:` plus port) |
| **Flutter (web server)** | `flutter run -d web-server` | e.g. `http://localhost:xxxxx` — copy the link from the output |
| **Expo (Metro)** | `npm start` | Bundler / dev UI often at **`http://localhost:8081`** |
| **Expo (web)** | `npm run web` | **`http://localhost:8081`** or another port shown when web starts |

Use **`http://127.0.0.1:…`** instead of `localhost` if your system resolves `localhost` oddly. Allow the firewall prompt the first time if Windows asks.

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

After `web-server` starts, open the **localhost** URL from the terminal (for example `http://localhost:54321`).

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

For **web in the browser**, Expo usually serves at **`http://localhost:8081`** (or the port shown after `npm run web`). The Metro / dev server page is also commonly **`http://localhost:8081`** while `npm start` is running.

---

## Repository

- **Remote:** [github.com/michiamimaria/Mobile-Application-Project](https://github.com/michiamimaria/Mobile-Application-Project)
- Default branch: `main`

## License

Private project unless otherwise noted.
