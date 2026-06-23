# DocFlow

Offline-first clinical calculator app for doctors.

## Local setup

1. Install Flutter and make sure `flutter --version` works.
2. From this folder run:
```powershell
flutter pub get
flutter test
```

## Firebase setup

Firebase is optional until the project credentials are added.

1. Create a Firebase project in the Firebase console.
2. Add Android and iOS apps to that project.
3. Download `google-services.json` and `GoogleService-Info.plist`.
4. Place them in the platform folders inside `docflow_app`.
5. Run `flutterfire configure` if you want generated `firebase_options.dart`.
6. Commit the generated config files once you are ready for cloud sync.

Until the Firebase project is configured, DocFlow stays offline-first and skips cloud calls safely.
