# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Small Flutter app (Android/iOS) for saving titled URLs and launching them in an external app. The pub package name is `url_launcher_app` (not `url_launcher`, to avoid clashing with the `url_launcher` dependency), so imports look like `package:url_launcher_app/...`. Android package ID: `com.oleksii_lemeshinskyi.url_launcher`.

## Commands

```bash
flutter pub get
flutter run
flutter analyze                                   # flutter_lints; android/, ios/, build/ excluded
flutter test                                      # unit tests in test/, no device needed
flutter test integration_test/app_test.dart       # needs a device/emulator
dart run build_runner build --delete-conflicting-outputs   # regenerate Hive adapters
dart run flutter_launcher_icons                   # regenerate Android icons from assets/app-icon.png
dart run flutter_native_splash:create             # regenerate splash
```

The single integration test drives the whole add / validate / edit / delete / persist flow and calls `Hive.box('URLBox').clear()` at the start, so it wipes the app's saved data on the target device.

iOS plugins are integrated via Swift Package Manager only (`enable-swift-package-manager: true` in `pubspec.yaml`), not CocoaPods.

## Architecture

Persistence is the only backend: a single Hive CE box named `"URLBox"` holding `Item` objects (`title`, `url`).

- **Startup** (`lib/main.dart`): `Hive.initFlutter()` → `Hive.registerAdapters()` → `Hive.openBox('URLBox')` → `runApp`. The box must be open before `DbProvider` is created, since `DbProvider` grabs it synchronously with `Hive.box("URLBox")`.
- **`DbProvider`** (`lib/providers/db_provider.dart`): a plain class exposed with `Provider<DbProvider>` (not `ChangeNotifier`). UI reads it with `Provider.of<DbProvider>(context, listen: false)`.
- **Reactivity** comes from `box.watch()` (`itemsStream`) wrapped in a `StreamBuilder` in `HomeScreen`, not from Provider notifications. Items are addressed by **list index** (`putAt`/`deleteAt`), so the index passed to `EditItemScreen` and `ConfirmationDialog` must match the box order.
- **Hive codegen**: `Item` is annotated with `@HiveType(typeId: 0)`. `item.g.dart` and `hive_registrar.g.dart` are generated and committed. Don't edit them by hand. After changing `Item` fields or adding new `@HiveType` classes, rerun `build_runner`. Keep `@HiveField` numbers stable, since changing them breaks data already on users' devices.
- **Link types**: `LinkType` (`lib/models/link_type.dart`) is `link`, `email` or `phone`. Email and phone items are stored in `Item.url` as `mailto:`/`tel:` urls, so the Hive model doesn't change. `LinkType.fromUrl` detects the type from the scheme, `toUrl`/`displayValue` add or strip it in the edit screen, and `validate` is the field validator. Android needs matching `<queries>` entries in `AndroidManifest.xml` for each scheme.
- **Launching URLs**: `lib/functions/launch_url.dart` calls `launchUrl(..., LaunchMode.externalApplication)` and shows an error dialog when it throws or returns `false`. It is used both from list taps and from home-screen quick actions.
- **Quick actions** (`quick_actions`): `HomeScreen` rebuilds the app-icon shortcut list from the box on every stream event, using the item's URL as the shortcut `type` and `title` as its label. The shortcut callback then passes that `type` string straight to `launchURL`.

Screens are in `lib/screens/` (`home_screen.dart`, `edit_item_screen.dart`; the edit screen serves both add and edit, and add is reached through the `OpenContainer` FAB in `lib/widgets/fab.dart`). Shared widgets are in `lib/widgets/`.

## Notes

- Feature status is tracked in `README.md`. HTTP links, email addresses and phone numbers are supported. Translation is unchecked.
- `Privacy Policy.md` is the policy for the Play Store listing.
