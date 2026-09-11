# White-label brands

This app builds multiple brands from one codebase. Each brand is fully described
by `brands/<brandId>/` — the **single source of truth**. No brand values are
hardcoded in `lib/` or the native projects.

`brands/` lives at the workspace root (a sibling of the Flutter project,
`aaraakart/`), not inside the app itself, so it can be shared across sibling
apps in the workspace. `tool/apply_brand.dart` resolves it via
`brandDirFor()` in `tool/brand_utils.dart`, which looks one directory above
the Flutter project root.

## Layout

```
brands/<brandId>/
├── config.json          # every brand value (see brands/tfv/config.json)
├── icon/icon.png        # 1024×1024 launcher icon source
├── splash/splash.png    # splash screen source
├── keystore/<file>.jks  # release signing keystore (optional)
├── firebase/
│   ├── google-services.json        # Android Firebase (source of truth)
│   └── GoogleService-Info.plist    # iOS Firebase (source of truth)
└── assets/
    ├── logo.png  banner.jpg  success.json
    └── icons/<category>-icon.svg
```

### Firebase

Firebase values are **not** duplicated in `config.json`. The native
`google-services.json` and `GoogleService-Info.plist` are the source of truth;
`apply_brand.dart` parses them to regenerate `lib/firebase_options.dart`. To
change a brand's Firebase project, just replace those two files.

### Signing

`config.json`'s `keystore` block (`storeFile`, `keyAlias`, `storePassword`,
`keyPassword`) plus a keystore in `brands/<id>/keystore/` configures release
signing. `apply_brand.dart` copies the keystore into `android/app/` and writes
`android/key.properties`. If the block is empty (no password), the build falls
back to debug signing — fill in the passwords to produce a store-ready build.

## How it works

`android/` and `ios/` are **not committed** — they are generated fresh on
every `apply_brand.dart` run (git-ignored, like Expo's `prebuild`). The
brand-neutral native project template lives in `bricks/native_app/`, a
[mason](https://pub.dev/packages/mason_cli) brick. Brand identity (bundle id,
app name, version, Maps key) is baked in via mustache variables in the
template; everything else (Gradle config, permissions, Firebase plugin wiring,
Podfile, Xcode project) is static and brand-neutral.

Three layers consume `config.json`:

1. **Native skeleton** — `apply_brand.dart` runs `mason make native_app` to
   regenerate `android/` + `ios/` from `bricks/native_app/__brick__/`,
   overwriting the identity fields for the current brand.
2. **Runtime** — `apply_brand.dart` copies the active config to
   `assets/brand/config.json`; at startup `BrandConfig.load()`
   (`lib/core/config/brand_config.dart`) parses it. Drives theme colors, app
   name, content, feature flags, Maps key, and API credentials.
3. **Build time** — `apply_brand.dart` copies in the native Firebase files,
   generates app icons, splash, release signing (`key.properties`), and
   regenerates `lib/firebase_options.dart` from the native Firebase files.

### Editing the native template

Never hand-edit `android/` or `ios/` directly — they get overwritten on the
next `apply_brand.dart` run. To change something structural (a new permission,
a Gradle dependency, Podfile changes), edit the corresponding file under
`bricks/native_app/__brick__/` instead. Brand-specific values there use
mustache syntax (`{{bundle_id}}`, `{{app_name}}`, `{{version}}`,
`{{build_number}}`, `{{maps_native_key}}`) — see `bricks/native_app/brick.yaml`
for the variable list.

## Build a brand locally

```bash
dart pub global activate mason_cli
flutter pub get
dart run tool/apply_brand.dart madrasmilk
flutter build ios --config-only
flutter build apk
```

Switching brands is just re-running the script — it fully regenerates
`android/`/`ios/` from the template and overwrites the previous brand, so it
is safe to switch back and forth.

`android/`, `ios/`, `assets/brand/`, `flutter_launcher_icons.yaml`, and
`flutter_native_splash.yaml` are generated build state and are git-ignored.

## Build a brand in CI

Run the **Build (multi-brand)** GitHub Actions workflow
(`.github/workflows/build.yml`) and pick the brand from the dropdown.

## Add a new brand

1. Copy an existing folder: `cp -r brands/tfv brands/<newId>`.
2. Edit `brands/<newId>/config.json` (set `brandId`, `appName`, `bundleId`,
   colors, Firebase, Maps, API credentials, content, features).
3. Replace `icon/`, `splash/`, `assets/`, `firebase/`, and `keystore/` with the
   brand's real files.
4. Add `<newId>` to the `brand` choice list in `.github/workflows/build.yml`.
5. `dart run tool/apply_brand.dart <newId>` and build.
