# Travel App – Project Structure

This document describes the project structure for maintainability and scalability. The app uses **Provider** for state management and **go_router** for navigation.

## Directory Overview

```
lib/
├── app/                    # Application bootstrap & configuration
│   ├── app.dart            # Root widget (MultiProvider + MaterialApp)
│   └── providers.dart      # Central list of all ChangeNotifierProviders
│
├── core/                   # Shared, app-wide code (no feature logic)
│   ├── constants/          # Colors, assets, text styles, route extensions
│   ├── enums/              # Shared enums (e.g. chat, payment)
│   ├── theme/              # App theme (ThemeData, colors)
│   ├── widgets/            # Reusable UI components (buttons, cards, inputs)
│   └── core.dart           # Barrel: import '.../core/core.dart' for constants/theme/enums
│
├── features/               # (Optional future) Feature modules
│   # Each feature can have: data/, presentation/, provider/
│
├── model/                  # Data models (by domain)
│   ├── chat/
│   └── home/
│
├── provider/               # Provider state (by feature/domain)
│   ├── chat/
│   ├── home/
│   ├── profile/
│   └── trip/
│
├── routes/                 # Navigation
│   ├── go_routes.dart      # GoRouter config (combines route_pages)
│   ├── user_routes.dart    # Route name enum
│   └── route_pages/        # Route definitions by feature
│       ├── auth_routes.dart
│       ├── booking_routes.dart
│       ├── trip_routes.dart
│       ├── chat_routes.dart
│       └── profile_routes.dart
│
├── screens/                # Full-screen UI (by feature)
│   ├── auth/
│   ├── chat/
│   ├── home/
│   ├── profile/
│   ├── splash/
│   ├── tabs/
│   └── trip/
│
├── services/               # App-level services (e.g. push notifications)
│
├── firebase_options.dart   # Firebase config (generated)
└── main.dart              # Entry point: init Firebase, run App
```

## Conventions

### State management (Provider)

- **Add new providers** in `lib/app/providers.dart`. Register them in the `appProviders` list so they are available app-wide.
- Keep **one provider per feature/domain** (e.g. `home_provider`, `trip_provider`). Split large providers by responsibility.
- **Models** live under `lib/model/<domain>/`. Providers in `lib/provider/<domain>/` depend on models and core only where needed.

### Naming

- **Files**: `snake_case` (e.g. `attachment_popup.dart`, `my_trip_provider.dart`).
- **Classes**: `PascalCase` (e.g. `TripProvider`, `AttachmentPopup`).
- **Screens**: suffix with `_screen.dart` (e.g. `sign_in_screen.dart`).

### Imports

- Use **package imports**: `package:trael_app_abdelhamid/...`
- For **constants, theme, enums**: `import 'package:trael_app_abdelhamid/core/core.dart';`
- For **widgets**: import the specific file, e.g. `core/widgets/app_button.dart`, to avoid circular dependencies.

### Routes

- **Route names and paths**: `lib/routes/user_routes.dart` (enum) + `lib/core/constants/extensions/routes_extensions.dart` (e.g. `.path`).
- **GoRouter setup**: `lib/routes/go_routes.dart`. For very large apps, consider splitting route definitions by feature (e.g. `auth_routes.dart`, `trip_routes.dart`) and merging in one router.

### Adding a new feature

1. Add **screens** under `screens/<feature>/`.
2. Add **provider** under `provider/<feature>/` and register it in `app/providers.dart`.
3. Add **models** under `model/<feature>/` if needed.
4. Add **routes** in `user_routes.dart` and `go_routes.dart`.
5. Use **core** for shared widgets, colors, and theme.

## Scalability tips

- Keep **core** free of feature-specific logic.
- Prefer **small, focused providers** over one large app-state provider.
- Reuse **core/widgets** and **core/theme** so UI stays consistent.
- As the app grows, you can move to **feature folders** (e.g. `lib/features/auth/`, `lib/features/trip/`) that each contain their own screens, provider, and models.
