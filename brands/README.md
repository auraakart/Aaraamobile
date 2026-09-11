# White-label brands

This app builds multiple brands from one codebase. Each brand is described by
`brands/<brandId>/`, while structural native configuration lives in
`aaraakart/bricks/native_app/`. Together they form the source of truth for a
brand build.

`brands/` lives at the workspace root (a sibling of the Flutter project,
`aaraakart/`). `tool/apply_brand.dart` resolves it via `brandDirFor()` in
`tool/brand_utils.dart`, which looks one directory above the Flutter project
root.

## Security boundary

Tracked brand configuration is **client configuration**, not a secret store.
Anything included in `config.json`, Dart source, Android/iOS resources, or the
mobile binary must be treated as recoverable by an end user.

Do **not** store any of the following in a tracked brand config or mobile source:

- WooCommerce/admin consumer secrets
- privileged wallet credentials
- payment merchant/signing secrets
- keystore passwords
- backend service credentials

Those credentials belong in an authenticated backend/BFF or secure CI/release
secret store. Mobile code should use user-scoped authentication to backend
endpoints instead of authenticating as the store/server.

Client API keys that must ship in the app, such as Google Maps keys, must be
restricted at the provider by API and application identity/package/signing
certificate.

## Layout

```text
brands/<brandId>/
├── config.json          # client-safe brand/runtime values only
├── icon/icon.png        # 1024×1024 launcher icon source
├── splash/splash.png    # splash screen source
├── firebase/
│   ├── google-services.json        # Android Firebase source
│   └── GoogleService-Info.plist    # iOS Firebase source
└── assets/
    ├── logo.png  banner.jpg  success.json
    └── icons/<category>-icon.svg
```

A local `keystore/` directory may be used by a controlled release process, but
keystores and passwords must not be committed. Repository `.gitignore` rules
exclude common signing material.

### Firebase

Firebase values are not duplicated manually in Dart. The native
`google-services.json` and `GoogleService-Info.plist` are the brand inputs;
`apply_brand.dart` parses them to regenerate `lib/firebase_options.dart`.
Review Firebase configuration separately for provider-side restrictions and
least privilege.

### Signing

Release signing is **fail closed**. A release build must not silently fall back
to the debug keystore.

Tracked `config.json` files must keep `storePassword` and `keyPassword` empty.
For a store/release build, provision the release keystore and
`android/key.properties` from the secure release environment after brand
generation, or use an equivalent CI signing mechanism. Never commit signing
passwords or production keystores.

Debug builds remain available without release signing material.

## How it works

The portable native template lives in `aaraakart/bricks/native_app/`, a Mason
brick. `aaraakart/mason.yaml` is the portable Mason source of truth; `.mason/`
and `mason-lock.json` are local/generated state and must not be committed.

Brand identity (bundle ID, package name, app name, version, Maps key) is baked
in via mustache variables in the template. Structural settings such as Gradle,
permissions, Firebase plugin wiring, Podfile, and Xcode project configuration
belong in the brick, not in a generated platform tree.

Three layers consume brand inputs:

1. **Native skeleton** — `apply_brand.dart` runs `mason make native_app` to
   regenerate `android/` + `ios/` from `bricks/native_app/__brick__/` using the
   current brand identity.
2. **Runtime** — `apply_brand.dart` copies the active config to
   `assets/brand/config.json`; `BrandConfig.load()` parses client-safe theme,
   content, Maps, endpoint and feature configuration.
3. **Build time** — `apply_brand.dart` copies native Firebase files and can
   generate icons/splash assets. Production signing material is supplied
   separately by the secure release environment.

Some imported/generated platform files may currently exist in the repository
for compatibility, but the native brick is authoritative. A structural native
change must be made in the brick and validated by regenerating a brand.

### Editing the native template

Do not make a structural fix only in generated `android/` or `ios/` files; it
will be lost at the next brand regeneration. Make the durable change under
`bricks/native_app/__brick__/` and regenerate the active brand to validate it.
Brand-specific variables use mustache syntax such as `{{bundle_id}}`,
`{{package_name}}`, `{{app_name}}`, `{{version}}`, `{{build_number}}`, and
`{{maps_native_key}}`.

## Build a brand locally

```bash
dart pub global activate mason_cli
flutter pub get
dart run tool/apply_brand.dart madrasmilk
flutter build apk --debug
```

For a release build, provision signing material securely after brand
application, then run the release build. The build is expected to fail when
release signing is absent.

Switching brands is done by re-running the script, which regenerates the native
brand state from the template.

## CI validation

The Aaraamobile CI workflow validates:

- tracked brand configs contain no privileged server/signing secrets
- brand regeneration works on a clean runner
- changed Dart code can be formatted for validation
- static analysis contains no blocking analyzer errors
- Flutter tests pass
- the Android debug APK compiles

Warnings and legacy deprecations remain visible and should be reduced in focused
maintenance work rather than hidden.

## Add a new brand

1. Copy an existing brand folder to `brands/<newId>`.
2. Edit `brands/<newId>/config.json` with client-safe values only: identity,
   colors/theme, client-safe endpoints, Maps configuration, content and flags.
3. Leave privileged WooCommerce/wallet/payment/signing secret fields empty in
   tracked files.
4. Replace icon, splash, assets, and Firebase brand inputs as required.
5. Apply the brand from a clean environment and validate with CI/builds.
6. Provision production signing and backend secrets only through the secure
   release/backend environment.
