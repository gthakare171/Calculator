# EulerX MathPro (Android APK & Source Bundle)

## Security
- **Zero dynamic eval() or reflection**: Uses AST recursive-descent math parser in `lib/secure_math_engine.dart`.
- **Zero permissions**: Does not request camera, contacts, internet, or storage permissions.
- **R8 ProGuard**: Minification and dead code stripping enabled in `android/app/build.gradle`.

## 1-Click APK Build in the Cloud (Free)
1. Push this folder to a new repository on GitHub.
2. Go to **Actions** tab on GitHub (workflow `.github/workflows/build_apk.yml` runs automatically).
3. Download `eulerx_mathpro-arm64-v8a-release-apk` directly from GitHub Artifacts in ~2 minutes!

## Local Build (Terminal)
```bash
flutter pub get
flutter build apk --release --split-per-abi
```
The resulting APK will be at:
`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

## Installing onto Android Phone
1. Transfer the `.apk` to your phone via USB, Google Drive, WhatsApp, or Bluetooth.
2. Tap the `.apk` file in your phone's File Manager.
3. If prompted, toggle "Allow installation from this source".
4. Tap **Install** and enjoy!
